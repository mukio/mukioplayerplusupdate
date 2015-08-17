package org.lala.comments
{
    import flash.display.Sprite;
    
    import org.lala.event.*;
    import org.lala.net.*;
    import org.lala.utils.*;

    /** 底部字幕管理者 **/
    public class BottomCommentManager extends CommentManager
    {
        /** 构造函数 **/
        public function BottomCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 设置空间管理者
         **/
        override protected function setSpaceManager():void
        {
            this.space_manager = CommentSpaceManager(new BottomCommentSpaceManager());
        }
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.BOTTOM);
        }
    }
}