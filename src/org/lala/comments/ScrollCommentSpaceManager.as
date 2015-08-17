package org.lala.comments
{
    /** 滚动字幕空间管理类 **/
    public class ScrollCommentSpaceManager extends CommentSpaceManager
    {
        /** 滚动秒数,或者要速度恒定则在getSpeed中定义速度 **/
        private var duration:Number = 3;
        
        override public function add(cmt:Comment):void
        {
            cmt.x = this.Width;
            ScrollComment(cmt).duration = (this.Width + cmt.width) / this.getSpeed(cmt);
            if(cmt.height >= this.Height)
            {
                cmt.setY(0,-1,transformY);
            }
            else 
            {
                this.setY(cmt);
            }
        }
        override protected function vCheck(y:int, cmt:Comment, index:int):Boolean 
        {
            var bottom:int = y + cmt.height;
            var right:int = cmt.x + cmt.width;
            for each(var c:Comment in this.Pools[index])
            {
                if(c.y > bottom || c.bottom < y)
                {
                    continue;
                }
                else if(c.right < cmt.x || c.x > right) 
                {
                    if(this.getEnd(c) <= this.getMiddle(cmt))
                    {
                        continue;
                    }
                    else 
                    {
                        return false;
                    }
                }
                else 
                {
                    return false;
                }
            }
            return true;
        }
        /** 弹幕速度,未在Comment中定义是因为与弹幕空间有关 **/
        private function getSpeed(cmt:Comment):Number
        {
            return config.speede * 0.5 * (this.Width + cmt.width) / this.duration;
        }
        /** 弹幕结束时间 **/
        private function getEnd(cmt:Comment):Number
        {
            return cmt.stime + (this.Width + cmt.width) / this.getSpeed(cmt);
        }
        /** 弹幕抵左边线时间 **/
        private function getMiddle(cmt:Comment):Number
        {
            return cmt.stime + this.Width / this.getSpeed(cmt);
        }
    }
}