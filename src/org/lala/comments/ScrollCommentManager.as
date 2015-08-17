package org.lala.comments
{
    import flash.display.Sprite;
    
    import org.lala.event.*;
    import org.lala.net.*;
    import org.lala.utils.*;
    /** 滚动字幕管理 **/
    public class ScrollCommentManager extends CommentManager
    {
        public function ScrollCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 设置空间管理者
         **/
        override protected function setSpaceManager():void
        {
            this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
        }
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FLOW_RIGHT_TO_LEFT);
        }
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
        override protected function getComment(data:Object):IComment
        {
            return IComment(new ScrollComment(data));
        }
    }
}