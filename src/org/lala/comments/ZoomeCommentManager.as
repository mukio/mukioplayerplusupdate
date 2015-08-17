package org.lala.comments
{
    import flash.display.Sprite;
    
    import org.lala.event.CommentDataEvent;
    /** zoome弹幕管理类 **/
    public class ZoomeCommentManager extends CommentManager
    {
        public function ZoomeCommentManager(clip:Sprite)
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
            this.mode_list.push(CommentDataEvent.ZOOME_NORMAL);
            this.mode_list.push(CommentDataEvent.ZOOME_LOUD);
            this.mode_list.push(CommentDataEvent.ZOOME_THINK);
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
            return new ZoomeComment(data);
        }
    }
}