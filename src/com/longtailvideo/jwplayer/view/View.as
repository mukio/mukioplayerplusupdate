package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Color;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.player.PlayerV4Emulation;
	import com.longtailvideo.jwplayer.player.PlayerVersion;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlayerComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFormat;


	public class View extends GlobalEventDispatcher {
		protected var _player:IPlayer;
		protected var _model:Model;
		protected var _skin:ISkin;
		protected var _components:IPlayerComponents;
		protected var _fullscreen:Boolean = false;
		protected var _preserveAspect:Boolean = false;
		protected var _normalScreen:Rectangle;
		protected var stage:Stage;

		protected var _root:MovieClip;

		protected var _maskedLayers:MovieClip;
		protected var _backgroundLayer:MovieClip;
		protected var _mediaLayer:MovieClip;
		protected var _imageLayer:MovieClip;
		protected var _componentsLayer:MovieClip;
		protected var _pluginsLayer:MovieClip;
		protected var _plugins:Object;

		protected var _displayMasker:MovieClip;

		protected var _image:Loader;
		protected var _logo:Logo;

		protected var layoutManager:PlayerLayoutManager;

		[Embed(source="../../../../../assets/flash/loader/loader.swf")]
		protected var LoadingScreen:Class;

		[Embed(source="../../../../../assets/flash/loader/error.swf")]
		protected var ErrorScreen:Class;

		protected var loaderScreen:Sprite;
		
		protected var currentLayer:Number = 0;
		
		// Keep track of the last tab index
		protected var lastIndex:Number = -1;
		
		public function View(player:IPlayer, model:Model) {
			_player = player;
			_model = model;

//			RootReference.stage.scaleMode = StageScaleMode.NO_SCALE;
//			RootReference.stage.stage.align = StageAlign.TOP_LEFT;

			loaderScreen = new Sprite();
			loaderScreen.name = 'loaderScreen';

//			RootReference.stage.addChildAt(loaderScreen, 0);
			RootReference.root.addChildAt(loaderScreen, 0);

//			if (RootReference.stage.stageWidth > 0) {
			if (RootReference.root.width > 0) {
				resizeStage();
			} else {
//				RootReference.stage.addEventListener(Event.RESIZE, resizeStage);
//				RootReference.stage.addEventListener(Event.ADDED_TO_STAGE, resizeStage);
				RootReference.root.addEventListener(Event.RESIZE, resizeStage);
				RootReference.root.addEventListener(Event.ADDED_TO_STAGE, resizeStage);
			}

			_root = new MovieClip();
			_normalScreen = new Rectangle();
		}


		protected function resizeStage(evt:Event=null):void {
			try {
//				RootReference.stage.removeEventListener(Event.RESIZE, resizeStage);
//				RootReference.stage.removeEventListener(Event.ADDED_TO_STAGE, resizeStage);
				RootReference.root.removeEventListener(Event.RESIZE, resizeStage);
				RootReference.root.removeEventListener(Event.ADDED_TO_STAGE, resizeStage);
			} catch(err:Error) {
				Logger.log("Can't add stage resize handlers: " + err.message);
			}

			loaderScreen.graphics.clear();
			loaderScreen.graphics.beginFill(0, 0);
            if(RootReference.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
			    loaderScreen.graphics.drawRect(0, 0, RootReference.stage.stageWidth, RootReference.stage.stageHeight);
            }
            else
            {
			    loaderScreen.graphics.drawRect(0, 0, RootReference.root.width, RootReference.root.height);
            }
			loaderScreen.graphics.endFill();
		}


		public function get skin():ISkin {
			return _skin;
		}


		public function set skin(skn:ISkin):void {
			_skin = skn;
		}


		public function setupView():void {
//			RootReference.stage.addChildAt(_root, 0);
			RootReference.root.addChildAt(_root, 0);
			_root.visible = false;

			setupLayers();
			setupComponents();

//			RootReference.stage.addEventListener(Event.RESIZE, resizeHandler);
//			RootReference.stage.addEventListener(FocusEvent.FOCUS_IN, keyFocusOutHandler);
			RootReference.root.addEventListener(Event.RESIZE, resizeHandler);
			RootReference.root.addEventListener(FocusEvent.FOCUS_IN, keyFocusOutHandler);
			

			_model.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, itemHandler);
			_model.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);

			layoutManager = new PlayerLayoutManager(_player);
			setupRightClick();

			redraw();
		}

		/** 
		 * Handles the loss of a button's focus.  
		 * The player attempts to blur Flash's focus on the page after the last tabbable 
		 * element so that keyboard users don't get stuck with their focus insideo of the player.   
		 **/
		protected function keyFocusOutHandler(evt:FocusEvent):void {
			var button:Sprite = evt.target as Sprite;
			
			if (!button) { return; }
			
			if (button.tabIndex < lastIndex) {
				// Prevent focus from wrapping to the first button
				evt.preventDefault();
				// Nothing should be focused now
//				RootReference.stage.focus = null;
				// Try to blur the Flash object in the browser
				if (ExternalInterface.available) {
					ExternalInterface.call("(function() { try { document.getElementById('"+PlayerVersion.id+"').blur(); } catch(e) {} })"); 
				}
				lastIndex = -1;
			} else {
				lastIndex = button.tabIndex;
			}
		}
		
		
		protected function setupRightClick():void {
			var menu:RightclickMenu = new RightclickMenu(_player, _root);
			menu.addGlobalListener(forward);
		}

		public function completeView(isError:Boolean=false, errorMsg:String=""):void {
			if (!isError) {
				_root.visible = true;
				loaderScreen.parent.removeChild(loaderScreen);
			} else {
				var errorScreen:DisplayObject = new ErrorScreen() as DisplayObject;
				var errorMessage:TextField = new TextField();
				errorMessage.defaultTextFormat = new TextFormat("_sans", 12, 0xffffff);
				errorMessage.text = errorMsg;
				errorMessage.width = loaderScreen.width - 60;
				errorMessage.wordWrap = true;
				errorMessage.height = errorMessage.textHeight + 10;

				errorScreen.x = (loaderScreen.width - errorScreen.width) / 2;
				errorScreen.y = (loaderScreen.height - errorScreen.height - errorMessage.height - 10) / 2;
				errorMessage.x = (loaderScreen.width - errorMessage.width) / 2;
				errorMessage.y = errorScreen.y + errorScreen.height + 10;
				loaderScreen.addChild(errorScreen);
				loaderScreen.addChild(errorMessage);
			}
		}


		protected function setupLayers():void {
			_maskedLayers = setupLayer("masked", currentLayer++);
			
			_backgroundLayer = setupLayer("background", 0, _maskedLayers);
			setupBackground();

			_mediaLayer = setupLayer("media", 1, _maskedLayers);
			_mediaLayer.visible = false;

			_imageLayer = setupLayer("image", 1, _maskedLayers);
			_image = new Loader();
			_image.contentLoaderInfo.addEventListener(Event.COMPLETE, imageComplete);
			_image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError);

			setupLogo();

			_componentsLayer = setupLayer("components", currentLayer++);

			_pluginsLayer = setupLayer("plugins", currentLayer++);
			_plugins = {};
			
		}
			
		protected function setupLogo():void {
			_logo = new Logo(_player);
		}


		protected function setupLayer(name:String, index:Number, parent:DisplayObjectContainer=null):MovieClip {
			var layer:MovieClip = new MovieClip();
			parent ? parent.addChildAt(layer,index) : _root.addChildAt(layer, index);
			layer.name = name;
			layer.x = 0;
			layer.y = 0;
			return layer;
		}


		protected function setupBackground():void {
			var background:MovieClip = new MovieClip();
			background.name = "background";
			_backgroundLayer.addChild(background);
			
			var screenColor:Color;
			if (_model.config.screencolor) {
				screenColor = _model.config.screencolor;
			} else if (_model.config.pluginConfig('display').hasOwnProperty('backgroundcolor')) {
				screenColor = new Color(String(_model.config.pluginConfig('display')['backgroundcolor']));
			}
			
			background.graphics.beginFill(screenColor ? screenColor.color : 0x000000, screenColor ? 1 : 0);
			background.graphics.drawRect(0, 0, 1, 1);
			background.graphics.endFill();
		}


		protected function setupDisplayMask():void {
			_displayMasker = new MovieClip();
			_displayMasker.graphics.beginFill(0x000000, 1);
			_displayMasker.graphics.drawRect(0, 0, _player.config.width, _player.config.height);
			_displayMasker.graphics.endFill();

			_maskedLayers.mask = _displayMasker;
		}


		protected function setupComponents():void {
			var n:Number = 0;
			
			_components = new PlayerComponents(_player);

			setupComponent(_components.display, n++);
			setupComponent(_components.playlist, n++);
			setupComponent(_logo, n++);
			setupComponent(_components.controlbar, n++);
			setupComponent(_components.dock, n++);
		}


		protected function setupComponent(component:*, index:Number):void {
			if (component is IGlobalEventDispatcher) { (component as IGlobalEventDispatcher).addGlobalListener(forward); }
			if (component is DisplayObject) { _componentsLayer.addChildAt(component as DisplayObject, index); }
		}


		protected function resizeHandler(event:Event):void {
			_fullscreen = (RootReference.stage.displayState == StageDisplayState.FULL_SCREEN);
			if (_model.fullscreen != _fullscreen) {
				dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, _fullscreen));
			}
            if(_fullscreen)
            {
    			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_RESIZE, {width: RootReference.stage.stageWidth, height: RootReference.stage.stageHeight}));
            }
            else
            {
			    dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_RESIZE, {width: RootReference.root.width, height: RootReference.root.height}));
            }

			redraw();
		}


		public function fullscreen(mode:Boolean=true):void {
			try {
				RootReference.stage.displayState = mode ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
                redraw();
			} catch (e:Error) {
				Logger.log("Could not enter fullscreen mode: " + e.message);
			}
		}


		/** Redraws the plugins and player components **/
		public function redraw():void {
            if(RootReference.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
			    layoutManager.resize(RootReference.stage.stageWidth, RootReference.stage.stageHeight);
            }
            else
            {
			    layoutManager.resize(RootReference.root.width, RootReference.root.height);
            }

			_components.resize(_player.config.width, _player.config.height);
			if (!_fullscreen) {
				_normalScreen.width = _player.config.width;
				_normalScreen.height = _player.config.height;
			} 

			resizeBackground();
			resizeMasker();

			_imageLayer.x = _mediaLayer.x = _components.display.x;
			_imageLayer.y = _mediaLayer.y = _components.display.y;

			if (_preserveAspect) {
				if(!_fullscreen && _player.config.stretching != Stretcher.EXACTFIT) {
					_preserveAspect = false;
				}
			} else {
				if (_fullscreen && _player.config.stretching == Stretcher.EXACTFIT) {
					_preserveAspect = true;
				}
			}

			resizeImage(_player.config.width, _player.config.height);
			resizeMedia(_player.config.width, _player.config.height);
			
			if (_logo) {
				_logo.x = _components.display.x;
				_logo.y = _components.display.y;
				_logo.resize(_player.config.width, _player.config.height);
			}

			for (var i:Number = 0; i < _pluginsLayer.numChildren; i++) {
				var plug:IPlugin = _pluginsLayer.getChildAt(i) as IPlugin;
				var plugDisplay:DisplayObject = plug as DisplayObject;
				if (plug && plugDisplay) {
					var cfg:PluginConfig = _player.config.pluginConfig(plug.id);
					if (cfg['visible']) {
						plugDisplay.visible = true;
						plugDisplay.x = cfg['x'];
						plugDisplay.y = cfg['y'];
						try {
							plug.resize(cfg.width, cfg.height);
						} catch (e:Error) {
							Logger.log("There was an error resizing plugin '" + plug.id + "': " + e.message);
						}
					} else {
						plugDisplay.visible = false;
					}
				}
			}

			PlayerV4Emulation.getInstance(_player).resize(_player.config.width, _player.config.height);
		}

		protected function resizeMedia(width:Number, height:Number):void {
			if (_mediaLayer.numChildren > 0 && _model.media.display) {
				if (_preserveAspect && _model.media.stretchMedia) {
					if (_fullscreen && _player.config.stretching == Stretcher.EXACTFIT) {
						_model.media.resize(_normalScreen.width, _normalScreen.height);
						Stretcher.stretch(_mediaLayer, width, height, Stretcher.UNIFORM);
					} else {
						_model.media.resize(width, height);
						_mediaLayer.scaleX = _mediaLayer.scaleY = 1;
						_mediaLayer.x = _mediaLayer.y = 0;
					}
				} else {
					_model.media.resize(width, height);
					_mediaLayer.x = _mediaLayer.y = 0;
				}
				_mediaLayer.x += _components.display.x;
				_mediaLayer.y += _components.display.y;
			}
		}

		protected function resizeImage(width:Number, height:Number):void {
			if (_imageLayer.numChildren > 0) {
				if (_preserveAspect) {
					if (_fullscreen && _player.config.stretching == Stretcher.EXACTFIT) {
						Stretcher.stretch(_image, _normalScreen.width, _normalScreen.height, _player.config.stretching);
						Stretcher.stretch(_imageLayer, width, height, Stretcher.UNIFORM);
					} else {
						Stretcher.stretch(_image, width, height, _player.config.stretching);
						Stretcher.stretch(_imageLayer, width, height, Stretcher.NONE);
						_imageLayer.x = _imageLayer.y = 0;
					}
				} else {
					Stretcher.stretch(_image, width, height, _player.config.stretching);
					_imageLayer.x = _imageLayer.y = 0;
				}
				_imageLayer.x += _components.display.x;
				_imageLayer.y += _components.display.y;
			}
			
		}

		protected function resizeBackground():void {
			var bg:DisplayObject = _backgroundLayer.getChildByName("background");
            if(RootReference.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
    			bg.width = RootReference.stage.stageWidth;
    			bg.height = RootReference.stage.stageHeight;
            }
            else
            {
    			bg.width = RootReference.root.width;
    			bg.height = RootReference.root.height;
            }
			bg.x = 0;
			bg.y = 0;
		}


		protected function resizeMasker():void {
			if (_displayMasker == null)
				setupDisplayMask();

			_displayMasker.graphics.clear();
			_displayMasker.graphics.beginFill(0, 1);
			_displayMasker.graphics.drawRect(_components.display.x, _components.display.y, _player.config.width, _player.config.height);
			_displayMasker.graphics.endFill();
		}


		public function get components():IPlayerComponents {
			return _components;
		}

		/** This feature, while not yet implemented, will allow the API to replace the built-in components with any class that implements the control interfaces. **/
		public function overrideComponent(newComponent:IPlayerComponent):void {
			if (newComponent is IControlbarComponent) {
				// Replace controlbar
			} else if (newComponent is IDisplayComponent) {
				// Replace display
			} else if (newComponent is IDockComponent) {
				// Replace dock
			} else if (newComponent is IPlaylistComponent) {
				// Replace playlist
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Component must implement a component interface"));
			}
		}


		public function addPlugin(id:String, plugin:IPlugin):void {
			try {
				var plugDO:DisplayObject = plugin as DisplayObject;
				if (!_plugins[id] && plugDO != null) {
					_plugins[id] = plugDO;
					_pluginsLayer.addChild(plugDO);
				}
				if (_player.config.pluginIds.indexOf(id) < 0) {
					_player.config.plugins += "," + id;
				}
			} catch (e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}


		public function removePlugin(plugin:IPlugin):void {
			var id:String = plugin.id.toLowerCase();
			if (id && _plugins[id] is IPlugin) {
				_pluginsLayer.removeChild(_plugins[id]);
				delete _plugins[id];
			}
		}


		public function loadedPlugins():Array {
			var list:Array = [];
			for (var pluginId:String in _plugins) {
				if (_plugins[pluginId] is IPlugin) {
					list.push(pluginId);
				}
			}
			return list;
		}


		public function getPlugin(id:String):IPlugin {
			return _plugins[id] as IPlugin;
		}


		public function bringPluginToFront(id:String):void {
			var plugin:IPlugin = getPlugin(id);
			_pluginsLayer.setChildIndex(plugin as DisplayObject, _pluginsLayer.numChildren - 1);
		}


		protected function mediaLoaded(evt:MediaEvent):void {
			if (_model.media.display) {
				_mediaLayer.addChild(_model.media.display);
				resizeMedia(_player.config.width, _player.config.height);
			}
		}


		protected function itemHandler(evt:PlaylistEvent):void {
			while (_mediaLayer.numChildren) {
				_mediaLayer.removeChildAt(0);
			}
			while (_imageLayer.numChildren) {
				_imageLayer.removeChildAt(0);
			}
			if (_model.playlist.currentItem && _model.playlist.currentItem.image) {
				loadImage(_model.playlist.currentItem.image);
			}
		}


		protected function loadImage(url:String):void {
			_image.load(new URLRequest(url), new LoaderContext(true));
		}


		protected function imageComplete(evt:Event):void {
			if (_image) {
				_imageLayer.addChild(_image);
				resizeImage(_player.config.width, _player.config.height);
				try {
					Draw.smooth(_image.content as Bitmap);
				} catch (e:Error) {
					Logger.log('Could not smooth preview image: ' + e.message);
				}
			}
		}


		protected function imageError(evt:ErrorEvent):void {
			Logger.log('Error loading preview image: '+evt.text);
		}


		protected function stateHandler(evt:PlayerStateEvent):void {
			switch (evt.newstate) {
				case PlayerState.IDLE:
					_imageLayer.visible = true;
					_mediaLayer.visible = false;
					if (_logo) _logo.visible = false;
					break;
				case PlayerState.PLAYING:
					_mediaLayer.visible = true;
					if (_model.media.display) {
						_imageLayer.visible = false;
					}
					if (_logo) _logo.visible = true;
					break;
				case PlayerState.BUFFERING:
					if (_logo) _logo.visible = true;
					break;
			}
		}


		protected function forward(evt:Event):void {
			if (evt is PlayerEvent)
				dispatchEvent(evt);
		}
	}
}