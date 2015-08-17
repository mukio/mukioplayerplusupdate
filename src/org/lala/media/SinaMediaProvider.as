package org.lala.media
{
	import com.adobe.crypto.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

    /**
    * jwplayer5的新浪视频播放模块
    * 可以用作其他单,多段视频播放模块的原型(使用playItems方法)
    * 由mukioplayer的jwplayer4的相应文件更改而来,最初的原型参照PADPlayer Project@tamaki
    * @author aristotle9
    **/
	public class SinaMediaProvider extends MediaProvider {
        /** 视频,显示者 **/
        protected var video:Video;
        /** 音量,0-1 **/
        protected var vol:Number;
        
        /** NS(网络流)数组,一个NS对应一段视频,即一个网络上的视频文件 **/
        protected var nss:Array=[];
        /** 辅助数组,每段视频的偏移值 **/
        protected var ofs:Array=[];
        /** 视频信息数组,每项的重要数据有视频文件url,视频长度 **/
        protected var ifs:Array=[];
        /** 当前缓冲段索引 **/
        protected var bi:int=-1;
        /** 当前播放段索引 **/
        protected var pi:int=-1;
        
        /** 总长度,毫秒 **/
        protected var totle:int;
        /** 模块状态信息,内部使用 **/
        protected var status:String;
        
		
        /** 构造函数 **/
		public function SinaMediaProvider() {
			super('sina');
		}

        /** 插件初始化,在此可以使用播放器的配置了 **/
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
            
            // 初始化视频显示者
            video = new Video();
            //是否反锯齿
            video.smoothing = config.smoothing;
            //音量,把配置文件中的音量0-100,转换为0-1
            vol = config.mute ? 0 : config.volume / 100;
            //显示者,视频的显示问题至此结束
            media = video;
		}


		/**
		 * Load a new playlist item
		 * @param itm The playlistItem to load
		 **/
		public override function load(itm:PlaylistItem):void {
			_item = itm;
            /** videoInfo标志表示传进来的是videoInfo对象,跳过获取xml **/
            if(itm.file == 'videoInfo')
            {
                playeItems(itm.videoInfo);
            }
            else
			{
				//开始加载视频描述文件,sina api
				status = 'prepare';
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, xmlLoadHandler);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				if(itm.file.substr(0,4) == 'self')
				{
					var url:String = _item.file.substr(4);
					xmlLoader.load(new URLRequest(url));
				}
				else
				{    
					
					xmlLoader.load(new URLRequest(getXMLUrl(_item.file)));
				}
				
			}
			dispatchEvent(new MediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED));
		}
		/**渣浪编码函数**/
		public function sinaEncode(param1:Number):Number 
		{
			var _loc_2:String = param1.toString(2);                    //使用二进制表示传入数据
			var _loc_3:String = _loc_2.substring(0, _loc_2.length - 6);//取出文本从0~长度-6的值
			return parseInt(_loc_3, 2);    	//转换为十进制数据					  
		}
		
		/**
		 * 计算视频信息文件地址
		 **/
		protected function getXMLUrl(vid:String):String
		{
			var rand:Number =  Math.random();						
			var Date1:Date = new Date();
			var num1:Number = int( Date1.time / 1000);
			var num2:Number = sinaEncode( num1 );
			var str:String = vid.toString() +"Z6prk18aWxP278cVAH" + num2.toString() + rand.toString(); 
			var hash:String = MD5.hash(str);                                //hash
			var encode:String = hash.substr(0, 16).toString() + num2.toString();//截取0~16位hash值,加上编码数字		
			
			return "http://v.iask.com/v_play.php?vid="+ vid +"&p=i&ran="+ rand + "&k=" + encode+ "&r=video.sina.com.cn&v=4.1.43.10";
		}
        /**
        * 收到视频信息文件后
        **/
        protected function xmlLoadHandler(evt:Event):void
        {
            if (item['vid'] == '-1')
            {
                //新的显示错误信息方法
                error('使用方法: 见程序目录readme.txt');
                return;
            }
            try {
                var data:XML = XML(evt.target.data);
            }
            catch (e:Error)
            {
                error('播放地址出错了!');
                return;
            }
            
            var items:Array = [];
            for each(var itm:XML in data.descendants('durl'))
            {
                items.push({url:itm.url, length:parseInt(itm.length)});
            }
            
            var info:Object = {'length':parseInt(data.timelength),'items':items};
            
            if (!info.length)
            {
                error('视频出错了!');
                return;
            }
            
            playeItems(info);
        }	
        /**
        * 加载xml时的错误处理
        **/
        protected function ioErrorHandler(event:IOErrorEvent):void
        {
            error("加载视频信息出错");
        }
        /**
        * 播放模块本身定义的播放列表
        * @param videoInfo:{length:总长度(毫秒数),items:items}
        * items:{url:视频地址,length:视频长度}
        * 单个文件的播放是:
        * {
        * length:0,
        * items:[
        *        {
        *         url:fileurl,
        *         length:0
        *        }
        *       ]
        * }
        * 长度为零时会自动去metadata事件时填充,播放信息文件的合法性不在这里检验
        **/
        protected function playeItems(videoInfo:Object):void
        {
           totle = videoInfo.length;
           ifs = videoInfo.items;
           
           nss = [];
           ofs = [];
            
            var co:uint = 0;
            //计算偏移数组
            for(var i:uint = 0;i < ifs.length;i++)
            {
                ofs[i] = co += ifs[i].length;
            }
            pi = -1;
            bi = -1;
            
            item['duration'] = totle / 1000;
            //调用父方法,语义同下
            super.pause();
            //播放模块的内部状态设置
            status = 'ready';
            //加载完成后播放
            play();
            pause();
        }
            
        /** 创建buff数组,填充nss **/
        protected function createBuffer():void
        {
            if(ifs[++bi])
            {
//                trace("create buffer : " + bi);
                var ns:NS = new NS()
                
                
                ns.addEventListener(NSEvent.PLAYING, playingHandler);
                ns.addEventListener(NSEvent.BUFFERING, bufferingHandler);
                ns.addEventListener(NSEvent.CHECK_FULL, checkfullHandler);
                ns.addEventListener(NSEvent.STOP, stopHandler);
                if (bi == 0) ns.addEventListener(NSEvent.META_DATA,  metadataHandler);
                
                ns.id = ifs[bi].id 
                ns.volume = vol;
                
                ns.loadV(ifs[bi].url)
                nss.push(ns)
                return;
            }
//            trace('buffer all full');
        }
        /** 切换下一段播放 **/
        protected function changeNS():void
        {  
            if(pi >= 0)
            {
                if(!nss[pi])
                    return
                    getns(pi).stopV();
            } 
            
            if(nss[pi+1])
            {
//                trace("change ns : " + (pi+1));
                getns(++pi).playV();
                
                video.clear();
                video.attachNetStream(getns(pi).ns);
                
                getns(pi).stopV();
                getns(pi).playV();
                
            }
            
        }
		/** Resume playback of the item. **/
		public override function play():void {
            if (status == 'prepare')
            {
                return;
            }
            if (status == 'play')
            {
                return;
            }
            if (status == 'ready')
            {
                createBuffer();
                
                changeNS();
                //getns(pi).playV();
                
                status = 'play';
            }
            if (status == 'pause')
            {
                getns(pi).playV();
                status = 'play';
            }
			super.play();
		}
		
		
		/** Pause playback of the item. **/
		public override function pause():void {
            if (status == 'prepare')
            {
                return;
            }
            if (status == 'pause')
            {
                return;
            }
            if (status == 'play')
            {
                getns(pi).pauseV();
                
                status = 'pause';
            }
			super.pause();
		}


		/**
		 * Seek to a certain position in the item.
		 *
		 * @param pos	The position in seconds.
		 **/
		public override function seek(pos:Number):void {
            if (status == 'prepare')
            {
                return;
            }
			_position = pos;
            //			super.seek(pos);
            //			pos = Math.floor(pos);
            pos *= 1000;
            //trace("pos *= 1000 : " + pos);
            
            if (status == 'ready' || status == 'pause')
            {
                play();
                seek(_position);
                pause();
                return;
            }
            //trace("seek pos : " + pos);
            
            var si:int = getPIByTime(pos);
            
            if (si == pi)
            {
                seekInPart(pos, si);
                return;
            }
            if (si >= nss.length)
            {
//                trace("si >= nss.length : ");
                return;
            }
            for (var i:int = 0; i < nss.length; i++)
            {
                getns(i).stopV();
                //trace("getns(i).stopV() : ");
            }
            video.clear();
            //trace("video.clear() : ");
            pi = si;
            
            video.attachNetStream(getns(pi).ns);
            //trace("video.attachNetStream(getns(pi).ns) : ");
            seekInPart(pos, pi);
            //trace("seekInPart(pos, pi) : ");
            sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: _position, duration: totle/1000});
		}
        /** 收到元数据 **/
        protected function metadataHandler(evt:NSEvent):void
        {
            if (evt.info['width'])
            {
                video.width = evt.info['width'];
                video.height = evt.info['height'];
            }
            
            if(evt.info['duration'] && totle == 0)
            {
                _item['duration'] = parseFloat(evt.info.duration);
                totle = _item['duration'] * 1000;
                ifs[0].length = totle;
                ofs[0] = totle;
            }                
            resize(_width, _height);
            //trace("resize : ");
            sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: evt.info});
            getns(0).removeEventListener(NSEvent.META_DATA,  metadataHandler);
        }
        /** 缓冲状态 **/
        protected function bufferingHandler(evt:NSEvent):void
        {
            var next:Number;
            var current:Number;
            var pre:Number;
            if(bi == 0)
            {
                next = int(ofs[bi]) / totle;
                current = Number(evt.info) * next;
                //trace("current : " + current);
                sendBufferEvent(current * 100, 0, {loaded:current, total:1});
            }
            else
            {
                pre = int(ofs[bi - 1]) / totle;
                next = int(ofs[bi]) / totle;
                current = pre + Number(evt.info) * (next - pre);
                //trace("current : " + current);
                sendBufferEvent(current * 100, 0, {loaded:current, total:1});
            }
        }
        /** 段播放结束 **/
        protected function stopHandler(evt:NSEvent):void
        {
            if (pi != ifs.length -1)
            {
                changeNS();
                return;
            }
            
            //stop();
            for (var i:int = 0; i < nss.length; i++)
            {
                getns(i).stopV();
            }
            video.clear();
            
            pi = -1;
            changeNS();
            getns(pi).pauseV();
            pause();
            sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: 0, duration: totle/1000});
            //没有完成事件发送到外部,所以自行确定是否循环播放
            if(config.repeat == 'single')
            {
                play();
            }
