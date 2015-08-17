package org.lala.comments 
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    
    import org.lala.event.*;
    import org.lala.net.*;
    import org.lala.plugins.CommentView;
    import org.lala.utils.*;
    /**
     * CommentManager的基类:本身实现顶端字幕管理
     * 维护了一个时间轴,可以在这个时间轴上添加弹幕
     * 外部通过调用time方法来驱动时间轴
     * 驱动时调用弹幕自身的播放方法
     * play,pause方法用来恢复,暂停已经被驱动了的弹幕的动作,因为即使停止驱动时间轴弹幕动作也可能在播放
     * @author aristotle9
     */
    public class CommentManager
    {
        /**
         * 时间轴,为弹幕数据信息数组,按时间顺序插入
         */
        protected var timeLine:Array = [];
        /**
         * 时间轴当前位置索引
         */
        protected var pointer:int = 0;
        /**
         * 保存上一次time调手时的时间位置
         */
        protected var oldPosition:Number = 0;
        /**
         * 弹幕舞台
         */
        protected var clip:Sprite;
        /**
        * 弹幕来源
        **/
        protected var _provider:CommentProvider = null;
        /**
        * 弹幕过滤器
        **/
        protected var _filter:CommentFilter = null;
        /** 弹幕空间管理者 **/
        protected var space_manager:CommentSpaceManager;
        /** 弹幕模式集,用于监听 **/
        protected var mode_list:Array = [];
        /** 普通弹幕配置类 **/
        protected var config:CommentConfig = CommentConfig.getInstance();
        /** 准备栈 **/
        protected var prepare_stack:Array = [];
        /**
         * 构造函数
         */
        public function CommentManager(clip:Sprite) 
        {
            this.clip = clip;
            this.setSpaceManager();
            this.setModeList();
        }
        /**
        * 设置要监听的模式
        **/
        protected function setModeList():void
        {
            /** 因为本类管理顶部字幕,所以监听TOP消息 **/
            this.mode_list.push(CommentDataEvent.TOP);
        }
        /**
        * 设置空间管理者
        **/
        protected function setSpaceManager():void
        {
            this.space_manager = new CommentSpaceManager();
        }
        /**
        * 设置弹幕来源,同时监听好弹幕分发事件
        * @param prd 弹幕来源类实例
        **/
        public function set provider(prd:CommentProvider):void
        {
            var mode:String;
            if(this._provider != null)
            {
                for each(mode in this.mode_list)
                {
                    this._provider.removeEventListener(mode,commentDataHandler);
                }
                this._provider.removeEventListener(CommentDataEvent.CLEAR,clearDataHandler);
            }
            this._provider = prd;
            for each(mode in this.mode_list)
            {
                this._provider.addEventListener(mode,commentDataHandler);
            }
            this._provider.addEventListener(CommentDataEvent.CLEAR,clearDataHandler);
        }
        /**
        * 弹幕分发事件监听器
        **/
        protected function commentDataHandler(event:CommentDataEvent):void
        {
            insert(event.data);
        }
        /**
        * 弹幕清除事件监听器
        **/
        protected function clearDataHandler(event:CommentDataEvent):void
        {
            this.clean();
        }
        /**
        * 设置弹幕过滤器
        * @param flt 弹幕过滤器实例
        **/
        public function set filter(flt:CommentFilter):void
        {
            this._filter = flt;
        }
        /**
         * 清除时间轴上所有弹幕数据
         */
        public function clean():void
        {
            this.timeLine = [];
            this.pointer = 0;
            this.oldPosition = 0;
        }
        /**
         * 暂停在该Manager上的所有弹幕的动作
         */
        public function pause():void
        {
            
        }
        /**
         * 继续播放在该Manager上的所有弹幕的动作
         */
        public function resume():void
        {
            
        }
        /**
         * 在该Manager上添加一个弹幕
         * @param	data 弹幕数据信息
         */
        public function insert(data:Object):void
        {
            /*
            * 拷贝副本
            */
            var obj:Object = {on:false};
            for (var key:String in data)
            {
                obj[key] = data[key];
            }
            /*
            * 如果带有边框,则立即呈现播放
            */
            if (obj.border) 
            {
                this.start(obj);
            }
            /*
            * 带有preview属性则不插入时间轴
            */
            if (obj.preview) 
            {
                return;
            }
            /*
            * 得到插入位置
            */
            var p:int = bsearch(this.timeLine, obj, function(a:*, b:*):Number {
                if (a.stime < b.stime) 
                {
                    return -1;
                }
                else
                    if (a.stime > b.stime)
                    {
                        return 1;
                    }
                    else 
                    {
                        if (a.date < b.date)
                        {
                            return -1;
                        }
                        else if (a.date > b.date)
                        {
                            return 1;
                        } else 
                        {
                            return 0;
                        }
                    }
            });
            /*
            * 插入
            */
            this.timeLine.splice(p, 0, obj);
            /*
            * 在时间轴当前位置之前插入,要把当前位置向后移动
            */
            if (p <= this.pointer)
            {
                this.pointer ++;
            }
            start_all();
        }
        /**
         * 开始播放一个弹幕
         * @param	data 弹幕数据信息
         */
        protected function start(data:Object):void
        {
            /** 在终结前不再被渲染 **/
            data['on'] = true;
            var cmt:IComment = this.getComment(data);
            var self:CommentManager = CommentManager(this);
            cmt.complete = function():void {
                self.complete(data);
                self.removeFromSpace(cmt);
                clip.removeChild(DisplayObject(cmt));
//                cmt = null;
            };
            this.add2Space(cmt);
            /** 添加到舞台 **/
            clip.addChild(DisplayObject(cmt));
            /** 压入准备栈,在所有弹幕准备完成后一同出栈 **/
            prepare_stack.push(cmt);
        }
        /**
        * 空间分配
        **/
        protected function add2Space(cmt:IComment):void
        {
            this.space_manager.add(Comment(cmt));
        }
        /**
        * 空间回收
        **/
        protected function removeFromSpace(cmt:IComment):void
        {
            this.space_manager.remove(Comment(cmt));
        }
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
        protected function getComment(data:Object):IComment
        {
            return new Comment(data);
        }
        /**
         * 当一个弹幕完成播放动作时调用
         * @param	data 弹幕数据信息
         */
        protected function complete(data:Object):void
        {
            data['on'] = false;
        }
        /**
         * 更改Manager的宽高参数,这些参数影响了弹幕的位置与大小
         * @param	width 宽度
         * @param	height 高度
         */
        public function resize(width:Number, height:Number):void
        {
            this.space_manager.setRectangle(config.width,config.height);
        }
        /**
         * 驱动Manager的时间轴
         * @param	position 时间,单位秒
         */
        public function time(position:Number):void
        {
            /** 前移微小步,以方便0时间的弹幕展示 **/
            position = position - 0.001;
            /** 当时间头到底,或者前后时间位置相差大于2秒时,强行移动时间头,这是自动判断的,所以该类没有专门的seek事件处理函数 **/
            if (this.pointer >= this.timeLine.length || Math.abs(this.oldPosition - position) >= 2) {
                this.seek(position);
                this.oldPosition = position;
                if (this.timeLine.length <= this.pointer)
                {
                    return;
                }
            } else
            {
                this.oldPosition = position;
            }
            for (; this.pointer < this.timeLine.length; this.pointer++ ) {
                if (this.getData(this.pointer)['stime'] <= position) 
                {
                    if (this.validate(this.getData(this.pointer)))
                    {
                        this.start(this.getData(this.pointer));
                    }
                }
                else 
                {
                    break;
                }
            }
            //弹出所有准备栈中的可视弹幕实例
            start_all();
        }
        /**
        * 启动弹幕,该方法跟在所有的this.start之后调用
        ***/
        protected function start_all():void
        {
            if(CommentView.getInstance().isPlaying)
            {
                while(prepare_stack.length)
                {
                    var cmt:IComment = prepare_stack.pop();
                    cmt.start();
                }            
            }
            else
            {
                while(prepare_stack.length)
                {
                    cmt = prepare_stack.pop();
                    cmt.start();
                    /** 暂停时发送的弹幕,在显示后立即暂停 **/
                    cmt.pause();
                }            
            }
        }
        /**
         * 提取弹幕数据
         * @param	index 时间轴上的索引
         * @return 位置index上的弹幕数据,出错时返回null
         */
        protected function getData(index:int):Object
        {
            if (index >= 0 && index < this.timeLine.length) 
            {
                return this.timeLine[index];
            }
            return null;
        }
        /**
         * 拨动Manager的时间头,当前后调用time的position参数相差较大时调用
         * @param	position 时间,单位秒
         */
        protected function seek(position:Number):void
        {
            this.pointer = bsearch(this.timeLine, position, function(pos:*, data:*):Number 
            {
                if (pos < data.stime)
                {
                    return -1;
                }
                else if(pos > data.stime)
                {
                    return 1;
                }
                else
                {
                    return 0;
                }
            });
        }
        /**
         * 校验函数,决定是否显示该弹幕
         * @param	data 弹幕数据
         * @return true表示允许显示,false表示不允许显示
         */
        protected function validate(data:Object):Boolean
        {
            if (data['on'])
            {
                return false;
            }
            return _filter.validate(data);
        }
        /**
         * 在数组arr中二分搜索
         * @param	arr 搜索的数组
         * @param	a 搜索目标
         * @param	fn 比较函数
         * @return 位置索引
         */
        public static function bsearch(arr:Array, a:*,fn:Function):int
        {
            if (arr.length == 0) 
            {
                return 0;
            }
            if (fn(a, arr[0]) < 0)
            {
                return 0;
            }
            if (fn(a, arr[arr.length - 1]) >= 0)
            {
                return arr.length;
            }
            var low:int = 0;
            var hig:int = arr.length - 1;
            var i:int;
            var count:int = 0;
            while (low <= hig)
            {
                i = Math.floor((low + hig + 1) / 2);
                count++;
                if (fn(a, arr[i - 1]) >= 0 && fn(a, arr[i]) < 0) 
                {
                    return i;
                } else if (fn(a, arr[i - 1]) < 0) 
                {
                    hig = i - 1;
                } else if (fn(a, arr[i]) >= 0) 
                {
                    low = i;
                } else 
                {
                    throw new Error('查找错误.');
                }
                if (count > 1000) {
                    throw new Error('查找超时.');
                    break;
                }
            }
            return -1;
        }
        /**
         * 二分插入
         * @param	arr 插入的数组
         * @param	a 插入对象
         * @param	fn 比较函数
         */
        public static function binsert(arr:Array, a:*, fn:Function):void
        {
            var i:int = bsearch(arr, a, fn);
            arr.splice(i, 0, a);
        }
    }
    
}