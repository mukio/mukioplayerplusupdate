package org.lala.comments 
{
    import flash.display.DisplayObject;
    import flash.events.TimerEvent;
    import flash.filters.*;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Timer;
    
    import org.lala.utils.CommentConfig;
    
    /**
     * Comment类,定义了弹幕的生命周期内各种动作:本身为基本字幕
     * 弹幕在舞台的起始与终结
     * @author aristotle9
     */
    public class Comment extends TextField implements IComment
    {
        /**
         * 完成地调用的函数,无参数
         */
        protected var _complete:Function;
        /** 配置数据 **/
        protected var item:Object;
        /** 空间分配索引,记录所占用的弹幕空间层 **/
        protected var _index:int;
        /** 底部位置,为减少计算 **/
        protected var _bottom:int;
        /** 时计 **/
        protected var _tm:Timer;
        /** 配置 **/
        protected var config:CommentConfig = CommentConfig.getInstance();
        /**
         * 构造方法
         * @param	data 弹幕数据信息
         */
        public function Comment(data:Object) 
        {
            item = {};
            for (var key:String in data)
            {
                item[key] = data[key]
            }
            init();
        }
        /**
        * 设置空间索引和y坐标
        **/
        public function setY(py:int,idx:int,trans:Function):void
        {
            this.y = trans(py,this);
            this._index = idx;
            this._bottom = py + this.height;
        }
        /** 
        * 空间索引读取,在移除出空间时被空间管理者使用
        **/
        public function get index():int
        {
            return this._index;
        }
        /**
        * 底部位置,在空间检验时用到
        **/
        public function get bottom():int
        {
            return this._bottom;
        }
        /**
        * 右边位置
        **/
        public function get right():int
        {
            return this.x + this.width;
        }
        /**
        * 开始时间
        **/
        public function get stime():Number
        {
            return this.item['stime'];
        }
        /**
         * 初始化,由构造函数最后调用
         */
        protected function init():void
        {
            this.defaultTextFormat = new TextFormat(config.font, config.sizee * item.size, item.color, config.bold);
            this.alpha = config.alpha;
            this.autoSize = "left";
            this.text = item.text;
            this.border = item.border;
            this.borderColor = 0x0099FF;
            //this.filters = config.filter;
			this.filters = config.getFilterColor(item.color);
        }
        /**
         * 恢复播放
         */
        public function resume():void
        {
            this._tm.start();
        }
        /**
         * 暂停
         */
        public function pause():void
        {
            this._tm.stop();
        }
        /**
         * 开始播放
         */
        public function start():void
        {
            this._tm = new Timer(250,10);
            this._tm.addEventListener(TimerEvent.TIMER_COMPLETE,completeHandler);
            this._tm.start();
        }
        /**
        * 时计结束事件监听
        */
        private function completeHandler(event:TimerEvent):void
        {
            this._complete();
        }
        /**
         * 设置完成播放时调用的函数,调用一次仅一次
         * @param	foo 完成时调用的函数,无参数
         */
        public function set complete(foo:Function):void
        {
            this._complete = foo;
        }
    }
    
}