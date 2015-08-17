package org.lala.components
{
	import mx.core.UIComponent;
	import flash.display.Graphics;
	
	public class DataGridHeaderSkin extends UIComponent
	{
		public function DataGridHeaderSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void 
		{
			var g:Graphics = graphics;
			
			g.clear();
			g.beginFill(0xFFFFFF);
			g.drawRect(0,0,width,height);
			g.lineStyle(1,0xDDDDDD);
			g.moveTo(0,unscaledHeight - 0.5);
			g.lineTo(unscaledWidth,unscaledHeight - 0.5);
			g.endFill();
		}
	}
}