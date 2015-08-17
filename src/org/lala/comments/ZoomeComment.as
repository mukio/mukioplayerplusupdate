package org.lala.comments 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Expo;
	import org.libspark.betweenas3.easing.Linear;
	import org.libspark.betweenas3.easing.Physical;
	import org.libspark.betweenas3.easing.Quad;
	import org.libspark.betweenas3.events.TweenEvent;
	import org.libspark.betweenas3.tweens.ITween;
	
	/**
	 * zoome style comments
	 * @author aristotle9
	 */
	public class ZoomeComment extends Sprite implements IComment
	{
		static private var TIMER_INTERVAL:Number = 8;//补间更新毫秒
		static private var TIMER_TICK:Number = 1;//退场增量速度
		static private var RADIUS:Number = 540 / 2;//全方向半径
		static private var screenW:int = 540;
		static private var screenH:int = 432;
		
		private var item:Object;//config data
		
		//visual objects
		private var bg:MovieClip;
		private var ttf:TextField;
		private var tf:TextFormat;//but
		
		//size control
		private var W:int;//bg size
		private var H:int;
		private var w:int;//inner size
		private var h:int;
		
		//complete handle,[in]
		public var completeHandler:Function;
		
		//three type of actions
		private var tmte:Timer//lupin effect
		
		private var twd:ITween;//duration
		private var tw:ITween;
		
		public function ZoomeComment(itm:Object) 
		{
			//copy config data
			item = {};
			for(var key :String in itm)
			{
				item[key] = itm[key];
			}
			
			visible = false;
			init();
		}
		
		private function init():void
		{
			//x = item.x;
			y = item.y;
			
			tf = getTextFormat();
			ttf = new TextField();
			ttf.autoSize = 'left';
			ttf.defaultTextFormat = tf;
			ttf.x = ttf.y = 15;
			ttf.text = item.text;
			
			w = ttf.width;//global size bases on text size
			h = ttf.height;
			W = w + 30;
			H = h + 30;
			
			//if (item.alpha)
			//{
				bg = FukidashiFactory.getFukidashi(item.style);
				bg.alpha = item.alpha / 100;
				bg.x = bg.y = 0;
				bg.width = W;
				bg.height = H;
				bg.filters = [new DropShadowFilter(10, 45, 0, 0.5)];
				addChild(bg);
			//}
			
			addChild(ttf);
			
			//position 校正
			setPosition();
			
			var inStyle:String = item.inStyle == 'random' ? getRndStyle() : item.inStyle;
			var outStyle:String = item.outStyle == 'random' ? getRndStyle() : item.outStyle;
			
			//get start,end position
			getPosition(inStyle,outStyle);
			
			//set action chains
    		var twi:ITween=null;
    		var two:ITween=null;
            var sequence:Array = [];
			var self:ZoomeComment = this;
			if (inStyle == 'normal')
			{
				x = item.x;
				y = item.y;
            }
            else
            {
                if (inStyle == 'fade')
                {
                    x = item.x;
                    y = item.y;
                    alpha = 0;
                    twi = BetweenAS3.tween(this, { alpha:1}, {alpha:0},0.5,Linear.easeOut);
                }
                else
                {
                    x = item.stx;
                    y = item.sty;
                    twi = BetweenAS3.tween(this, { x:item.x, y:item.y }, { x:item.stx, y:item.sty },1,Expo.easeOut);
                }
                sequence.push(twi);
            }
            
			if (item.tEffect == 'lupin')
			{
				ttf.text = '';
				tmte = new Timer(50, 0);
				var num:int = 0;
				var tEffectHandler:Function = function(event:TimerEvent):void
				{
					if (num < self.item.text.length)
					{
						num ++;
						self.ttf.text = String(self.item.text).substr(0, num);
					}
					else
					{
						self.tmte.stop();
						self.tmte.removeEventListener(TimerEvent.TIMER, tEffectHandler);
						self.tmte = null;
					}
				};
				tmte.addEventListener(TimerEvent.TIMER, tEffectHandler);
			}
			
			twd = BetweenAS3.tween(this, {alpha:1} , {alpha:1},item.duration / 1000,Linear.easeNone);
            sequence.push(twd);
            
            if(outStyle != 'normal')
            {
                if (outStyle == 'fade')
                {
                    two = BetweenAS3.tween(this, { alpha:0 } , {alpha:1},0.5,Linear.easeIn);
                }
                else
                {
                    two = BetweenAS3.tween(this, { x:item.edx, y:item.edy } , { x:item.x, y:item.y },1,Quad.easeIn);
                }
                sequence.push(two);
            }
			
            if(sequence.length == 1)
            {
                tw = twd;
            }
            else
            {
                tw = BetweenAS3.serialTweens(sequence);
            }
            tw.addEventListener(TweenEvent.COMPLETE,function(event:TweenEvent):void{
               self.completeHandler(); 
            });
		}
		
		private function getTextFormat():TextFormat
		{
			var tmp:TextFormat = new TextFormat();
			
			tmp.size = item.size;
			tmp.color = item.color;
			
			var tStyle:String = item.tStyle;
			
			if (tStyle.match('italic'))
				tmp.italic = true;
				
			if (tStyle.match('bold'))
				tmp.bold = true;
				
			if (tStyle.match('underline'))
				tmp.underline = true;

			return tmp;
		}
		
		//start action chains
		public function start():void
		{
			visible = true;
			tw.play();
			if (item.tEffect == 'lupin')
            {
				tmte.start();
            }
		}
        
		public function set complete(value:Function):void
        {
            this.completeHandler = value;
        }
        public function pause():void
        {
            tw.stop();
            if(tmte)
            {
                tmte.stop();
            }
        }
        public function resume():void
        {
             tw.play();
            if(tmte)
            {
                tmte.start();
            }           
        }
		private function getRndStyle():String
		{
			var arr:Array = ['right',
						 	 'left',
							 'rise',
							 'drop',
							 'fade',
							 'fade'
							];
			return arr[Math.floor(Math.random()*5)];
		}
		
		//change item.x and item.y
		//set popo arrow
		private function setPosition():void
		{
			if (!item.x)
				item.x = 0;
			
			if (!item.y)
				item.y = 0;
				
			if (!item.style)
				item.style = 'normal';
				
			if (W > ZoomeComment.screenW)
			{
				w -= (W - ZoomeComment.screenW);
				W = w;
				h = tf.size as Number;
				H = h + 30;
			}
			
			var newX :int = item.x;
			var newY :int = item.y - H;
			
			if (newX + W <= screenW)
			{
				if (newY > 0)
				{
					bg.gotoAndStop('LB');
				}
				else
				{
					newY = newY + H;
					bg.gotoAndStop('LT');
				}
			}
			else if (newY >= 0)
			{
				newX -= W;
				bg.gotoAndStop('RB');
			}
			else
			{
				newX -= W;
				newY += H;
				bg.gotoAndStop('RT');
			}
			
			if (newX < 0)
				newX = 0;
				
			if (newY < 0)
				newY = 0;
				
			item.x = newX;
			item.y = newY;
		}
		
		//caculate the start position
		private function getPosition(inStyle:String,outStyle:String):void
		{
			item.stx = getXPosition(inStyle);
			item.sty = getYPosition(inStyle);
			
			item.edx = getXPosition(outStyle,false);
			item.edy = getYPosition(outStyle,false);
		}
		
		//return the x pos
		private function getXPosition(style:String,bIn:Boolean=true):Number
		{
			var n:Number = parseInt(style);
			
			if (n > 0 && n <= 360)//全方向的计算方法有所不同,是按半径算的,以成为圆形
				return item.x + ZoomeComment.RADIUS * Math.cos(-n / 180 * Math.PI);
				
			if(!bIn)
				switch(style)
				{
					case 'left':
						return -W;
					case 'right':
						return screenW;
					case 'drop':
					case 'rise':
						return item.x;
					default:
						return 0;
				}
			else
				switch(style)
				{
					case 'left':
						return screenW;
					case 'right':
						return -W;
					case 'drop':
					case 'rise':
						return item.x;
					default:
						return 0;
				}
			return 0;
			
		}
		
		//return the y pos
		private function getYPosition(style:String,bIn:Boolean=true):Number
		{
			//trace("style : " + style);
			var n:Number = parseInt(style);
			
			if (n > 0 && n <= 360)//全方向的计算方法有所不同,是按半径算的,以成为圆形
				return item.y + ZoomeComment.RADIUS * Math.sin(-n / 180 * Math.PI);

			if(bIn)
				switch(style)
				{
					case 'drop':
						return -H;
					case 'rise':
						return screenH;
					case 'left':
					case 'right':
						return item.y;
					default:
						return 0;
				}
			else
				switch(style)
				{
					case 'drop':
						return screenH;
					case 'rise':
						return -H;
					case 'left':
					case 'right':
						return item.y;
					default:
						return 0;
				}
				
			return 0;
			
		}
	}

}