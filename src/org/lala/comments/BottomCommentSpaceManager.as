package org.lala.comments
{
    /** 底部字幕空间管理者 **/
    public class BottomCommentSpaceManager extends CommentSpaceManager
    {
        /** y坐标转换函数 **/
        override protected function transformY(y:int,cmt:Comment):int
        {
            return this.Height - y - cmt.height;
        }
        /** 碰撞检测 **/
        override protected function vCheck(y:int, cmt:Comment, index:int):Boolean
        {
            var bottom:int = y + cmt.height;
            for each(var c:Comment in this.Pools[index])
            {
                var _y:int = transformY(c.y,c);
                if(_y > bottom || c.bottom < y)
                {
                    continue;
                }
                else 
                {
                    return false;
                }
            }
            return true;
        }
    }
}