//            事实上,stop的处理一直是个关键,按照jwplayer的一贯做法是摧毁视频,
//            如果要再次播放则重新缓冲,这在桌面播放器上是必须的
//            但是播放单一文件的网络播放器又不能如此,应该把视频存储在flash缓存中,而不是浏览器的缓存中
        }
        /** 缓冲完成后缓冲下一段 **/
        protected function checkfullHandler(evt:NSEvent):void
        {
            getns(bi).removeEventListener(NSEvent.BUFFERING, bufferingHandler);
            getns(bi).removeEventListener(NSEvent.CHECK_FULL, checkfullHandler);
            createBuffer();
        }
        /** 播放状态 **/
        protected function playingHandler(evt:NSEvent):void
        {
            var pos:Number = Math.round(getns(pi).ns.time*10)/10;
            var bfr:Number = getns(pi).ns.bufferLength / getns(pi).ns.bufferTime;
            //
            if(bfr < 0.5 && pos < ifs[pi].length - 10 && state != PlayerState.BUFFERING) {
                setState(PlayerState.BUFFERING);
            } else if (bfr > 1 && state != PlayerState.PLAYING) {
                setState(PlayerState.PLAYING);
            }
            if(state != PlayerState.PLAYING && state != PlayerState.BUFFERING)
            {
                return;
            }
            //
            //
            if (pi == 0)
            {
                _position = uint(evt.info) / 1000;
                sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: uint(evt.info) / 1000, duration: totle/1000});
            }
            else
            {
                _position = uint(parseInt(ofs[pi-1])+uint(evt.info)) / 1000;
                sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: uint(parseInt(ofs[pi - 1]) + uint(evt.info)) / 1000, duration: totle/1000});
            }
        }
		/** Stop playing and loading the item. **/
		public override function stop():void {
            if (status == 'prepare')
            {
                return;
            }
            if (state == 'pause' || state=='ready')
            {
                return;
            }
            if (state == 'play')
            {
                for (var i:int = 0; i < nss.length; i++)
                {
                    getns(i).stopV();
                    //trace("getns(i).stopV() : ");
                }
                video.clear();
                
                pi = -1;
                changeNS();
                pause();
                sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: 0, duration: totle/1000});
                
            }
