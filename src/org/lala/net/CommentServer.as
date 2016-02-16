package org.lala.net
{
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.NetConnection;
    import flash.net.ObjectEncoding;
    import flash.net.Responder;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    
    import org.lala.event.EventBus;
    import org.lala.event.MukioEvent;
    import org.lala.utils.CommentDataParser;
    import org.lala.utils.CommentXMLConfig;
    
    /** 
    * 处理向服务器发送弹幕消息
    * 从服务器的Amf加载弹幕
    * 普通的弹幕文件加载在provider中,因为实现得比较早
    * @author aristotle9
    **/
    public class CommentServer extends EventDispatcher
    {
        private var _user:String;
        private var _cid:String;
        private var _conf:CommentXMLConfig;
        private var _gateway:String;
        private var _postServer:String;
        private var _postLoader:URLLoader;
        private var _dataServer:NetConnection;
        private var _responderPut:flash.net.Responder;
        private var _responderGet:flash.net.Responder;
        private var _dispathHandle:Function;
		
		private var _fmsDispatcher:FMSDispatcher = null;
		private var _rtmp:String;

        public function CommentServer(target:IEventDispatcher=null)
        {
            _user = 'test';
            EventBus.getInstance().addEventListener(MukioEvent.SEND,sendHandler);
            
            _postLoader = new URLLoader();
            _postLoader.addEventListener(Event.COMPLETE,postLoader_CompleteHandler);
            _postLoader.addEventListener(IOErrorEvent.IO_ERROR,postLoader_ErrorHandler);
            _postLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,postLoader_ErrorHandler);
            
            super(target);
        }
        
        /** 当接收到SEND消息后 **/
        private function sendHandler(event:MukioEvent):void
        {
            /**
            * item的格式在EventBus中以及弹幕输入类Input中可查
            **/
            var item:Object = event.data;
            var data:Object;
            item.user = _user;
            if(_dataServer)
            {
                log("使用AMF发送");
                data = CommentDataParser.data_format(item);
                _dataServer.call('CmtAmfService.putCmt',_responderPut,data,_cid);
            }
            else if(_postServer)
            {
                log("使用POST发送");
                data = CommentDataParser.data_format(item);
                var postVariables:URLVariables = new URLVariables();
                for(var k:String in data)
                {
                    postVariables[k] = data[k];
                }
                postVariables["cid"] = _cid;
                var request:URLRequest = new URLRequest(_postServer);
                request.method = 'POST';
                request.data = postVariables;
                _postLoader.load(request);
            }
            else
            {
                log("无法发送弹幕,服务器配置不正确.");
                EventBus.getInstance().removeEventListener(MukioEvent.SEND,sendHandler);
            }
			if(_fmsDispatcher)
			{
				_fmsDispatcher.sendData(item);
			}
        }
        private function postLoader_CompleteHandler(event:Event):void
        {
            log('POST Complete:' + String(event.target.data));   
        }
        private function postLoader_ErrorHandler(event:Event):void
        {
            log("POST Error:" + event.toString());
        }
        private function remotePutHandler(result:*):void
        {
            log('remotePutHandler:'+JSON.stringify(result));
        }
        private function remoteGetHandler(result:*):void
        {
            var items:Array = result as Array;
            CommentDataParser.data_parse(items,_dispathHandle);
        }
        private function remoteError(e:*):void
        {
            log('remoteError:'+JSON.stringify(e));
        }
        private function get cid():String
        {
            return _cid;
        }

        public function set cid(value:String):void
        {
            _cid = value;
            _postServer = _conf.getCommentPostURL(_cid);
			if(rtmp != "" && _cid != null)
			{
				_fmsDispatcher = new FMSDispatcher(rtmp + '/');
				_fmsDispatcher.addEventListener("newCmtData", rtmpNewCmtDataHandler);
			}
        }
        
        private function log(message:String):void
        {
            EventBus.getInstance().log(message);
        }

        private function get gateway():String
        {
            return _gateway;
        }
        public function getCmts(foo:Function):void
        {
            if(!_dataServer)
            {
                log('服务器未连接,无法取得弹幕块.');
                return;
            }
            _dispathHandle = foo;
            _dataServer.call('CmtAmfService.getCmts',_responderGet,_cid);
        }
        private function set gateway(value:String):void
        {
            _gateway = value;
            if(_gateway == '')
            {
                log('服务器网关为空,取消连接操作.');
                return;
            }
            try
            {
                _dataServer = new NetConnection();
                _dataServer.objectEncoding = ObjectEncoding.AMF3;
                _dataServer.connect(_gateway);
                _responderPut = new flash.net.Responder(remotePutHandler,remoteError);
                _responderGet = new flash.net.Responder(remoteGetHandler,remoteError);
                log('与服务器连接完毕');
            }
            catch(error:Error)
            {
                log('与服务器连接遇到问题:\n' +
                    '_gateway:' + _gateway + '\n'
                    +error);
            }
        }
        /**
        * post提交的url
        * 收到需要发送的数据时,先检测_dataServer是否赋值,如果是,则用_gateway进行postamf提交
        * 如果没有赋值,则检测_postServer是否赋值,如果是,则用post表单提交
        **/
        private function get postServer():String
        {
            return _postServer;
        }

        private function set postServer(value:String):void
        {
            _postServer = value;
        }

        public function set conf(value:CommentXMLConfig):void
        {
            _conf = value;
            gateway = _conf.gateway;
			rtmp = value.rtmp;
        }

        public function get user():String
        {
            return _user;
        }

        public function set user(value:String):void
        {
            _user = value;
        }

		public function get rtmp():String
		{
			return _rtmp;
		}

		public function set rtmp(value:String):void
		{
			_rtmp = value;
			
			if(rtmp != "" && _cid != null)
			{
				_fmsDispatcher = new FMSDispatcher(rtmp + '/');
				_fmsDispatcher.addEventListener("newCmtData", rtmpNewCmtDataHandler);
			}
		}
		
		private function rtmpNewCmtDataHandler(event:MukioEvent):void
		{
			delete event.data.border;
			event.data.rtmp = true; //增加来自RTMP的Tag
			EventBus.getInstance().sendMukioEvent("displayRtmp", event.data);
		}


    }
}