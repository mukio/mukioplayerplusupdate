package org.lala.plugins
{
    import com.longtailvideo.jwplayer.controller.Controller;
    import com.longtailvideo.jwplayer.events.*;
    import com.longtailvideo.jwplayer.model.PlaylistItem;
    import com.longtailvideo.jwplayer.player.*;
    import com.longtailvideo.jwplayer.plugins.*;
    import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.system.System;
    import flash.text.TextField;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import org.lala.comments.*;
    import org.lala.net.*;
    import org.lala.utils.*;
    
    /**
     * 纯JWPlayer v5.x的弹幕播放插件:
     * 只实现弹幕的加载与播放,无发送界面与功能,无过滤器设置界面与功能
     * @author aristotle9
     **/    
    /** 内全屏按下 **/
    [Event(name='innerFullScreen',type='flash.events.Event')]
    public class CommentView extends Sprite implements IPlugin
    {
        [Embed(source="assets/innerFullScreenIcon.png")]
        /** 内全屏图标 **/
        private var InnerFullScreenButtonIcon:Class;
        private var _innerFullScreenButtonIcon:Bitmap;
        private var _innerFullScreenButton:MovieClip = null;
        
        [Embed(source="assets/loopIcon.png")]
        /** 循环图标 **/
        private var LoopButtonIcon:Class;
        private var _loopButtonIcon:Bitmap;
        
//        [Embed(source="assets/commentShowIcon.png")]
//        /** 显示隐藏弹幕图标 **/
//        private var CommentVisibleIcon:Class;
//        private var _visibleButtonIcon:Bitmap;
        
        /** 插件配置,用于从外部传参数给本插件 **/
        private var config:PluginConfig;
        /** 对JWP的引用 **/
        private var player:IPlayer;
        /** 弹幕来源,只有唯一一个实例 **/
        private var _provider:CommentProvider;
        /** 弹幕过滤器,只有唯一一个实例 **/
        private var _filter:CommentFilter;
        /** 弹幕管理者 **/
        private var managers:Vector.<CommentManager>;
        /**
        JWP(layer)是可以将列表作为播放对象的,如果只将一个cid参数传给播放器实为不妥
        (相当于一个列表中的所有视频都使用该弹幕),因此最好从播放的item事件中提取cid.
        本着对JWP最小修改的原则,不再将cid属性hack到播放的item中,
        考虑到JWP使用file,type两个参数定义视频来源.因此用type=sina&file={vid}这种写法来取代
        vid={vid},并且cid就是该vid.因此也不能在播放器外部直接配置cid(JWP没有cid参数,不打算更改)
        ,只要有较短的file(vid)都能直接转化为cid.
        **/
        /** 弹幕层,类本身是插件层,但是位置不符合弹幕的需求,所以另起一层 **/
        private var _clip:Sprite;
        /** 不使用遮罩可以提高效率 **/
//        private var clipMask:Sprite;
        /** singleton **/
        private static var instance:CommentView;
        /** 时间点 **/
        private var _stime:Number=0;
        /** 普通弹幕配置 **/
        private var cmtConfig:CommentConfig = CommentConfig.getInstance();
        /** 复制右键 **/
        private var copyMenuItem:ContextMenuItem;
        /** 关于右键 **/
        private var aboutMenuItem:ContextMenuItem;
        /** 播放器右键 **/
        private var menuArr:Array=[];
        /** 插件的版本号,非JW播放器 **/
        private var _version:String;
        /** 简化的视频的播放器态,播放或静止 **/
        private var _isPlaying:Boolean = false;
        
        public function CommentView()
        {
            if(instance != null)
            {
                throw new Error("class CommentView is a Singleton,please use getInstance()");
            }
            /** 不接收点击事件 **/
            this.mouseEnabled = this.mouseChildren = false;
            _clip = new Sprite();
            _clip.name = 'commentviewlayer';
            _clip.mouseEnabled = _clip.mouseChildren = false;
//            clipMask = new Sprite();
//            clipMask.name = 'commentviewmasklayer';
            managers = new Vector.<CommentManager>();
            init();
        }
        /** 单件 **/
        public static function getInstance():CommentView
        {
            if(instance == null)
            {
                instance = new CommentView();
            }
            return instance;
        }
        /** 接口方法:初始化插件,这时插件层已经添加到播放器的plugins层上,为最表层 **/
        public function initPlugin(ply:IPlayer, conf:PluginConfig):void
        {
            player = ply;
            config = conf;
            player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM,itemHandler);
            player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME,timeHandler);
            player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE,stateHandler);			
            /**
            * 把层放置在紧随masked之后
            * 从View.setupLayers函数可以看到JWP的层次结构,Plugin在最表层
            **/
            var _p:DisplayObjectContainer = this.parent;
            var _root:DisplayObjectContainer = _p.parent;
            var _masked:DisplayObject = _root.getChildByName('masked');
            /** 插入弹幕层,注意位置 **/
