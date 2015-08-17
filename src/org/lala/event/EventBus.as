package org.lala.event
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import org.lala.plugins.CommentView;
    import org.lala.utils.CommentDataParser;

    /**
    * 弹幕播放器弹幕相关事件管道
    * @author aristotle9
    **/
    [Event(name="send",type="org.lala.event.MukioEvent")]
    [Event(name="display",type="org.lala.event.MukioEvent")]
    [Event(name="log",type="org.lala.event.MukioEvent")]
	[Event(name="displayRtmp", type="org.lala.event.MukioEvent")]
    public class EventBus extends EventDispatcher
    {
        private static var instance:EventBus;
        
        private var hasLogListener:Boolean = false;
        private var logsBeforeListener:Array = [];
        
        public function EventBus(target:IEventDispatcher=null)
        {
            if(instance != null)
            {
                throw new Error("please use getInstance() method.");
            }
        }
        public static function getInstance():EventBus
        {
            if(instance == null)
            {
                instance = new EventBus();
            }
            return instance;
        }
        public function sendMukioEvent(type:String,data:Object):void
        {
            if(type == MukioEvent.DISPLAY)
            {
                data = displayHook(data);
            }
            if(type == MukioEvent.LOG && !hasLogListener)
            {
                pushLog(new MukioEvent(type,data));
                return;
            }
            if(data)
            {
                dispatchEvent(new MukioEvent(type,data));
            }
        }
        /**
        * 显示弹幕数据预处理
        **/
        private function displayHook(data:Object):Object
        {
            var a:Array = String(data.text).match(/^script:(.*)/ism);
            if(a)
            {
                //可以在其他弹幕输入面板中输入脚本弹幕
                //只要在内容前加上script:前缀
                //没有预览功能的面板则直接将弹幕放入弹幕库中
                data.type = 'script';
                data.text = a[1];
                data.mode = '10';
            }
            if(data.type == 'normal')
            {
                
                var sizeTable:Object={
                    'middle':25,  
                    'small':13,  
                    'big':27
                };
                var modeTable:Object={
                    'toLeft':CommentDataEvent.FLOW_RIGHT_TO_LEFT,
                        'bottom':CommentDataEvent.BOTTOM,
                        'top':CommentDataEvent.TOP
                };
                var parseResult:Object = parse(data.text);
                if(!parseResult.ret)
                {
                    data.text = parseResult.text;
                }
                if(int(data.size) == 0)
                {
                    data.size = sizeTable[data.size];
                }
                data.mode = modeTable[data.mode];
                data.msg = data.mode;
            }
            else if(data.type == 'zoome')
            {
                data.msg = data.style + data.position;
            }
            else if(data.type == 'bili')
            {
                data.msg = data.mode;
            }
            else if(data.type == 'script')
            {
                data.msg = data.mode;
            }
            else
            {
                return data;
            }
            data.border = true;
            data.stime = CommentView.getInstance().stime;
            data.date = CommentDataParser.date();
            
            //填充好后准备发送,不发送预览弹幕
            if(!data.preview)
            {
                EventBus.getInstance().sendMukioEvent(MukioEvent.SEND,data);
            }
            return data;
        }
        /**
        * 文本命令解析
        * @return ret true表示没有特殊处理
        **/
        private function parse(text:String):Object
        {
            var result:Object={ret:true,text:text};
            return result;
        }
        /**
        * 日志显示
        */
        public function log(message:String):void
        {
            sendMukioEvent(MukioEvent.LOG,message);
        }
        /**
        * 重载,在有log监听器之保存所有log,第一个监听器连接上时dump所有log事件
        * 因Flex界面创建机制,在输出器创建之前的log无法监听到
        * 只为第一个监听器保存,当然本应用程序中只有一个log事件监听者
        **/
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
        {
            super.addEventListener(type, listener, useCapture, priority, useWeakReference);
            if(hasLogListener == false && type == MukioEvent.LOG)
            {
                hasLogListener = true;
                dumpLogs();
            }
        }
        private function pushLog(logEvent:MukioEvent):void
        {
            logsBeforeListener.push(logEvent);
        }
        private function dumpLogs():void
        {
            while(logsBeforeListener.length)
            {
                dispatchEvent(logsBeforeListener.shift());
            }
        }
    }
}