package org.lala.event
{
    import flash.events.Event;
    /** 播放器事件管道中流动的事件类 **/
    public class MukioEvent extends Event
    {
        /** 数据将被送到服务器 **/
        public static var SEND:String = 'send';
        /** 数据将被送到显示者 **/
        public static var DISPLAY:String = 'display';
        /** 日志数据 **/
        public static var LOG:String = 'log';
        
        private var _data:Object;
        public function MukioEvent(type:String, d:Object, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            _data = d;
            super(type, bubbles, cancelable);
        }
        public function get data():Object
        {
            return _data;
        }
        
    }
}