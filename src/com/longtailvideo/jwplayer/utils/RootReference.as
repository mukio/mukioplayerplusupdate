package com.longtailvideo.jwplayer.utils {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.system.Security;

	/**
	 * Maintains a static reference to the stage and root of the application.
	 *
	 * @author Pablo Schklowsky
	 */
	public class RootReference {

		/** The root DisplayObject of the application.  **/ 
		public static var root:DisplayObjectContainer;

		/** A reference to the stage. **/ 
		private static var _stage:Stage;
        
        /** parameters,controlled by application **/
        public static var parameters:Object;
		
		public static function get stage():Stage {
			return _stage;
		}

		public static function set stage(s:Stage):void  {
			_stage = s;
		}

		public function RootReference(displayObj:DisplayObjectContainer,params:Object=null) {
			if (!RootReference.root) {
//				RootReference.root = displayObj.root;
//				RootReference.stage = displayObj.stage;
				RootReference.root = displayObj;
				RootReference.stage = displayObj.stage;
                RootReference.parameters = params;
				try {
					Security.allowDomain("*");
				} catch(e:Error) {
					// This may not work in the AIR testing suite
				}
			}
		}
	}
}