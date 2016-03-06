package org.lala.utils
{
    import flash.display.DisplayObject;

    /** 应用程序配置,从外部xml文件加载 **/
    public class CommentXMLConfig
    {
        private var _xml:XML;
        /** 加载地址 **/
		public var _load:String;
		public var _send:String;
		public var _onHost:String;
		public var _gateway:String;
		public var _rtmp:String;
		public var _videoServer:String; //自解析
		public var _sina:String;
		public var _root:DisplayObject;
        public function CommentXMLConfig(_r:DisplayObject)
        {
            _root = _r;
        }
        
        public function init(xml:XML):void
        {
            _xml = xml;
            _load = _xml.server.load;
            _send = _xml.server.send;
			_sina = _xml.server.sina;
			_videoServer = _xml.server.youku;
            _gateway = _xml.server.gateway;
            _onHost = _xml.server.onhost;
			_rtmp = String(_xml.server.rtmp);
            // ...
        }
        public function get initialized():Boolean
        {
            if(_xml)
            {
                return true;
            }
            return false;
        }
        public function getCommentFileURL(id:String):String
        {
            var result:String = _load.replace(/\{\$id\}/ig,id);
            var random:String = 'r=' + Math.ceil(Math.random() * 1000);
            if(result.lastIndexOf('?') == -1)
            {
                result += '?' + random;
            }
            else
            {
                result += '&' + random;
            }
            return result;
        }
        public function getCommentPostURL(id:String):String
        {
            return _send.replace(/\{\$id\}/ig,id);
        }
		public function getSinaURL(id:String):String
		{
			return _sina.replace(/\{\$id\}/ig,id);
		}
		public function getSelfURL(id:String):String
		{
			return _videoServer.replace(/\{\$id\}/ig,id);
		}
		public function get selfURL():String
		{
			return _videoServer;
		}
        public function get playerURL():String
        {
            return _root.loaderInfo.url;
        }
		
		/** 使用自己的配置文件名 **/
        public function getConfURL(fileName:String='conf.xml'):String
        {
            return playerURL.replace(/[^\/]+.swf.*/igm,'') + fileName;
        }

        /** amf网关 **/
        public function get gateway():String
        {
            return _gateway;
        }
        /** 使用mukioplayer规定的参数来路由 **/
        public function get isOnHost():Boolean
        {
            return _onHost.length != 0;
        }
		/** 消息服务器 **/
		public function get rtmp():String
		{
			return _rtmp;
		}


    }
}