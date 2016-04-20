package org.lala.components.skins
{
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.describeType;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.skins.Border;
	import mx.styles.IStyleClient;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	public class TabSkin extends Border
	{
		public function TabSkin()
		{
			super();
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			// User-defined styles.
			var backgroundAlpha:Number = getStyle("backgroundAlpha");		
			var backgroundColor:Number = getStyle("backgroundColor");
			var borderColor:uint = getStyle("borderColor");
			var cornerRadius:Number = getStyle("cornerRadius");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			styleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");		
			var themeColor:uint = getStyle("themeColor");
			
			// Placehold styles stub.
			var falseFillColors:Array = []; /* of Number*/ // added style prop
			falseFillColors[0] = ColorUtil.adjustBrightness2(fillColors[0], -5);
			falseFillColors[1] = ColorUtil.adjustBrightness2(fillColors[1], -5);
		
			var cornerRadius2:Number = Math.max(cornerRadius - 2, 0);
			var cr:Object = { tl: cornerRadius, tr: cornerRadius, bl: 0, br: 0 };
			var cr2:Object = { tl: cornerRadius2, tr: cornerRadius2, bl: 0, br: 0 };
			
			graphics.clear();
			
			switch (name)
			{
				case "upSkin":
				{
					var upFillColors:Array =
						[ falseFillColors[0], falseFillColors[1] ];
					
					var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];
					
					// outer edge
					drawRoundRect(
						0, 0, w, h - 1, cr,
						0xDDDDDD, 1); 
					
					// tab fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr2,
						0xFFFFFF, 1);
					
					break;
				}
					
				case "overSkin":
				{
					var overFillColors:Array;
					if (fillColors.length > 2)
						overFillColors = [ fillColors[2], fillColors[3] ];
					else
						overFillColors = [ fillColors[0], fillColors[1] ];
					
					var overFillAlphas:Array;
					if (fillAlphas.length > 2)
						overFillAlphas = [ fillAlphas[2], fillAlphas[3] ];
					else
						overFillAlphas = [ fillAlphas[0], fillAlphas[1] ];
					
					// outer edge
					drawRoundRect(
						0, 0, w, h - 1, cr,
						0xDDDDDD, 1);
					
					// tab fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr2,
						0xEEEEEE, 1);
					
					break;
				}
					
				case "disabledSkin":
				{
					var disFillColors:Array = [ fillColors[0], fillColors[1] ];
					
					var disFillAlphas:Array =
						[ Math.max( 0, fillAlphas[0] - 0.15),
							Math.max( 0, fillAlphas[1] - 0.15) ];
					
					// outer edge
					drawRoundRect(
						0, 0, w, h - 1, cr,
						0xDDDDDD, 0.5);
					
					// tab fill
					drawRoundRect(
						1, 1, w - 2, h - 2, cr2,
						0xDDDDDD, 1);
					
					break;
				}
					
				case "downSkin":
				case "selectedUpSkin":
				case "selectedDownSkin":
				case "selectedOverSkin":
				case "selectedDisabledSkin":
				{
					if (isNaN(backgroundColor))
					{
						// Walk the parent chain until we find a background color
						var p:DisplayObjectContainer = parent;
						
						while (p)
						{
							if (p is IStyleClient)
								backgroundColor = IStyleClient(p).getStyle("backgroundColor");
							
							if (!isNaN(backgroundColor))
								break;
							
							p = p.parent;
						}
						
						// Still no backgroundColor? Use white.
						if (isNaN(backgroundColor))
							backgroundColor = 0xFFFFFF;
					}
					
					// outer edge
					drawRoundRect(
						0, 0, w, h - 1, cr,
						0xDDDDDD, 1);
					
					// tab fill color
					drawRoundRect(
						1, 1, w - 2, h - 2, cr2,
						0xFFFFFF, 1);
					
					break;
				}
			}
		}

	}
}