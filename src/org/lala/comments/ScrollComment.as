package org.lala.comments
{
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import fl.transitions.easing.None;

    /** 滚动字幕类 **/
    public class ScrollComment extends Comment
    {
        /** 动画对象 **/
        protected var _tw:Tween;
        /** 滚动时间 **/
        protected var _dur:Number;
        /** 构造函数 **/
        public function ScrollComment(data:Object)
        {
            super(data);
        }
        /** 设置持续时间,在滚动空间管理类中设置 **/
        public function set duration(dur:Number):void
        {
            this._dur = dur;
        }
        /**
         * 开始播放
         * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
         */
        override public function start():void
        {
            _tw = new Tween(this,'x',None.easeOut,x,-width,_dur,true);
            _tw.addEventListener(TweenEvent.MOTION_FINISH,completeHandler);
            _tw.resume();
        }
        /**
         * 结束事件监听
         */
        protected function completeHandler(event:TweenEvent):void
        {
            _complete();
            _tw = null;
            delete this;
        }
        /**
         * 恢复播放
         */
        override public function resume():void
        {
            _tw.resume();
        }
        /**
         * 暂停
         */
        override public function pause():void
        {
            _tw.stop();
        }

    }
}