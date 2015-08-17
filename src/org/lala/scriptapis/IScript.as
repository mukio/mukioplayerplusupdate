package org.lala.scriptapis
{
    /**
    * 脚本类接口,用于包装播放器类提交给脚本引擎
    * 所有类必须是原生的,绝对不能从
    * flash的类中派生
    * @author aristotle9
    **/
    public interface IScript
    {
        /** 显示类的帮助信息 **/
        function get help():String;
    }
}