package org.lala.comments
{
    import flash.display.Sprite;

    import org.lala.event.*;
    import org.lala.net.*;
    import org.lala.utils.*;
    /** 反向滚动弹幕 **/
    public class RScrollCommentManager extends ScrollCommentManager
    {
        public function RScrollCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FLOW_LEFT_TO_RIGHT);
        }
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
        override protected function getComment(data:Object):IComment
        {
            return new RScrollComment(data);
        }
    }
}