package org.lala.media
{
	
    import flash.events.*;
    import flash.media.*;
    import flash.net.*;
    import flash.utils.Timer;
    
    public class NS extends EventDispatcher
    {
        private var _$id:uint;
        private var _$stopSign:Boolean;
        private var _$bufferTime:uint;
        private var _$nc:NetConnection;
        private var _$ns:NetStream;
        private var _$is_hc:Boolean;
        private var _$isStop:Boolean;
        private var _$volume:Number = 0.7;
        private var _$btimer:Timer = new Timer(1000);
        private var _$ptimer:Timer = new Timer(100);
        private var _$isLoad:Boolean = false;

        public function NS(bufferTime:uint = 5) : void
        {
            _$bufferTime = bufferTime;
            init();
            return;
        }// end function
      
        private function init() : void
        {
            this.addEventListener(NSEvent.CHECK_FULL,onReallyFull)
            _$btimer.addEventListener(TimerEvent.TIMER,checkBuff)
            _$ptimer.addEventListener(TimerEvent.TIMER,onPlaying)
            _$nc = new NetConnection();
            _$nc.addEventListener(NetStatusEvent.NET_STATUS, ncStatus);
            _$nc.connect(null);
            return;
        }// end function

    private function onPlaying(eve:TimerEvent):void
    {
      dispatchEvent(new NSEvent(NSEvent.PLAYING,this.time));
    }
    private function checkBuff(eve:TimerEvent):void
    {   //trace(this.loadPercent)
        dispatchEvent(new NSEvent(NSEvent.BUFFERING,this.loadPercent));
    	if(this.loadPercent == 1)
    	{
    		trace("really full!")
    		dispatchEvent(new NSEvent(NSEvent.CHECK_FULL));
    		this.removeEventListener(TimerEvent.TIMER,checkBuff);
    		this._$btimer.stop();
    		this._$isLoad = true
    	}
    }

    private function ncStatus(param1:NetStatusEvent) : void
        {
            if (param1.info.code == "NetConnection.Connect.Success")
            {
                createNS();
            }// end if
            return;
        }// end function
        private function createNS() : void
        {
            _$ns = new NetStream(_$nc);
            _$ns.bufferTime = _$bufferTime;
            _$ns.client = this;
            setVolume();
            removeEvent(_$ns);
            addEvent(_$ns);
            return;
        }// end function

     public function set id(param1:uint) : void
        {
            _$id = param1;
            return;
        }// end function

        public function stopV() : void
        {
            _$ptimer.stop();
            _$btimer.stop();
            _$ns.pause();
            _$ns.seek(0);
            return;
        }// end function


        public function closeV() : void
        {   _$ptimer.stop();
            _$btimer.stop();
            _$ns.pause();
            _$ns.close();
            return;
        }// end function

        public function pauseV() : void
        {
            _$ptimer.stop();
            _$ns.pause();
            return;
        }// end function

        public function get volume() : Number
        {
            return _$volume;
        }// end function

        private function setVolume(param1:Number = 0.7) : void
        {
            _$volume = param1;
            var st:SoundTransform = new SoundTransform(_$volume, 0);
            _$ns.soundTransform = st;
            return;
        }// end function

        public function seekV(param1:Number) : void
        {
            param1 = Math.floor(param1 / 1000);
            _$ns.seek(param1);
            return;
        }// end function

        public function playV() : void
        {
            _$ptimer.start();
           if(!_$isLoad)
             _$btimer.start();
            _$isStop = false;
            _$ns.resume();
            return;
        }// end function



        private function asyncHandler(param1:AsyncErrorEvent) : void
        {
            trace("AsyncErrorEvent::" + param1.type);
            return;
        }// end function

     /*  public function attachVideo(param1:MyVideo) : void
        {
            param1.attachNetStream(_$ns);
            return;
        }// end function*/

        public function loadV(param1:String) : void
        {
           
            var path:String = param1;
           _$isStop = false;
           _$is_hc = false;
           _$stopSign = false;
            try
            {
                _$ns.play(path);
            }// end try
            catch (e:Error)
            {
                trace(e);
            }// end catch
            _$ns.pause();
           this._$btimer.start()
            return;
        }// end function


        private function addEvent(dispather:NetStream) : void
        {
        	dispather.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
            dispather.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncHandler);
            return;
        }// end function
        private function removeEvent(param1:NetStream) : void
        {
            param1.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
            param1.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncHandler);
            return;
        }// end function

        private function statusHandler(param1:NetStatusEvent) : void
        {
            var loadPercent:Number;
            var  info:String = param1.info.code;
           // trace("stream state�? + info);
            switch(info)
            {
                case "NetStream.Play.Start":
                {
                    dispatchEvent(new NSEvent(NSEvent.READY));
                    break;
                }// end case
                case "NetStream.Play.Stop": //break playing
                {
                    if (!_$isStop)//is playing
                    {
                        _$isStop = true;
                        trace("stopStop");
                        dispatchEvent(new NSEvent(NSEvent.STOP));
                    }// end if
                    break;
                }// end case
               case "NetStream.Buffer.Empty":
                {
                    if (_$stopSign)// is buffer flushed
                    {
                        if (!_$isStop)//is playing
                        {
                            _$isStop = true;//stopped
                            trace("emptyStop");
                            dispatchEvent(new NSEvent(NSEvent.STOP));
                        }// end if
                    }
                    else //it's not really the end..wait for buffering...
                    {   //currentloaded/prepare
                        loadPercent = Math.round(_$ns.bufferLength / _$ns.bufferTime * 100) / 100;
                        dispatchEvent(new NSEvent(NSEvent.EMPTY, loadPercent));
                    }// end else if
                    break;
                }// end case
                case "NetStream.Buffer.Full":
                {
                    if (!_$is_hc)
                    {
                        _$is_hc = true;//firsttime start playing?
                        dispatchEvent(new NSEvent(NSEvent.PLAY));
                    }
                    else
                    {
                        dispatchEvent(new NSEvent(NSEvent.FULL));
                    }// end else if
                    break;
                }// end case
                case "NetStream.Buffer.Flush":
                {   //buffer will be clear
                    if (!_$stopSign) //set buffer stop sign
                    {
                       _$stopSign = true;
                    }// end if
                    dispatchEvent(new NSEvent(NSEvent.FLUSH));
                    break;
                }// end case
                case "NetStream.Play.StreamNotFound":
                {
                    trace("StreamNotFound");
                    dispatchEvent(new NSEvent(NSEvent.FILE_EMPTY));
                    break;
                }// end case
                case "NetStream.Seek.Notify":
                {   
                	//seek completed set is flush false
                    _$stopSign = false;
                    break;
                }// end case
                case "NetStream.Seek.Failed":
                {
                    break;
                }// end case
                case "NetStream.Seek.InvalidTime":
                {
                    dispatchEvent(new NSEvent(NSEvent.SEEK_ERROR));
                    break;
                }// end case
                default:
                {
                    break;
                }// end default
            }// end switch
            return;
        }// end function


        public function get ns() : NetStream
        {
            return _$ns;
        }// end function

        public function get loadPercent() : Number
        {
            return _$ns.bytesLoaded / _$ns.bytesTotal;
        }// end function

        public function get total() : Number
        {
            return _$ns.bytesTotal;
        }// end function

        public function get loaded() : Number
        {
            return _$ns.bytesLoaded;
        }// end function

        public function get time() : Number
        {
            var time:uint = Math.round(_$ns.time * 1000);
            return time;
        }// end function*/
        public function set volume(param1:Number) : void
        {
            param1 = param1 > 1 ? (1) : (param1);
            param1 = param1 < 0 ? (0) : (param1);
            setVolume(param1);
            return;
        }// end function

        public function get id() : uint
        {
            return _$id;
        }// end function
        public function get bufferTime() : int
        {
            return _$bufferTime;
        }// end function
        public function set bufferTime(param1:int) : void
        {
           
            _$bufferTime = param1;
            _$ns.bufferTime = param1;
            return;
        }// end function
        public function onMetaData(param1:Object) : void
        {
            dispatchEvent(new NSEvent(NSEvent.META_DATA, param1));
            return;
        }// end function
        public function onCuePoint(param1:Object) : void
        {
            trace("cue point" + param1);
            return;
        }// end function
        public function onLastSecond(param1:Object):void
        {
         trace("last second" + param1);
        }
        public function onReallyFull(param1:NSEvent):void
        {
        	this._$btimer.stop()
        }
        public function onXMPData(... rest):void {
//            forward(rest[0], 'xmp');
        }

     }
} 