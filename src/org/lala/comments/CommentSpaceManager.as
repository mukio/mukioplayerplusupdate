package org.lala.comments
{
    import org.lala.utils.CommentConfig;

    /**
    * 弹幕占用视觉空间管理分配类,本身实现线性空间管理
    * @author aristotle9
    **/
    public class CommentSpaceManager
    {
        /** 层数列 **/
        protected var Pools:Array = [];
        /** 宽度 **/
        protected var Width:int;
        /** 高度 **/
        protected var Height:int;
        /** 配置 **/
        protected var config:CommentConfig = CommentConfig.getInstance();
        
        public function CommentSpaceManager()
        {
        }
        /**
        * 设置宽度高度参数
        * @param w 宽度
        * @param h 高度
        **/
        public function setRectangle(w:int,h:int):void
        {
            this.Width = w;
            this.Height = h;
        }
        /** 添加弹幕到空间,重点在于设置x,y值 **/
        public function add(cmt:Comment):void
        {
            cmt.x = (this.Width - cmt.width) / 2;
            if(cmt.height >= this.Height)
            {
                cmt.setY(0,-1,transformY);
            }
            else
            {
                /** 进入高级y坐标确定 **/
                this.setY(cmt);   
            }
        }
        /** 复杂一点的y坐标确定 **/
        protected function setY(cmt:Comment,index:int = 0):void
        {
            /** 临时y坐标 **/
            var y:int = 0;
            if(this.Pools.length <= index)
            {
                this.Pools.push(new Array());
            }
            var pool:Array = this.Pools[index];
            if(pool.length == 0)
            {
                cmt.setY(0,index,transformY);
                pool.push(cmt);
                return;
            }
            if(this.vCheck(0,cmt,index))
            {
                cmt.setY(0,index,transformY);
                CommentManager.binsert(pool,cmt,bottom_cmp);
                return;
            }
            for each(var c:Comment in pool)
            {
                y = c.bottom + 1;
                if(y + cmt.height > this.Height)
                {
                    break;
                }
                if(this.vCheck(y,cmt,index))
                {
                    cmt.setY(y,index,transformY);
                    CommentManager.binsert(pool,cmt,bottom_cmp);
                    return;
                }
            }
            this.setY(cmt,index + 1);
            
        }
        /** y坐标转换函数(id) **/
        protected function transformY(y:int,cmt:Comment):int
        {
            return y;
        }
        /** 底部排序比较函数 **/
        protected function bottom_cmp(a:Comment,b:Comment):int
        {
            if(a.bottom < b.bottom)
            {
                return -1;
            }
            else if(a.bottom == b.bottom)
            {
                return 0;
            } 
            else 
            {
                return 1;
            }
        }
        /** 碰撞检测 **/
        protected function vCheck(y:int,cmt:Comment,index:int):Boolean
        {
            var bottom:int = y + cmt.height;
            for each(var c:Comment in this.Pools[index])
            {
                if(c.y > bottom || c.bottom < y)
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
        /**
        * 移除函数
        */
        public function remove(cmt:Comment):void
        {
            if(cmt.index != -1)
            {
                var pool:Array = this.Pools[cmt.index];
                var n:int = pool.indexOf(cmt);
                pool.splice(n,1);
            }
        }
    }
}