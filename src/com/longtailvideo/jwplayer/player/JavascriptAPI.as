package com.longtailvideo.jwplayer.player {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.utils.JavascriptSerialization;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlayerComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class JavascriptAPI {
		protected var _player:IPlayer;
		protected var _playerBuffer:Number = 0;
		protected var _playerPosition:Number = 0;
		
		protected var _listeners:Object;
		protected var _queuedEvents:Array = [];

		
		public function JavascriptAPI(player:IPlayer) {
			_listeners = {};
			
			_player = player;
			_player.addEventListener(PlayerEvent.JWPLAYER_READY, playerReady);

			setupPlayerListeners();
			setupJSListeners();
			_player.addGlobalListener(queueEvents);
			
		}
		
		/** Delay the response to PlayerReady to allow the external interface to initialize in some browsers **/
		protected function playerReady(evt:PlayerEvent):void {
			var timer:Timer = new Timer(50, 1);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(timerEvent:TimerEvent):void {
				_player.removeGlobalListener(queueEvents);
				var callbacks:String = _player.config.playerready ? _player.config.playerready + "," + "playerReady" : "playerReady";  
				if (ExternalInterface.available) {
					for each (var callback:String in callbacks.replace(/\s/,"").split(",")) {
						try {
							ExternalInterface.call(callback,{
								id:evt.id,
								client:evt.client,
								version:evt.version
							});
						} catch (e:Error) {}
					}
					
					clearQueuedEvents();
				}
				

			});
			timer.start();
		}

		protected function queueEvents(evt:PlayerEvent):void {
			_queuedEvents.push(evt);
		}
		
		protected function clearQueuedEvents():void {
			for each (var queuedEvent:PlayerEvent in _queuedEvents) {
				listenerCallback(queuedEvent);
			}
			_queuedEvents = null;
		}
		
		protected function setupPlayerListeners():void {
			_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, resetPosition);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, updatePosition);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, updateBuffer);
		}
		
		protected function resetPosition(evt:PlaylistEvent):void {
			_playerPosition = 0;
			_playerBuffer = 0;
		}
		
		protected function updatePosition(evt:MediaEvent):void {
			_playerPosition = evt.position;
		}

		protected function updateBuffer(evt:MediaEvent):void {
			_playerBuffer = evt.bufferPercent;
		}

		protected function setupJSListeners():void {
			try {
				// Event handlers
				ExternalInterface.addCallback("jwAddEventListener", js_addEventListener);
				ExternalInterface.addCallback("jwRemoveEventListener", js_removeEventListener);
				
				// Getters
				ExternalInterface.addCallback("jwGetBuffer", js_getBuffer);
				ExternalInterface.addCallback("jwGetDuration", js_getDuration);
				ExternalInterface.addCallback("jwGetFullscreen", js_getFullscreen);
				ExternalInterface.addCallback("jwGetHeight", js_getHeight);
				ExternalInterface.addCallback("jwGetMute", js_getMute);
				ExternalInterface.addCallback("jwGetPlaylist", js_getPlaylist);
				ExternalInterface.addCallback("jwGetPlaylistIndex", js_getPlaylistIndex);
				ExternalInterface.addCallback("jwGetPosition", js_getPosition);
				ExternalInterface.addCallback("jwGetState", js_getState);
				ExternalInterface.addCallback("jwGetWidth", js_getWidth);
				ExternalInterface.addCallback("jwGetVersion", js_getVersion);
				ExternalInterface.addCallback("jwGetVolume", js_getVolume);

				// Player API Calls
				ExternalInterface.addCallback("jwPlay", js_play);
				ExternalInterface.addCallback("jwPause", js_pause);
				ExternalInterface.addCallback("jwStop", js_stop);
				ExternalInterface.addCallback("jwSeek", js_seek);
				ExternalInterface.addCallback("jwLoad", js_load);
				ExternalInterface.addCallback("jwPlaylistItem", js_playlistItem);
				ExternalInterface.addCallback("jwPlaylistNext", js_playlistNext);
				ExternalInterface.addCallback("jwPlaylistPrev", js_playlistPrev);
				ExternalInterface.addCallback("jwDockSetButton", js_dockSetButton);
				ExternalInterface.addCallback("jwSetMute", js_mute);
				ExternalInterface.addCallback("jwSetVolume", js_volume);
				ExternalInterface.addCallback("jwSetFullscreen", js_fullscreen);
				
				// Showing and hiding player controls.
				ExternalInterface.addCallback("jwShowControlbar", js_showControlbar);
				ExternalInterface.addCallback("jwHideControlbar", js_hideControlbar);
				ExternalInterface.addCallback("jwShowDock", js_showDock);
				ExternalInterface.addCallback("jwHideDock", js_hideDock);
				ExternalInterface.addCallback("jwShowDisplay", js_showDisplay);
				ExternalInterface.addCallback("jwHideDisplay", js_hideDisplay);

				// UNIMPLEMENTED
				//ExternalInterface.addCallback("jwGetBandwidth", js_getBandwidth); 
				//ExternalInterface.addCallback("jwGetLevel", js_getLevel);
				//ExternalInterface.addCallback("jwGetLockState", js_getLockState);
				
			} catch(e:Error) {
				Logger.log("Could not initialize JavaScript API: "  + e.message);
			}
			
		}

		
		/***********************************************
		 **              EVENT LISTENERS              **
		 ***********************************************/
		
		protected function js_addEventListener(eventType:String, callback:String):void {
			if (!_listeners[eventType]) {
				_listeners[eventType] = [];
				_player.addEventListener(eventType, listenerCallback);
			}
			(_listeners[eventType] as Array).push(callback);
		}
		
		protected function js_removeEventListener(eventType:String, callback:String):void {
			var callbacks:Array = _listeners[eventType];
			if (callbacks) {
				var callIndex:Number = callbacks.indexOf(callback);
				if (callIndex > -1) {
					callbacks.splice(callIndex, 1);
				}
			}
		}
		
		
		
		protected function listenerCallback(evt:PlayerEvent):void {
			var args:Object;
			
			if (evt is MediaEvent)
				args = listnerCallbackMedia(evt as MediaEvent);
			else if (evt is PlayerStateEvent)
				args = listenerCallbackState(evt as PlayerStateEvent);
			else if (evt is PlaylistEvent)
				args = listenerCallbackPlaylist(evt as PlaylistEvent);
			else if (evt is ViewEvent && (evt as ViewEvent).data != null)
				args = { data: JavascriptSerialization.stripDots((evt as ViewEvent).data) };
			else
				args = { message: evt.message };
			
			var callbacks:Array = _listeners[evt.type] as Array;
			
			//Insert 1ms delay to allow all Flash listeners to complete before notifying JavaScript
			setTimeout(function():void {
				if (callbacks) {
					for each (var call:String in callbacks) {
						ExternalInterface.call(call, args);
					}
				}
			}, 1);
			
		}
		
		protected function merge(obj1:Object, obj2:Object):Object {
			var newObj:Object = {};
			
			for (var key:String in obj1) {
				newObj[key] = obj1[key];
			}
			
			for (key in obj2) {
				newObj[key] = obj2[key];
			}
			
			return newObj;
		}
		
		protected function listnerCallbackMedia(evt:MediaEvent):Object {
			var returnObj:Object = {};

			if (evt.bufferPercent >= 0) 		returnObj.bufferPercent = evt.bufferPercent;
			if (evt.duration >= 0)		 		returnObj.duration = evt.duration;
			if (evt.message)					returnObj.message = evt.message;
			// todo: strip out 'name.properties' named properties
			if (evt.metadata != null)	 		returnObj.metadata = JavascriptSerialization.stripDots(evt.metadata);
			if (evt.offset > 0)					returnObj.offset = evt.offset;
			if (evt.position >= 0)				returnObj.position = evt.position;

			if (evt.type == MediaEvent.JWPLAYER_MEDIA_MUTE)
				returnObj.mute = evt.mute;
			
			if (evt.type == MediaEvent.JWPLAYER_MEDIA_VOLUME)
				returnObj.volume = evt.volume;

			return returnObj;
		}
		
		
		protected function listenerCallbackState(evt:PlayerStateEvent):Object {
			if (evt.type == PlayerStateEvent.JWPLAYER_PLAYER_STATE) {
				return { newstate: evt.newstate, oldstate: evt.oldstate };
			} else return {};
		}

		protected function listenerCallbackPlaylist(evt:PlaylistEvent):Object {
			if (evt.type == PlaylistEvent.JWPLAYER_PLAYLIST_LOADED) {
				var list:Array = JavascriptSerialization.playlistToArray(_player.playlist);
				list = JavascriptSerialization.stripDots(list) as Array;
				return { playlist: list };
			} else if (evt.type == PlaylistEvent.JWPLAYER_PLAYLIST_ITEM) {
				return { index: _player.playlist.currentIndex };
			} else return {};
		}

		/***********************************************
		 **                 GETTERS                   **
		 ***********************************************/
		
		protected function js_getBandwidth():Number {
			return _player.config.bandwidth;
		}

		protected function js_getBuffer():Number {
			return _playerBuffer;
		}
		
		protected function js_getDuration():Number {
			return _player.playlist.currentItem ? _player.playlist.currentItem.duration : 0;
		}
		
		protected function js_getFullscreen():Boolean {
			return _player.config.fullscreen;
		}

		protected function js_getHeight():Number {
			return RootReference.stage.stageHeight;
		}
		
		protected function js_getLevel():Number {
			return _player.playlist.currentItem ? _player.playlist.currentItem.currentLevel : 0;
		}
		
		protected function js_getLockState():Boolean {
			return _player.locked;
		}
		
		protected function js_getMute():Boolean {
			return _player.config.mute;
		}
		
		protected function js_getPlaylist():Array {
			var playlistArray:Array = JavascriptSerialization.playlistToArray(_player.playlist);
			for (var i:Number=0; i < playlistArray.length; i++) {
				playlistArray[i] = JavascriptSerialization.stripDots(playlistArray[i]);
			}
			return playlistArray; 
		}

		
		protected function js_getPlaylistIndex():Number {
			return _player.playlist.currentIndex; 
		}
		
		
		protected function js_getPosition():Number {
			return _playerPosition;
		}
		
		protected function js_getState():String {
			return _player.state;
		}

		protected function js_getWidth():Number {
			return RootReference.stage.stageWidth;
		}

		protected function js_getVersion():String {
			return _player.version;
		}

		protected function js_getVolume():Number {
			return _player.config.volume;
		}

		/***********************************************
		 **                 PLAYBACK                  **
		 ***********************************************/

		protected function js_dockSetButton(name:String,click:String=null,out:String=null,over:String=null):void {
		    _player.controls.dock.setButton(name,click,out,over);
		};
	
		protected function js_play(playstate:*=null):void {
			if (playstate == null){
				playToggle();
			} else {
				if (String(playstate).toLowerCase() == "true"){
					_player.play();
				} else {
					_player.pause();
				}
			}
		}
		
		
		protected function js_pause(playstate:*=null):void {
			if (playstate == null){
				playToggle();
			} else {
				if (String(playstate).toLowerCase() == "true"){
					_player.pause();
				} else {
					_player.play();	
				}
			}
		}
		
		protected function playToggle():void {
			if (_player.state == PlayerState.IDLE || _player.state == PlayerState.PAUSED) {
				_player.play();
			} else {
				_player.pause();
			}
		}
		
		protected function js_stop():void {
			_player.stop();
		}
		
		protected function js_seek(position:Number=0):void {
			_player.seek(position);
		}
		
		protected function js_load(toLoad:*):void {
			_player.load(toLoad);
		}
		
		protected function js_playlistItem(item:Number):void {
			_player.playlistItem(item);
		}

		protected function js_playlistNext():void {
			_player.playlistNext();
		}

		protected function js_playlistPrev():void {
			_player.playlistPrev();
		}

		protected function js_mute(mutestate:*=null):void {
			if (mutestate == null){
				_player.mute(!_player.config.mute);
			} else {
				if (String(mutestate).toLowerCase() == "true") {
					_player.mute(true);
				} else {
					_player.mute(false);
				}
			}
		}

		protected function js_volume(volume:Number):void {
			_player.volume(volume);
		}

		protected function js_fullscreen(fullscreenstate:*=null):void {
			if (fullscreenstate == null){
				_player.fullscreen(!_player.config.fullscreen);
			} else {
				if (String(fullscreenstate).toLowerCase() == "true") {
					_player.fullscreen(true);
				} else {
					_player.fullscreen(false);
				}
			}
		}
		
		protected function setComponentVisibility(component:IPlayerComponent, state:Boolean):void {
			if (component is IPlaylistComponent) {
				state ? (component as IPlaylistComponent).show() : (component as IPlaylistComponent).hide();
			} else if (component is IDockComponent) {
				state ? (component as IDockComponent).show() : (component as IDockComponent).hide();
			} else if (component is IControlbarComponent) {
				state ? (component as IControlbarComponent).show() : (component as IControlbarComponent).hide();
			}
		}

		protected function js_showControlbar():void {
			setComponentVisibility(_player.controls.controlbar, true);
		}
		
		protected function js_hideControlbar():void {
			setComponentVisibility(_player.controls.controlbar, false);
		}

		protected function js_showDock():void {
			setComponentVisibility(_player.controls.dock, true);
		}
		
		protected function js_hideDock():void {
			setComponentVisibility(_player.controls.dock, false);
		}

		protected function js_showDisplay():void {
			setComponentVisibility(_player.controls.display, true);
		}
		
		protected function js_hideDisplay():void {
			setComponentVisibility(_player.controls.display, false);
		}

		
	}

}