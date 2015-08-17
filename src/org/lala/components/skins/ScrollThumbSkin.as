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

/**
 *  The skin for all the states of the thumb in a ScrollBar.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ScrollThumbSkin extends Border
{
	public function ScrollThumbSkin()
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
		return 10;
	}
	
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		// User-defined styles.
		var backgroundColor:Number = getStyle("backgroundColor");
		var borderColor:uint = getStyle("borderColor");
		var cornerRadius:Number = getStyle("cornerRadius");
		var fillAlphas:Array = getStyle("fillAlphas");
		var fillColors:Array = getStyle("fillColors");
        styleManager.getColorNames(fillColors);
		var highlightAlphas:Array = getStyle("highlightAlphas");				
		var themeColor:uint = getStyle("themeColor");
		
		// Placeholder styles stub.
		var gripColor:uint = 0x6F7777;
		
		// Derived styles.
		//var derStyles:Object = calcDerivedStyles(themeColor, borderColor,
												// fillColors[0], fillColors[1]);
		//var derStyles:Object;
			//derStyles.borderColorDrk1 = 0xDDDDDD;
												 
		var radius:Number = Math.max(cornerRadius - 1, 0);
		var cr:Object = { tl: 0, tr: radius, bl: 0, br: radius };
		radius = Math.max(radius - 1, 0);
		var cr1:Object = { tl: 0, tr: radius, bl: 0, br: radius };

		var horizontal:Boolean = parent &&
								 parent.parent &&
								 parent.parent.rotation != 0;

		if (isNaN(backgroundColor))
			backgroundColor = 0xFFFFFF;
		
		graphics.clear();
		
		// Opaque backing to force the scroll elements
		// to match other components by default.
		drawRoundRect(
			1, 0, w - 3, h, cr,
			backgroundColor, 1);                            

		switch (name)
		{
			default:
			case "thumbUpSkin":
			{
				// positioning placeholder
				drawRoundRect(
					1, 0, w, h, 0,
					0xFFFFFF, 0); 

				// shadow
				// border
				drawRoundRect(
					2, 0, w - 2, h, cr,
					0xCCCCCC, 1);  

				// fill
				drawRoundRect(
					2, 1, w - 3, h - 2, cr1,
					0xDDDDDD, 1); 

				// highlight
				/***
				if (horizontal)
				{
					drawRoundRect(
						1, 0, (w - 4) / 2, h - 2, 0,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas); 
				}
				else
				{
					drawRoundRect(
						1, 1, w - 4, (h - 2) / 2, cr1,
						[ 0xFFFFFF, 0xFFFFFF ], highlightAlphas); 
				}
				 * ***/
				break;
			}
			
			case "thumbOverSkin":
			{
				// positioning placeholder
				drawRoundRect(
					1, 0, w, h, 0,
					0xFFFFFF, 0); 

				// no shadow
								
				// border
				drawRoundRect(
					2, 0, w - 2, h, cr,
					0xCCCCCC, 1);

				// fill
				drawRoundRect(
					2, 1, w - 3, h - 2, cr1,
					0xCCCCCC, 1); 
				
				break;
			}
			
			case "thumbDownSkin":
			{				
				// no shadow
				// border
				drawRoundRect(
					2, 0, w - 2, h, cr,
					0xCCCCCC, 1);  

				// fill
				drawRoundRect(
					2, 1, w - 3, h - 2, cr1,
					0xBBBBBB,1); 
									
				break;
			}
			
			case "thumbDisabledSkin":
			{
				// positioning placeholder
				drawRoundRect(
					1, 0, w, h, 0,
					0xFFFFFF, 0); 
				
				// border
				drawRoundRect(
					2, 0, w - 2, h, cr,
					0xEEEEEE, 1);
				
				// fill
				drawRoundRect(
					2, 1, w - 3, h - 2, cr1,
					0xEEEEEE, 1);
				
				break;
			}
		}
		
		// Draw grip.
		
		/*** Draw grip your sister
		var gripW:Number = Math.floor(w / 2 - 4);
		
		drawRoundRect(
			gripW, Math.floor(h / 2 - 4), 5, 1, 0,
			0x000000, 0.4);
		
		drawRoundRect(
			gripW, Math.floor(h / 2 - 2), 5, 1, 0,
			0x000000, 0.4);
		
		drawRoundRect(
			gripW, Math.floor(h / 2), 5, 1, 0,
			0x000000, 0.4);
		
		drawRoundRect(
			gripW, Math.floor(h / 2 + 2), 5, 1, 0,
			0x000000, 0.4);

		drawRoundRect(
			gripW, Math.floor(h / 2 + 4), 5, 1, 0,
			0x000000, 0.4);
			 * **/
	}
}

}
