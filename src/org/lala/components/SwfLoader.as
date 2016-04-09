package org.lala.components
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import mx.events.RSLEvent;
	import mx.preloaders.SparkDownloadProgressBar;
	import mx.core.UIComponent.*;
	
	
	public class SwfLoader extends SparkDownloadProgressBar
	{
		private var _displayStartCount:uint = 0;
		private var _initProgressCount:uint = 0;
		private var _downloadComplete:Boolean = false;
		private var _showingDisplay:Boolean = false;
		private var _startTime:int;
		private var numberRslTotal:Number = 1;
		private var numberRslCurrent:Number = 1;
		
		private var _barWidth:Number;
		private var _bgSprite:Sprite;
		private var _barSprite:Sprite;
		private var _barFrameSprite:Sprite;
		private var _text:TextField;
		private var _fmt:TextFormat;
		
		public function SwfLoader()
		{
			super();
		}
		
		/**
		 *  Event listener for the <code>FlexEvent.INIT_COMPLETE</code> event.
		 *  NOTE: This event can be commented out to stop preloader from completing during testing
		 */
		override protected function initCompleteHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 *  Creates the subcomponents of the display.
		 */
		override protected function createChildren():void
		{
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
			
			_bgSprite = new Sprite();
			_barFrameSprite = new Sprite();
			_barSprite = new Sprite();
			_text = new TextField();
			
			
			addChild(_bgSprite);
			addChild(_barFrameSprite);  
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
			 
			_barFrameSprite.x = _barSprite.x = startX + 5;
			_barFrameSprite.y = _barSprite.y = startY + 5;
			
			// Draw the box background/shadow
			/**
			g = _bgSprite.graphics;
			g.lineStyle(1, 0x636363);
			g.beginFill(0xFFFFFF);
			g.drawRect(startX, startY, totalWidth, totalHeight);
			g.endFill();
			g.lineStyle();
			**/
			
			g = graphics;

		}
		
		/**
		 * Event listener for the <code>ProgressEvent.PROGRESS event</code> event.
		 * Download of the first SWF app
		 **/
		override protected function progressHandler(evt:ProgressEvent):void {
			if (_showingDisplay)        
				setDownloadProgress(evt.bytesLoaded, evt.bytesTotal);
		}
		
		/**
		 * Event listener for the <code>RSLEvent.RSL_PROGRESS</code> event.
		 **/
		override protected function rslProgressHandler(evt:RSLEvent):void {
		}
		
		/**
		 *  indicate download progress.
		 */
		override protected function setDownloadProgress(completed:Number, total:Number):void {
			if (!_barFrameSprite)
				return;
			
			var w:Number = Math.round(_barWidth * Math.min(completed / total / 2, 1));
			var h:Number = 14;
			var g:Graphics = _barSprite.graphics;
			
			_text.text = Math.round( Math.min(completed / total * 50, 50) ) + "%";
			_text.setTextFormat(_fmt);
			
			g.clear();
			
			g.beginFill(0x0099FF,1); 
			g.drawRoundRect(1, 1, w - 2, h - 2, 12);
			g.endFill();
			
			/***
			g = _bgSprite.graphics;
			
			g.clear();
		
			g.beginFill(0xCCCCCC,1);
			g.drawRoundRect(1, 1, _barWidth - 2, h - 2, 12);
			g.endFill();
			***/
			
			if (completed == total)
				_downloadComplete = true
		}
		
		/**
		 *  Updates the inner portion of the download progress bar to
		 *  indicate initialization progress.
		 */
		override protected function setInitProgress(completed:Number, total:Number):void {
			
			var w:Number = Math.round(_barWidth * Math.min(completed / total / 2 + 0.5, 1));
			var h:Number = 14;
			var g:Graphics = _barSprite.graphics;
			
			_text.text = Math.round( Math.min(completed / total * 50, 50) + 50 ) + "%";
			_text.setTextFormat(_fmt);
			
			g.clear();
			
			// highlight/fill
			//g.lineStyle(1, 0xCCCCCC);
			g.beginFill(0x0099FF,1);
			g.drawRoundRect(1, 1, w - 2, h - 2, 12);
			g.endFill();
			
			/***
			g = _bgSprite.graphics;
			
			g.clear();

			g.beginFill(0xCCCCCC,1);
			g.drawRoundRect(1, 1, _barWidth - 2, h - 2, 12);
			g.endFill();
			 * ***/
			
			// divider line
			//g.lineStyle(1, 0, 0.55);
			//g.moveTo(w - 1, 2);
			//g.lineTo(w - 1, h - 1);
		}
		
		/**
		 *  Event listener for the <code>FlexEvent.INIT_PROGRESS</code> event.
		 *  This implementation updates the progress bar
		 *  each time the event is dispatched.
		 */
		override protected function initProgressHandler(event:Event):void {
			// make elapsed time relative the time we started init.
			if (_initProgressCount == 0)
				_startTime = getTimer();
			
			var elapsedTime:int = getTimer() - _startTime;
			
			_initProgressCount++;
			
			if (!_showingDisplay &&
				showDisplayForInit(elapsedTime, _initProgressCount))
			{
				_displayStartCount = _initProgressCount;
				show();
				
				// If we are showing the progress for the first
				// time here, we need to call setDownloadProgress() once to draw
				// the progress bar background.
				setDownloadProgress(100, 100);
			}
			
			if (_showingDisplay)
			{
				// if show() did not actually show because of SWFObject bug
				// then we may need to draw the download bar background here
				if (!_downloadComplete)
					setDownloadProgress(100, 100);
				
				setInitProgress(_initProgressCount, initProgressTotal);
			}
		}
		
		private function show():void
		{
			// swfobject reports 0 sometimes at startup
			// if we get zero, wait and try on next attempt
			if (stageWidth == 0 && stageHeight == 0)
			{
				try
				{
					stageWidth = stage.stageWidth;
					stageHeight = stage.stageHeight
				}
				catch (e:Error)
				{
					stageWidth = loaderInfo.width;
					stageHeight = loaderInfo.height;
				}
				if (stageWidth == 0 && stageHeight == 0)
					return;
			}
			
			_showingDisplay = true;
			createChildren();
		}
		

		
	}
}