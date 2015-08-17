package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	import com.longtailvideo.jwplayer.view.skins.PNGSkin;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	public class DisplayComponent extends CoreComponent implements IDisplayComponent {
		protected var _icon:DisplayObject;
		protected var _background:MovieClip;
		protected var _overlay:Sprite;
		protected var _text:TextField;
		protected var _textBack:Sprite;
		protected var _icons:Object;
		protected var _rotateInterval:Number;
		protected var _bufferIcon:Sprite;
		protected var _rotate:Boolean = true;
		protected var _youtubeMask:MovieClip;
		
		protected var _bufferRotationTime:Number = 100;
		protected var _bufferRotationAngle:Number = 15;
		
		
		public function DisplayComponent(player:IPlayer) {
			super(player, "display");
			addListeners();
			setupDisplayObjects();
			setupIcons();
			if (!isNaN(getConfigParam('bufferrotation'))) _bufferRotationAngle = Number(getConfigParam('bufferrotation'));
			if (!isNaN(getConfigParam('bufferinterval'))) _bufferRotationTime = Number(getConfigParam('bufferinterval'));
		}
		
		
		private function itemHandler(evt:PlaylistEvent):void {
			setDisplay(_icons['play'], '');
			if (background) {
				if (_player.playlist.currentItem && _player.playlist.currentItem.provider == "youtube") {
					background.mask = _youtubeMask;
				} else {
					background.mask = null;
				}
			}
		}
		

		private function addListeners():void {
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, stateHandler);
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			player.addEventListener(PlayerEvent.JWPLAYER_ERROR, errorHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			this.buttonMode = true;
		}
		
		
		private function setupDisplayObjects():void {
			_background = new MovieClip();
			background.name = "background";
			addChildAt(background, 0);
			background.graphics.beginFill(0, 0);
			background.graphics.drawRect(0, 0, 1, 1);
			background.graphics.endFill();
			
			_overlay = new Sprite();
			_overlay.name = "overlay";
			addChildAt(_overlay, 1);
			
			_textBack = new Sprite();
			_textBack.name = "textBackground";
			_textBack.graphics.beginFill(0, 0.8);
			_textBack.graphics.drawRect(0, 0, 1, 1);
			_textBack.visible = false;
			_overlay.addChild(_textBack);
			
			_icon = new MovieClip();
			addChild(icon);

			_text = new TextField();
			text.gridFitType = GridFitType.NONE;
			text.defaultTextFormat = new TextFormat("_sans", null, 0xFFFFFF);
			_overlay.addChild(text);
			
			_youtubeMask = new MovieClip();
		}
		
		
		protected function setupIcons():void {
			_icons = {};
			setupIcon('buffer');
			setupIcon('play');
			setupIcon('mute');
		}
		
		
		/**
		 * Takes in an icon from a PNG skin and rearranges its children so that it's centered around 0, 0 
		 */
		protected function centerIcon(icon:Sprite):void {
			if (icon) {
				for (var i:Number=0; i < icon.numChildren; i++) {
					icon.getChildAt(i).x = -Math.round(icon.getChildAt(i).width)/2;
					icon.getChildAt(i).y = -Math.round(icon.getChildAt(i).height)/2;
				}
			}
		}
		
		protected function setupIcon(name:String):void {
			var icon:Sprite = getSkinElement(name + 'Icon') as Sprite;
			var iconOver:Sprite = getSkinElement(name + 'IconOver') as Sprite;

			if (!icon) { return; }
			
			if (_player.skin is PNGSkin) {
				if (icon.getChildByName("bitmap")) {
					centerIcon(icon);
					icon.name = 'out';
				}
				if (iconOver && iconOver.getChildByName("bitmap")) {
					centerIcon(iconOver);
					iconOver.name = 'over';
				}
			}
			
			if (name == "buffer") {
				if (player.skin is PNGSkin) {
					if (icon is MovieClip && (icon as MovieClip).totalFrames > 1) {
						// Buffer is already animated; no need to rotate.
						_rotate = false;
					} else {
						try {
							_bufferIcon = icon;
							var bufferBitmap:Bitmap = _bufferIcon.getChildByName('bitmap') as Bitmap;
							if (bufferBitmap) {
								Draw.smooth(bufferBitmap);
							} else {
								centerIcon(icon);
							}
						} catch (e:Error) {
							_rotate = false;
						}
					}
				} else {
					_rotate = false;
				}
			}
			
			var back:Sprite = getSkinElement('background') as Sprite;
			if (back) {
				if (_player.skin is PNGSkin) centerIcon(back);
			} else {
				back = new Sprite();
			}

			if (iconOver && player.skin is PNGSkin && name != "buffer") {
				iconOver.visible = false;
				back.addChild(iconOver);
				back.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
				back.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			}
			back.addChild(icon);
			if (player.skin is PNGSkin && !icon.getChildByName("bitmap")) {
				if (name != "buffer" || !_rotate) {
					centerIcon(back);
				}
			} else {
				back.x = back.y = icon.x = icon.y = 0;
			}
			_icons[name] = back;

		}
		
		protected function overHandler(evt:MouseEvent):void {
			var button:Sprite = _icon as Sprite;
			if (button) {
				setIconHover(button, true);
			}
		}

		protected function outHandler(evt:MouseEvent):void {
			var button:Sprite = _icon as Sprite;
			if (button) {
				setIconHover(button, false);
			}
		}
		
		protected function setIconHover(icon:Sprite, state:Boolean):void {
			var over:DisplayObject = icon.getChildByName('over'); 
			var out:DisplayObject = icon.getChildByName('out'); 
			
			if (over && out) {
				over.visible = state;
				out.visible = !state;
			}		
		}
		
		public function resize(width:Number, height:Number):void {
			_background.width = width;
			_background.height = height;
			
			_youtubeMask.graphics.clear();
			_youtubeMask.graphics.beginFill(0x00AA00, 0.3);
			_youtubeMask.graphics.drawRect(0, 0, width, height - 100);
			_youtubeMask.graphics.endFill();
			
			positionIcon();
			positionText();
			stateHandler();
		}
		
		
		public function setIcon(displayIcon:DisplayObject):void {
			try {
				if (icon && icon.parent == _overlay) { 
					_overlay.removeChild(icon);
				}
			} catch (err:Error) {
			}
			if (displayIcon && _player.config.icons && (getConfigParam("icons") === true || typeof(getConfigParam("icons")) == "undefined")) {
				if (displayIcon is Sprite) {
					setIconHover(displayIcon as Sprite, false);
				}
				_icon = displayIcon;
				_overlay.addChild(icon);
				positionIcon();
			}
		}
		
		//在此调整播放按钮等位置
		private function positionIcon():void {
			icon.x = background.scaleX - icon.width/2 - 20 ;
			icon.y = background.scaleY - icon.height/2 - 20 ;
		} 
		
		
		public function setText(displayText:String):void {
			if (_icon is Sprite && (_icon as Sprite).getChildByName('txt') is TextField) {
				((_icon as Sprite).getChildByName('txt') as TextField).text = displayText ? displayText : '';
				text.text = '';
			} else {
				text.text = displayText ? displayText : '';
			}
			positionText();
		}
		
		
		private function positionText():void {
			if (text.text) {
				text.visible = true;
				_textBack.visible = true;
				if (text.width > background.scaleX * .75) {
					text.width = background.scaleX * .75;
					text.wordWrap = true;
				} else {
					text.autoSize = TextFormatAlign.CENTER;
				}
				text.x = (background.scaleX - text.textWidth) / 2;
				if (contains(icon)) {
					text.y = icon.y + (icon.height/2) + 10;
				} else {
					text.y = (background.scaleY - text.textHeight) / 2;
				}
				_textBack.y = text.y - 2;
				_textBack.width = getConfigParam('width');
				_textBack.height = text.height + 4;
			} else {
				text.visible = false;
				_textBack.visible = false;
			}
		}
		
		
		protected function setDisplay(displayIcon:DisplayObject, displayText:String = null):void {
			setIcon(displayIcon);
			setText(displayText != null ? displayText : text.text);
		}
		
		
		protected function clearDisplay():void {
			setDisplay(null, '');
		}
		
		
		protected function stateHandler(event:PlayerEvent = null):void {
			//TODO: Handle mute button in error state
			clearRotation();
			switch (player.state) {
				case PlayerState.BUFFERING:
					setDisplay(_icons['buffer'], '');
					if (_rotate){
						startRotation();
					}
					break;
				case PlayerState.PAUSED:
					setDisplay(_icons['play']);
					break;
				case PlayerState.IDLE:
					setDisplay(_icons['play']);
					break;
				default:
					if ( player.config.mute && getConfigParam("showmute") ) {
						setDisplay(_icons['mute']);
					} else {
						clearDisplay();
					}
			}
		}
		
		
		protected function startRotation():void {
			if (!_rotateInterval && (_bufferRotationAngle % 360) != 0) {
				_rotateInterval = setInterval(updateRotation, _bufferRotationTime);
			}
		}
		
		
		protected function updateRotation():void {
			if (_bufferIcon) _bufferIcon.rotation += _bufferRotationAngle;
		}
		
		
		protected function clearRotation():void {
			if (_bufferIcon) _bufferIcon.rotation = 0;
			if (_rotateInterval) {
				clearInterval(_rotateInterval);
				_rotateInterval = undefined;
			}
		}
		
		
		protected function errorHandler(event:PlayerEvent):void {
			setDisplay(null, event.message);
		}
		
		
		protected function clickHandler(event:MouseEvent):void {
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_CLICK));
			if(_player.config.displayclick == 'link') {
				var link:String = _player.playlist.currentItem.link;
				if(link) {
					navigateToURL(new URLRequest(link),_player.config.linktarget);
				}
			} else if (player.state == PlayerState.PLAYING || player.state == PlayerState.BUFFERING) {
				dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PAUSE));
			} else {
				dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PLAY));
			}
		}
		
		
		protected function get icon():DisplayObject {
			return _icon;
		}
		
		
		protected function get text():TextField {
			return _text;
		}
		
		
		protected function get background():MovieClip {
			return _background;
		}
		
		
		/** Hide the display icon **/
		public override function hide():void {
			if (_overlay) {
				_overlay.visible = false;
			}
			_hiding = true;
		}
		
		/** Show the display icon **/
		public override function show():void {
			if (_overlay) {
				_overlay.visible = true;
			}
			_hiding = false;
		}
		
	}
}