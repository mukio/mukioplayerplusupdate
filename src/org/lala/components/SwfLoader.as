package org.lala.components
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.preloaders.SparkDownloadProgressBar;
	
	public class SwfLoader extends SparkDownloadProgressBar
	{
		public function SwfLoader()
		{
			super();
		}
		
		private var _downloadComplete:Boolean = false;
		
		private var _barWidth:Number;
		//private var _bgSprite:Sprite;
		private var _barSprite:Sprite;
		//private var _barFrameSprite:Sprite;
		private var _text:TextField;
		private var _fmt:TextFormat;
		private var _initProgressCount : uint = 0;
		
		/**
		 *  Creates the subcomponents of the display.
		 */
		override protected function createChildren():void{
			return;
		}
		
		override public function set preloader(value:Sprite):void
		{
			super.preloader = value;

			if (!_barSprite){
				var g:Graphics = graphics;
			
				//Background
				g.beginFill(0xFFFFFF, backgroundAlpha);
				g.drawRect(0, 0, stageWidth, stageHeight);
			
			
				// Determine the size
				var totalWidth:Number = Math.min(stageWidth - 10, 307);
				var totalHeight:Number = 24;
				var startX:Number = Math.round((stageWidth - totalWidth) / 2);
				var startY:Number = Math.round((stageHeight - totalHeight) / 2);
			
				_barWidth = totalWidth - 10;
			
				//_bgSprite = new Sprite();
				//_barFrameSprite = new Sprite();
				_barSprite = new Sprite();
				_text = new TextField();
			
			
				//addChild(_bgSprite);
				//addChild(_barFrameSprite);  
				addChild(_barSprite);
				addChild(_text);
				
				_text.autoSize = "center";
				_text.text = "Loading";
				
				_fmt = new TextFormat();
				_fmt.size = 28;
				_fmt.font = "Times New Roman";
				
				_text.setTextFormat(_fmt);
				_text.x = (stageWidth - _text.width) /2;
				_text.y = (stageHeight - _text.height) / 2 + 25 ;
				 
				_barSprite.x = startX + 5;
				_barSprite.y = startY + 5;
				
				g = graphics;
			}

		}
		
		/**
		 *  indicate download progress.
		 */
		override protected function setDownloadProgress(completed:Number, total:Number):void {
			if (!_barSprite)
				return;
			

			
			if (completed == total)
				_downloadComplete = true
		}
		
		/**
		 *  Updates the inner portion of the download progress bar to
		 *  indicate initialization progress.
		 */
		override protected function setInitProgress(completed:Number, total:Number):void {
			

		}
		
		override protected function progressHandler(event : ProgressEvent) : void {
			super.progressHandler(event);
			if (_text) {
				var p:Number = event.bytesLoaded / event.bytesTotal / 10 * 9;
				var w:Number = Math.round(_barWidth * Math.min(p, 0.9));
				var h:Number = 14;
				var g:Graphics = _barSprite.graphics;
				
				_text.text = Math.round( Math.min( p*100, 90) ) + "%";
				_text.setTextFormat(_fmt);
				
				g.clear();
				
				g.beginFill(0x0099FF,1); 
				g.drawRoundRect(1, 1, w - 2, h - 2, 12);
				g.endFill();
			}
			
		}
		
		override protected function completeHandler(event : Event) : void {
			_text.text = "Ready!";
			_text.setTextFormat(_fmt);
			//preloaderLogo.stop();
		}        
		
		
		override protected function initProgressHandler(event : Event) : void {
			super.initProgressHandler(event);
			//similar to super
			_initProgressCount++;
			if (_text) {
				var p:Number = _initProgressCount / initProgressTotal * 0.1 + 0.9;
				
				var w:Number = Math.round(_barWidth * Math.min(p, 1));
				var h:Number = 14;
				var g:Graphics = _barSprite.graphics;
				
				_text.text = Math.round( Math.min( p*100, 100 )) + "%";
				_text.setTextFormat(_fmt);
				
				g.clear();
				g.beginFill(0x0099FF,1);
				g.drawRoundRect(1, 1, w - 2, h - 2, 12);
				g.endFill();
			}
		}
		
	}
}