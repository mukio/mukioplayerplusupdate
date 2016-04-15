package org.lala.utils
{
	public class ApplicationConstants extends Object
	{
		import flash.system.Capabilities;
		import flash.text.Font;
		
		public function ApplicationConstants()
		{
			super();
		}
		
		public static function getDefaultFont() : String {
			var _loc1_:Array = null;
			if(Capabilities.os.indexOf("Linux") != -1)
			{
				_loc1_ = getCommentFontList();
				if(_loc1_.indexOf("WenQuanYi Micro Hei") !== -1)
				{
					return "WenQuanYi Micro Hei";
				}
				if(_loc1_.length >= 1)
				{
					return _loc1_[0];
				}
				return "sans";
			}
			if(Capabilities.os.indexOf("Mac") != -1)
			{
				return "Hei";
			}
			return "SimHei";
		}
		
		public static function doesChangeUIFont() : Boolean {
			if(Capabilities.os.indexOf("Linux") != -1)
			{
				return true;
			}
			if(Capabilities.os.indexOf("Mac") != -1)
			{
				return true;
			}
			return false;
		}
		
		public static function getCommentFontList() : Array {
			var _loc3_:Font = null;
			var _loc1_:Array = [];
			var _loc2_:RegExp = new RegExp("[一-龥]|hei|kai","i");
			for each(_loc3_ in Font.enumerateFonts(true))
			{
				if(_loc3_.fontName.match(_loc2_))
				{
					_loc1_.push(_loc3_.fontName);
				}
			}
			return _loc1_;
		}
	}
}