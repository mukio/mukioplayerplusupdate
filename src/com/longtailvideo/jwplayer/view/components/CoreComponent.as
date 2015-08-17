package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	import com.longtailvideo.jwplayer.model.Color;
	import com.longtailvideo.jwplayer.player.IPlayer;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class CoreComponent extends MovieClip implements IGlobalEventDispatcher {

		private var _dispatcher:IGlobalEventDispatcher;
		protected var _player:IPlayer;
		protected var _name:String;
		protected var _hiding:Boolean = false;

		public function CoreComponent(player:IPlayer, name:String) {
			_dispatcher = new GlobalEventDispatcher();
			_player = player;
			_name = name;
			super();
		}
		
		public function hide():void {
			_hiding = true;
			this.visible = false;
		}
		
		public function show():void {
			_hiding = false;
			this.visible = true;
		}
		
		protected function get player():IPlayer {
			return _player;
		}

		protected function getSkinElement(element:String):DisplayObject {
			return player.skin.getSkinElement(_name,element);
		}
		
		protected function getConfigParam(param:String):* {
			return player.config.pluginConfig(_name)[param];
		}
		
		protected function setConfigParam(param:String, value:*):void {
			player.config.pluginConfig(_name)[param] = value;
		}
		
		///////////////////////////////////////////		
		// Font style related helper getters
		///////////////////////////////////////////		
		
		protected function get backgroundColor():Color {
			return getConfigParam("backgroundcolor") ? new Color(String(getConfigParam("backgroundcolor"))) : null;
		}

		protected function get fontColor():Color {
			return getConfigParam("fontcolor") ? new Color(String(getConfigParam("fontcolor"))) : null;
		}
		
		protected function get fontSize():Number {
			return getConfigParam("fontsize") ? Number(getConfigParam("fontsize")) : 0;
		}
		
		protected function get fontFace():String {
			return getConfigParam("font");
		}
		
		protected function get fontWeight():String { 
			return getConfigParam("fontweight") ? String(getConfigParam("fontweight")).toLowerCase() : "";
		}
		
		protected function get fontStyle():String {
			return getConfigParam("fontstyle") ? String(getConfigParam("fontstyle")).toLowerCase() : "";
		}
		
		/** Whether or not the component has been hidden. **/
		protected function get hidden():Boolean {
			return _hiding;
		}

		
		///////////////////////////////////////////		
		/// IGlobalEventDispatcher implementation
		///////////////////////////////////////////		
		/**
		 * @inheritDoc
		 */
		public function addGlobalListener(listener:Function):void {
			_dispatcher.addGlobalListener(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function removeGlobalListener(listener:Function):void {
			_dispatcher.removeGlobalListener(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function dispatchEvent(event:Event):Boolean {
			_dispatcher.dispatchEvent(event);
			return super.dispatchEvent(event);
		}
	}
}