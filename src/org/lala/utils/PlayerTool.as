package org.lala.utils
{
   
    import com.longtailvideo.jwplayer.player.Player;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.xml.*;
    
    import org.lala.event.EventBus;
    import org.lala.net.CommentServer;
    import org.lala.plugins.CommentView;
    import org.lala.utils.CommentConfig;
	
	
    /** 
    * 播放器常用方法集
    * 播放sina视频可以直接调用Player的load方法,因为有SinaMediaProvider
    * 但是播放youku视频要借用SinaMediaProvider,
    * 此外还要对视频信息作解析,这些任务顺序可能较为复杂,因此放在该类中,保证主文件的清洁
    * @author aristotle9
    **/
    public class PlayerTool extends EventDispatcher
    {
        /** 所辅助控制的播放器的引用 **/
        private var _player:Player;
        /** 所辅助控制的弹幕插件的引用,主要用来加载弹幕文件 **/
        private var _commentView:CommentView;
		
		private var youku:CommentXMLConfig;
		
        [Bindable]
        private var config:CommentConfig = CommentConfig.getInstance();
		
		//
		
        public function PlayerTool(p:Player,target:IEventDispatcher=null)
        {
            _player = p;
            _commentView = CommentView.getInstance();
            super(target);
        }
        //SinaMediaProvider测试
        //_player.load({type:'youtube',file:'YQHsXMglC9A'});
        //player.load({type:'sina',file:'25550133'});
        //player.load({type:'sina',file:'singleFileTest',videoInfo:{length:0,items:[{url:'E:\\acfun\\badapple.flv',length:0}]}});
        //player.load({type:'sina',file:'singleFileTest',videoInfo:{length:347000,items:[{url:'E:\\acfun\\badapple.flv',length:218000},
        //{url:'E:\\acfun\\我哥在光腚.flv',length:129000}]}});
        /**
        * 播放单个文件,借用SinaMediaProvider,因为控制逻辑与原有的MediaProvider有不同
        * @param url 视频文件的地址
        **/
        public function loadSingleFile(url:String):void
        {
           if( _player.load(
                {   type:'sina',
                    file:'videoInfo',
                    videoInfo:{length:0,
                                items:[
                                       {'url':url,length:0}
                                      ]
                              }
                }) == false ) log("载入视频列表失败");
        }
        /** 
        * 播放sina视频
        * @param vid sina视频的vid
        **/
        public function loadSinaVideo(vid:String):void
        {
            _player.load(
                {   type:'sina',
                    file:vid
                });
        }
		/** 
		 * 播放自己服务器视频
		 * @param vid 视频的vid
		 **/
		public function loadSelfVideo(vid:String):void
		{
			log("加载视频信息");
			_player.load(
				{   type:'sina',
					file:'self' + vid //判断到底是什么传入的
				});
		}
		/** 
		 * 播放Youtube视频
		 * @param vid 视频的vid
		 **/
		public function loadYoutubeVideo(vid:String):void
		{
			log("加载视频信息");
		_player.load(
				{   type:'youtube',
					streamer: vid //返回Youtube的视频ID，可以是URL
				});
		}
		/** 
		 * 播放RTMP直播流
		 * @param vid 视频的vid
		 **/
		public function loadRTMPVideo(vid:String, cid:String ):void
		{
			log("加载视频信息");
			_player.load(
				{   type:'rtmp',
					file: cid,
					streamer: vid //返回Youtube的视频ID，可以是URL
				});
		}
        /**
        * 加载一般弹幕文件
        * @params url 弹幕文件地址
        **/
        public function loadCmtFile(url:String):void
        {
            _commentView.loadComment(url);
        }
        /**
        * 加载AMF弹幕文件
        * @params server 弹幕服务器
        **/
        public function loadCmtData(server:CommentServer):void
        {
            _commentView.provider.load('',CommentFormat.AMFCMT,server);
        }
        //以下两个函数在代理测试时使用        
        /**
        * 加载bili弹幕文件
        * @params cid 弹幕id
        **/
        public function loadBiliFile(cid:String):void
        {
            loadCmtFile('http://www.bilibili.us/dm,' + cid + '?r=' + Math.ceil(Math.random() * 1000));
        }
        /**
        * 加载acfun弹幕文件
        * @params cid 弹幕id
        **/
        public function loadAcfunFile(cid:String):void
        {
            loadCmtFile('http://124.228.254.234/newflvplayer/xmldata/' + cid + '/comment_on.xml?r=' + Math.random());
        }
        private function log(message:String):void
        {
            EventBus.getInstance().log(message);
        }
    }
}