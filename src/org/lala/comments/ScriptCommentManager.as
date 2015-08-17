package org.lala.comments
{
    import flash.display.Sprite;
    
    import org.lala.event.CommentDataEvent;
    
    /**
    * 脚本弹幕管理者
    * @date 2011年5月27日
    * @author aristotle9
    **/
    public class ScriptCommentManager extends CommentManager
    {
        /** 构造函数 **/
        public function ScriptCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 开始播放一个弹幕,脚本的播放方式与一般数据弹幕不同,必须完全修改
         * @param	data 弹幕数据信息
         */
        override protected function start(data:Object):void
        {
            /** 
            * data['on']符号的设置是无力的,不能在外部判断脚本何时会停,
            * 也不能让用户来做这件事
            * 脚本的执行是阻塞的,但是如果在脚本中启用事件钩子方法的话就不这样了
            * 一个不经意的seek可能会让一个钩子挂两次
            * 所以必须在脚本的接口上下点工夫,姑且这么写
            **/
            data['on'] = true;
            try
            {
                MukioEngine.exec(data.text);
            }
            catch(e:*)
            {
                MukioEngine.log(e);
            }
            this.complete(data);//data['on'] = false;
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
            this.mode_list.push(CommentDataEvent.ECMA3_SCRIPT);
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
            return null;
        }
    }
}