package org.lala.comments
{
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import fl.transitions.easing.None;
    
    /** 反向滚动弹幕 **/
    public class RScrollComment extends ScrollComment
    {
        public function RScrollComment(data:Object)
        {
            super(data);
        }
        /**
         * 开始播放
         * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
         */
        override public function start():void
        {
            _tw = new Tween(this,'x',None.easeOut,-width,x,_dur,true);
            _tw.addEventListener(TweenEvent.MOTION_FINISH,completeHandler);
            _tw.resume();
        }
    }
}