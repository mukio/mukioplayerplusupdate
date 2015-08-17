package org.lala.components.skins
{
	import mx.skins.ProgrammaticSkin;
	import flash.display.Graphics;
	public class DataGridHeaderSeparator extends ProgrammaticSkin
	{
		public function DataGridHeaderSeparator()
		{
			super();
		}
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			var g:Graphics = graphics;
			
			g.clear();
			
			// Highlight
			g.lineStyle(1, 0xEEEEEE, 0.5);
			g.moveTo(0, 0);
			g.lineTo(0, h);
			g.lineStyle(1, 0xEEEEEE); 
			g.moveTo(1, 0);
			g.lineTo(1, h);
		}
	}
}