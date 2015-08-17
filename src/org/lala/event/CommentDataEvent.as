package org.lala.event
{
    import flash.events.Event;
    
    public class CommentDataEvent extends Event
    {
        /** 从右往左的滚动弹幕,值为模式号的字符串 **/
        public static var FLOW_RIGHT_TO_LEFT:String = '1';
        /** 从左往右的滚动弹幕 **/
        public static var FLOW_LEFT_TO_RIGHT:String = '6';
        /** 顶部字幕 **/
        public static var TOP:String = '5';
        /** 底部字幕 **/
        public static var BOTTOM:String = '4';
        /** bilibili新字幕 **/
        public static var FIXED_POSITION_AND_FADE:String = '7';
        /** 脚本弹幕 **/
        public static var ECMA3_SCRIPT:String = '10';
        
        public static var ZOOME_NORMAL:String = 'normal';//zoome style
        public static var ZOOME_THINK:String = 'think';//zoome style
        public static var ZOOME_LOUD:String = 'loud';//zoome style
        public static var ZOOME_BOTTOM_SUBTITLE:String = 'subtitlebottom';//zoome style
        public static var ZOOME_TOP_SUBTITLE:String = 'subtitletop';//zoome style
        
        /** 清空管理者中的数据 **/
        public static var CLEAR:String = 'clear';
        
        private var _data:Object;
        public function CommentDataEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this._data = data;
        }
        
        public function get data():Object
        {
            return this._data;
        }
    }
    
}