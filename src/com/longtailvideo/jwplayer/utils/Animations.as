package com.longtailvideo.jwplayer.utils {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	
	public class Animations {
		/** Target MovieClip **/
		private var _tgt:MovieClip;
		/** Transition speed **/
		private var _spd:Number;
		/** Final Alpha **/
		private var _end:Number;
		/** X position **/
		private var _xps:Number;
		/** Y position **/
		private var _yps:Number;
		/** Text **/
		private var _str:String;
		
		/** Constructor 
		 * @param tgt	The Movielip to animate.
		 **/
		public function Animations(tgt:MovieClip) {
			_tgt = tgt;
		}
		
		/**
		 * Fade function for MovieClip.
		 *
		 * @param end	The final alpha value.
		 * @param spd	The amount of alpha change per frame.
		 **/
		public function fade(end:Number = 1, spd:Number = 0.25):void {
			_end = end;
			if (_tgt.alpha > _end) {
				_spd = -Math.abs(spd);
			} else {
				_spd = Math.abs(spd);
			}
			_tgt.addEventListener(Event.ENTER_FRAME, fadeHandler);
		}
		
		
		/** The fade enterframe function. **/
		private function fadeHandler(evt:Event):void {
			if ((_tgt.alpha >= _end - _spd && _spd > 0) || (_tgt.alpha <= _end + _spd && _spd < 0)) {
				_tgt.removeEventListener(Event.ENTER_FRAME, fadeHandler);
				_tgt.alpha = _end;
				if (_end == 0) {
					_tgt.visible = false;
				}
			} else {
				_tgt.visible = true;
				_tgt.alpha += _spd;
			}
		}
		
		
		/**
		 * Smoothly move a Movielip to a certain position.
		 *
		 * @param xps	The x destination.
		 * @param yps	The y destination.
		 * @param spd	The movement speed (1 - 2).
		 **/
		public function ease(xps:Number, yps:Number, spd:Number = 2):void {
			_spd = spd;
			if (!xps) {
				_xps = _tgt.x;
			} else {
				_xps = xps;
			}
			if (!yps) {
				_yps = _tgt.y;
			} else {
				_yps = yps;
			}
			_tgt.addEventListener(Event.ENTER_FRAME, easeHandler);
		}
		
		
		/** The ease enterframe function. **/
		private function easeHandler(evt:Event):void {
			if (Math.abs(_tgt.x - _tgt.xps) < 1 && Math.abs(_tgt.y - _tgt.yps) < 1) {
				_tgt.removeEventListener(Event.ENTER_FRAME, easeHandler);
				_tgt.x = _tgt.xps;
				_tgt.y = _tgt.yps;
			} else {
				_tgt.x = _tgt.xps - (_tgt.xps - _tgt.x) / _spd;
				_tgt.y = _tgt.yps - (_tgt.yps - _tgt.y) / _spd;
			}
		}
		
		
		/**
		 * Typewrite text into a textfield.
		 *
		 * @param txt	The textstring to write.
		 * @param spd	The speed of typing (1 - 2).
		 **/
		public function write(str:String, spd:Number = 1.5):void {
			_str = str;
			_spd = spd;
			_tgt.tf.text = '';
			_tgt.addEventListener(Event.ENTER_FRAME, writeHandler);
		}
		
		
		/** The write enterframe function. **/
		private function writeHandler(evt:Event):void {
			var dif:Number = Math.floor((_str.length - _tgt.tf.text.length) / _spd);
			_tgt.tf.text = _str.substr(0, _str.length - dif);
			if (_tgt.tf.text == _str) {
				_tgt.tf.htmlText = _str;
				_tgt.removeEventListener(Event.ENTER_FRAME, easeHandler);
			}
		}
	}
}