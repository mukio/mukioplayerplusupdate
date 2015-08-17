////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package org.lala.components.skins
{

import flash.display.GradientType;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

public class ScrollTrackSkin extends Border
{
	public function ScrollTrackSkin()
	{
		super(); 
	}
	
	/**
	 *  @private
	 */    
	override public function get measuredWidth():Number
	{
		return 8;
	}
	
	//----------------------------------
	//  measuredHeight
	//----------------------------------
	
	/**
	 *  @private
	 */        
	override public function get measuredHeight():Number
	{
		return 1;
	}
	
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		// User-defined styles.
		var fillColors:Array = getStyle("trackColors");
        styleManager.getColorNames(fillColors);
		
		var borderColor:uint =
			ColorUtil.adjustBrightness2(getStyle("borderColor"), -20);
		
		var borderColorDrk1:uint =
			ColorUtil.adjustBrightness2(borderColor, -30);
		
		graphics.clear();
		
		var fillAlpha:Number = 1;
		
		if (name == "trackDisabledSkin")
			fillAlpha = .2;
		
		// border
		/**
		drawRoundRect(
			0, 0, w, h, 0,
			0xCCCCCC, 1); 
		**/
		// fill
		drawRoundRect(
			1, 1, w - 2, h - 2, 0,
			0xFFFFFF, 1); 
	}
}

}
