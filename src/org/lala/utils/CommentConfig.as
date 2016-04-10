package org.lala.utils
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.net.SharedObject;
	
    
    import mx.collections.ArrayCollection;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.IStyleManager2;
    import mx.styles.StyleManager;

    /** 配置,主要是外观的配置,存储在本地SharedObject中 **/
    public class CommentConfig extends EventDispatcher
    {
        private static var instance:CommentConfig;
        
        /** 是否显示弹幕,没有存储到本地 **/
        public var visible:Boolean=true;
        /** 是否应用到界面字体 **/
        private var _isChangeUIFont:Boolean = false;
        /** 是否启用播放器控制API **/
        private var _isPlayerControlApiEnable:Boolean = true;
        /** 画质参数，默认为土豆480P，优酷高清 **/
        private var _quality:int = 2;
        
        [Bindable]
        /** 粗体 **/
        public var bold:Boolean=true;
        [Bindable]
        /** 透明度:0-1 **/
        public var alpha:Number=1;
        [Bindable]
        /** 滤镜:0-2 **/
        public var filterIndex:int = 0;
        [Bindable]
        public var filtersArr:ArrayCollection = new ArrayCollection([
            {
				label:"细边",
				black:[new GlowFilter(0, 0.7, 3,3)],
				white:[new GlowFilter(0xFFFFFF, 0.7, 3,3)]
			}, {
				label:"浅影",
				black:[new DropShadowFilter(2, 45, 0, 0.6)],
				white:[new DropShadowFilter(2, 45, 0xFFFFFF, 0.6)]
			}, {
				label:"深影",
				black:[new GlowFilter(0, 0.85, 4, 4, 3, 1, false, false)],
				white:[new GlowFilter(0xFFFFFF, 0.85, 4, 4, 3, 1, false, false)]
			}
        ]);
        private var _font:String='Microsoft Yahei';
        [Bindable]
        /** 速度因子:0.1-2 **/
        public var speede:Number = 1;
        [Bindable]
        /** 字号缩放因子:0.1-2 **/
        public var sizee:Number = 1;
        
        private var _width:int = 540;
        private var _height:int = 432;

		/** 设置弹幕区域大小 **/
		public function size(x:int,y:int):void
		{
			_width = x;
			_height = y;
		}
        /** 宽度 **/
        public function get width():int
        {
            return _width;
        }
        /** 高度 **/
        public function get height():int
        {
            return _height;
        }

        public function CommentConfig()
        {
            if(instance != null)
            {
                throw new Error("CommentConfig is a singleton");
            }
            //测试不靠谱,略去
//            var han:RegExp = /[一-龥]/;
            load();
        }
        
        public static function getInstance():CommentConfig
        {
            if(instance == null)
            {
                instance = new CommentConfig();
            }
            return instance;
        }
        
        public function reset():void
        {
            bold = true;
            alpha = 1;
            filterIndex = 0;
            speede = 1;
            sizee = 1;
            font = ApplicationConstants.getDefaultFont();
            isChangeUIFont = false;
            quality = 2;
            isPlayerControlApiEnable = true;
        }
        
        override public function toString():String
        {
            var a:Array = [];
            a.push(bold,alpha,filterIndex,speede,sizee,font,isChangeUIFont,isPlayerControlApiEnable,quality);
            return JSON.stringify(a);
        }
        
        public function fromString(source:String):void
        {
            try
            {
                var a:Array = JSON.parse(source) as Array;
                bold = a[0];
                alpha = a[1];
                filterIndex = a[2];
                speede = a[3];
                sizee = a[4];
                font = a[5];
                isChangeUIFont = a[6];
                isPlayerControlApiEnable = a[7];
                quality = a[8];
            }
            catch(e:Error){}
            if(speede <= 0)
            {
                speede = 0.1;
            }
            if(sizee <= 0)
            {
                sizee = 0.1;
            }
        }
        
        public function load():void
        {
            try
            {
                var so:SharedObject = SharedObject.getLocal('MukioPlayer','/');
                var str:String = so.data['CommentConfig'];
                if(str)
                {
                    fromString(str);
                }
            }
            catch(e:Error){}
        }
        
        public function save():void
        {
            try
            {
                var so:SharedObject = SharedObject.getLocal('MukioPlayer','/');
                so.data['CommentConfig'] = toString();
                so.flush();
            }
            catch(e:Error){}
        }
        
        public function get filter():Array
        {
            return filtersArr[filterIndex].black;
        }

		/**
		 * 根据弹幕颜色返回边框颜色
		 * **/
		public function getFilterColor(color:uint ):Array
		{
			var colorR:uint;
			var colorG:uint
			var colorB:uint;
			colorR = color / 0x010000;
			colorG = color / 0x000100 % 0x000100;
			colorB = color % 0x000100;
			if(colorR>=0x20 || colorG>=0x20 || colorB>=0x20)return filtersArr[filterIndex].black;
			else return filtersArr[filterIndex].white;
		}
		
        [Bindable]
        /** 是否让界面使用弹幕字体?,在非中文系统中可以解决
         * Spark组件不能显示汉字的问题 **/
        public function get isChangeUIFont():Boolean
        {
            return _isChangeUIFont;
        }

        /**
         * @private
         */
        public function set isChangeUIFont(value:Boolean):void
        {
            _isChangeUIFont = value;
            if(_isChangeUIFont)
            {
                setUIFontFamily(font);
            }
        }
        
        /**
        * 辅助方法,设置系统界面字体
        **/
        private function setUIFontFamily(name:String):void
        {
            var manager2:IStyleManager2 = StyleManager.getStyleManager(null);
            var globalStyle:CSSStyleDeclaration = manager2.getStyleDeclaration('global');
            globalStyle.setStyle('fontFamily',this.font);
            manager2.setStyleDeclaration("global", globalStyle, true);
        }
        [Bindable('fontChange')]
        public function get font():String
        {
            return _font;
        }

        public function set font(value:String):void
        {
            _font = value;
            dispatchEvent(new Event('fontChange'));
            if(_isChangeUIFont)
            {
                setUIFontFamily(font);
            }
        }

        [Bindable("playerControlApiEnableChange")]
        /** 是否启用播放器控制API **/
        public function get isPlayerControlApiEnable():Boolean
        {
            return _isPlayerControlApiEnable;
        }

        /**
         * @private
         */
        public function set isPlayerControlApiEnable(value:Boolean):void
        {
            _isPlayerControlApiEnable = value;
            dispatchEvent(new Event('playerControlApiEnableChange'));
        }
        [Bindable("playerQualityChange")]
        public function get quality():int
        {
            return _quality;
        }
        
        /**
         * @private
         */
        public function set quality(value:int):void
        {
            if(value < 0 || value > 4)return;
            if(_quality == value)return;
            _quality = value;
            dispatchEvent(new Event('playerQualityChange'));
        }
        

    }
}