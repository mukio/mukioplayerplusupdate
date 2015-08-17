package org.lala.comments
{
    import flash.display.Sprite;
    
    import org.lala.event.CommentDataEvent;

    /** bili的新类型弹幕管理者,比较简单 **/
    public class FixedPosCommentManager extends CommentManager
    {
        public function FixedPosCommentManager(clip:Sprite)
        {
            super(clip);
        }
        override protected function setSpaceManager():void
        {
            /** 置空 **/
        }
        override public function resize(width:Number, height:Number):void
        {
            /** 置空 **/
        }
        override protected function setModeList():void
        {
            this.mode_list.push(CommentDataEvent.FIXED_POSITION_AND_FADE);
        }
        override protected function add2Space(cmt:IComment):void
        {
            /** 置空 **/
        }
        override protected function removeFromSpace(cmt:IComment):void
        {
            /** 置空 **/
        }
        override protected function getComment(data:Object):IComment
        {
            return new FixedPosComment(data);
        }
    }
}