//			super.stop();改变jw的默认行为
		}


		/**
		 * Change the playback volume of the item.
		 *
		 * @param vol	The new volume (0 to 100).
		 **/
		public override function setVolume(vl:Number):void {
            vol = vl / 100;
            for(var i:uint=0;i<nss.length;i++)
            {
                getns(i).volume = vol;
                //trace("=====>>vol : " + vol);
            }
			super.setVolume(vl);
		}
        /** 按索引取得NS **/
        protected function getns(i:int):NS
        {
            return NS(nss[i]);
        }
        /** 按时间取得段索引 **/
        protected function getPIByTime(time:Number):uint
        {   
            var i:uint = 0;
            var pre:Number = -1;
            for(;i<nss.length;)
            {
                //trace("nss.length : " + nss.length);
                if( time > pre && time <=  ofs[i])
                    break;
                pre =  ofs[i++];
            }
            //trace("i : " + i);
            return i;
        }
        /** 在段中seek **/
        protected function seekInPart(time:Number,si:uint):void
        {
            //trace("seekInPart time : " + time);
            var ptime:Number;
            if (si == 0)
                ptime = time;
            else
                ptime = time - ofs[si - 1];
            
            //trace("seekInPart ptime : " + ptime);
            
            pause();
            getns(pi).seekV(ptime);
            play();
        }

		/**
		 * Changes the mute state of the item.
		 *
		 * @param mute	The new mute state.
		 **/
		public override function mute(mute:Boolean):void {
			//TODO: Your code goes here
			super.mute(mute);
		}

		
		/**
		 * Resizes the display.
		 *
		 * @param width		The new width of the display.
		 * @param height	The new height of the display.
		 **/
		public override function resize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			//TODO: Your code goes here
			if (media) {
				Stretcher.stretch(media, width, height, config.stretching);
			}
		}


		/** Puts the video into a buffer state **/
		protected override function buffer():void {
			//TODO: Your code goes here
		}
		
		
		/** Completes video playback **/
		protected override function complete():void {
			//TODO: Your code goes here
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
		}
		
		
		/** Dispatches error notifications **/
		protected override function error(message:String):void {
			//TODO: Your code goes here
			super.stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: message});
		}
	}
}