//            _root.addChildAt(clipMask,_root.getChildIndex(_masked) + 1);
            _root.addChildAt(_clip,_root.getChildIndex(_masked) + 1);
//            clip.mask = clipMask;
            
            setupUI();
            setUpRightClick(MovieClip(_root));
            
            /** 设置播放状态的初值 **/
            _isPlaying = player.config.autostart;
        }
        /** 右键 **/
        private function setUpRightClick(_root:MovieClip):void
        {
            //已经确定播放器的右键在root上
            copyMenuItem = new ContextMenuItem("--点击以上菜单复制内容--",true,false);
            aboutMenuItem = new ContextMenuItem("关于 MukioPlayer v" + _version + '...');
            aboutMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,aboutHandler);
            var mn:ContextMenu = new ContextMenu();
            mn.hideBuiltInItems();
            mn.customItems.push(copyMenuItem);
            mn.customItems.push(aboutMenuItem);
            menuArr.unshift(aboutMenuItem);
            for each(var mni:ContextMenuItem in _root.contextMenu.customItems)
            {
                mni.separatorBefore = false;
                mn.customItems.push(mni);
                menuArr.unshift(mni);
            }
            _root.contextMenu = mn;
            _root.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,createCopyCommentMenus);
        }
        /** 关于 **/
        protected function aboutHandler(evt:ContextMenuEvent):void
        {
            navigateToURL(new URLRequest('http://code.google.com/p/mukioplayer/'), '_blank');
        }
        /** 点击右键后,开始生成菜单 **/
        private function createCopyCommentMenus(event:ContextMenuEvent):void
        {
            var p:Point = new Point(_clip.stage.mouseX,_clip.stage.mouseY);
            var menus:Array = [];
            var i:int;
            for(i = 0; i < _clip.numChildren; i++)
            {
                var c:DisplayObject = _clip.getChildAt(i);
                if(c is TextField)
                {
                    if(c.hitTestPoint(p.x,p.y))
                    {
                        menus.push(createMenu(TextField(c)));
                    }
                }
            }
            var mn:ContextMenu = event.target as ContextMenu;
            mn.customItems= [];
            if(menus.length != 0)
            {
                while(menus.length)
                {
                    mn.customItems.push(menus.pop());
                }
                mn.customItems.push(copyMenuItem);
            }
            for(i = 0; i < menuArr.length; i ++)
            {
                mn.customItems.push(menuArr[i]);
            }
        }
        /** 生成一个可以复制内容的菜单项 **/
        private function createMenu(c:TextField):ContextMenuItem
        {
            var mni:ContextMenuItem = new ContextMenuItem('>> ' + c.text.substr(0,20) + (c.text.length > 20 ? '...' : ''));
            mni.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(event:ContextMenuEvent):void
            {
                System.setClipboard(c.text);
            });
            return mni;
        }
        /** 添加按钮等等 **/
        private function setupUI():void
        {
            var cb:IControlbarComponent = player.controls.controlbar;
            this._innerFullScreenButtonIcon = new InnerFullScreenButtonIcon() as Bitmap;
           // _innerFullScreenButton = cb.addButton(this._innerFullScreenButtonIcon,'WideScreen',innerFullScreenButtonHandler);
            //innerfullscreenbutton,在ZIP皮肤中文本替换会有误差,布局是由文本控制的这一点不太好,fullscreen一替换谅出问题,取另外名字
            
            _loopButtonIcon = new LoopButtonIcon() as Bitmap;
//            cb.addButton(_loopButtonIcon,'LoopBt',loopButtonHandler);
			
			player.addEventListener("loopButtonHandler",loopButtonHandler);
			player.addEventListener("unloopButtonHandler",loopButtonHandler);
            _loopButtonIcon.alpha = player.config.repeat != 'single' ? 0.5 : 1;
            //使用ZIP皮肤时必须在装好按钮后设置
            
//            _visibleButtonIcon = new CommentVisibleIcon() as Bitmap;
//            cb.addButton(_visibleButtonIcon,'VisibleBt',visibleButtonHandler);
        }
        /**
        * 内全屏事件监听 
        **/
        private function innerFullScreenButtonHandler(event:Event):void
        {
            dispatchEvent(new Event('innerFullScreen'));
        }
        /**
        * 是否循环切换
        **/
        private function loopButtonHandler(event:Event):void
        {
			var cb:IControlbarComponent = player.controls.controlbar;
            if(player.config.repeat != true )
            {
                player.config.repeat  = true;
               // _loopButtonIcon.alpha = 1;
				//在ControlBarComponentsV4中设置
            }
            else
            {
                player.config.repeat  = false;
                //_loopButtonIcon.alpha = .5;
            }
        }
        /** 状态改变事件监听器,监听暂停或者播放 **/
        private function stateHandler(event:PlayerStateEvent):void
        {
            var i:int;
            var c:DisplayObject;
            if((event.newstate == 'PLAYING' && event.oldstate != 'BUFFERING') || 
                (event.newstate == 'BUFFERING' && event.oldstate != 'PLAYING'))
            {
                for(i = 0; i < _clip.numChildren; i++)
                {
                    c = _clip.getChildAt(i);
                    if(c is IComment)
                    {
                        IComment(c).resume();
                    }
                }
                _isPlaying = true;
            }
            else if((event.oldstate == 'PLAYING' && event.newstate != 'BUFFERING') ||
                (event.oldstate == 'BUFFERING' && event.newstate != 'PLAYING'))
            {
                for(i = 0; i < _clip.numChildren; i++)
                {
                    c = _clip.getChildAt(i);
                    if(c is IComment)
                    {
                        IComment(c).pause();
                    }
                }
                _isPlaying = false;
            }
        }
        /** 接口方法:播放器调整大小时被调用 **/
        public function resize(width:Number, height:Number):void
        {
            /** 还没有搞清楚传递进来的参数是否符合要求 **/
            /** display的大小比较接近 **/
            /** 视频是player.model.media.display,无API获取 **/
            var w:int = player.controls.display.width;
            var h:int = player.controls.display.height;
            var rw:Number = w / cmtConfig.width;
            var rh:Number = h / cmtConfig.height;
/**        if(rw < rh)
                var r:Number = rw;
            else 
                r = rh;
            _clip.scaleY = _clip.scaleX = r;
            _clip.x = (w - cmtConfig.width * r) / 2;
            _clip.y = (h - cmtConfig.height * r) / 2;  **/
			_clip.x = 0;
			_clip.y = 0;
			cmtConfig.size(w,h);
            /** 通知到位 **/
            for each(var manager:CommentManager in managers)
            {
                manager.resize(w,h);
            }
            
//            clipMask.x = 0;
//            clipMask.y = 0;
//            
//            var g:Graphics = clipMask.graphics;
//            g.clear();
//            g.beginFill(0);
//            g.drawRect(0,0,w,h);
//            g.endFill();
//            if(clip.x > 0)
//            {
//                var m:Matrix = new Matrix();
//                m.createGradientBox(20,20,0,-20,0);
//                trace(m.toString());
//                g.beginGradientFill(GradientType.LINEAR,[0,0],[0,1],[0,0xff],m);
//                g.drawRect(-20,0,20,h);
//                g.endFill();
//
//                m.createGradientBox(20,20,0,cmtConfig.width * r,0);
//                g.beginGradientFill(GradientType.LINEAR,[0,0],[1,0],[0,0xff],m);
//                g.drawRect(cmtConfig.width * r,0,cmtConfig.width * r + 20,h);
//                g.endFill();
//            }
            
            /** 全屏时隐藏innerFullScreen图标 **/
//            _innerFullScreenButton.visible = stage.displayState == 'fullScreen' ? false:true;
            var b:Boolean = stage.displayState == 'fullScreen' ? false:true;
            _innerFullScreenButtonIcon.alpha = b == true ? 1 : 0.5;
        }
        /** 接口方法,唯一的,小写字母标识 **/
        public function get id():String
        {
            return 'commentview';
        }
        /** 
        * 监听播放列表的item事件,加载弹幕从此开始
        * 弹幕可能滞后,因为没有同步加载
        **/
        private function itemHandler(event:PlaylistEvent):void
        {
            //不再使用,加载弹幕由主程序控制
//            var item:PlaylistItem = player.playlist.currentItem;
//            if(config['url'])
//            {
//                try
//                {
//                    this.loadComment(config['url']);
//                }
//                catch(e:Error)
//                {
//                    
//                }
//            }
        }
        /**
        * 加载弹幕
        * @param url 弹幕文件路径
        **/
        public function loadComment(url:String):void
        {
            this._provider.load(url);
        }
        /**
        * 播放时间事件
        **/
        private function timeHandler(event:MediaEvent):void
        {
            if(cmtConfig.visible == false)
            {
                return;
            }
            _stime = event.position;
            for each(var manager:CommentManager in managers)
            {
                manager.time(event.position);
            }
        }
        /**
        * 当前时间
        **/
        public function get stime():Number
        {
            return _stime;
        }
        /**
        * 自身的初始化
        **/
        private function init():void
        {
            this._provider = new CommentProvider();
            this._filter = CommentFilter.getInstance();
            addManagers();
        }
        /**
        * 添加弹幕管理者,每一种弹幕模式对应一个弹幕管理者
        */
        private function addManagers():void
        {
            addManager(new CommentManager(_clip));
            addManager(new BottomCommentManager(_clip));
            addManager(new ScrollCommentManager(_clip));
            addManager(new RScrollCommentManager(_clip));
            addManager(new FixedPosCommentManager(_clip));
            addManager(new ZoomeCommentManager(_clip));
            addManager(new ScriptCommentManager(_clip));
        }
        /**
        * 添加弹幕管理者
        **/
        private function addManager(manager:CommentManager):void
        {
            manager.provider = this._provider;
            manager.filter = this._filter;
            this.managers.push(manager);
        }
        
        /**
        * 返回弹幕提供者
        **/
        public function get provider():CommentProvider
        {
            return this._provider;
        }
        
        /**
        * 返回弹幕过滤器
        **/
        public function get filter():CommentFilter
        {
            return this._filter;
        }
        
        /**
        * 返回弹幕舞台
        **/
        public function get clip():Sprite
        {
            return _clip;
        }

        /** 插件版本号 **/
        public function get version():String
        {
            return _version;
        }
		
		/**适用JW版本号**/
		public function get target():String {
			return "6.0";
		}
        
		/**
         * 插件版本号
         */
        public function set version(value:String):void
        {
            _version = value;
        }

        /** 简化的视频的播放器态,播放或静止 **/
        public function get isPlaying():Boolean
        {
            return _isPlaying;
        }


    }
}