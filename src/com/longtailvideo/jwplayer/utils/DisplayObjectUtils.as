package com.longtailvideo.jwplayer.utils {
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	
	
	
	public class DisplayObjectUtils {
		
		public static function enumerateChildren(displayObject:DisplayObjectContainer):void{
			try {
				for (var i:Number = 0 ; i < displayObject.numChildren; i++){
					Logger.log(displayObject.getChildAt(i).name+":"+flash.utils.getQualifiedClassName(displayObject.getChildAt(i)));
				}
			} catch (err:Error){
				
			}
		}

		public static function describeDisplayObject(displayObject:DisplayObject, depth:Number=0):String {
			var descString:String = " ";
			for(var i:Number=0; i<=depth; i++) { descString += "-"; }
			descString += displayObject.name + " = {" +
				"width:" + displayObject.width + ", " +
				"height:" + displayObject.height + ", " +
				"x:" + displayObject.x + ", " +
				"y:" + displayObject.y + "}";
			
			var displayObjectContainer:DisplayObjectContainer = displayObject as DisplayObjectContainer;  
			if (displayObjectContainer) {
				for(var j:Number=0; j<displayObjectContainer.numChildren; j++) {
					descString += "\n" + describeDisplayObject(displayObjectContainer.getChildAt(j), depth+1);
				}
			}
			
			return descString;
			
		}

	}
}