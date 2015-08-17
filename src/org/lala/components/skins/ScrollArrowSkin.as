////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package org.lala.components.skins
{

import flash.display.GradientType;
import flash.display.Graphics;
import mx.controls.scrollClasses.ScrollBar;
import mx.skins.Border;
import mx.styles.StyleManager;
import mx.utils.ColorUtil;

/**
 *  The skin for all the states of the up or down button in a ScrollBar.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class ScrollArrowSkin extends Border
{
	public function ScrollArrowSkin()
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
		return 8;
	}
	

	
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		// User-defined styles.

		var upArrow:Boolean = (name.charAt(0) == 'u');
		
		/***
		if (upArrow && !horizontal)
			borderColors =  [ borderColor, derStyles.borderColorDrk1 ];
		else
			borderColors = [ derStyles.borderColorDrk1,
							 derStyles.borderColorDrk2 ];
		***/
		
		var g:Graphics = graphics;
		g.clear();
		
		// Opaque backing to force the scroll elements
		// to match other components by default.
		drawRoundRect(
			0, 0, w, h, 0,
			0xFFFFFF, 1);

		switch (name)
		{
			case "upArrowUpSkin":
			case "downArrowUpSkin":
			{
   				/***
				var upFillColors:Array = [ fillColors[0], fillColors[1] ];
   				var upFillAlphas:Array = [ fillAlphas[0], fillAlphas[1] ];

				// border
				drawRoundRect(
					0, 0, w, h, 0,
					borderColors, 1);  

				// fill
				drawRoundRect(
					1, 1, w - 2, h - 2, 0,
					upFillColors, upFillAlphas);
				**/
				break;
			}
			
			case "upArrowOverSkin":
			case "downArrowOverSkin":
			{
				/**
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

				// white backing to force the scroll elements
				// to match other components by default
				drawRoundRect(
					0, 0, w, h, 0,
					0xFFFFFF, 1);  

				// border
				drawRoundRect(
					0, 0, w, h, 0,
					themeColor, 1); 

				// fill
				drawRoundRect(
					1, 1, w - 2, h - 2, 0,
					overFillColors, overFillAlphas); 
				**/
				break;
			}
			
			case "upArrowDownSkin":
			case "downArrowDownSkin":
			{
				/**
				// border
				drawRoundRect(
					0, 0, w, h, 0,
					 themeColor, 1); 

				// fill
				drawRoundRect(
					1, 1, w - 2, h - 2, 0,
					0xFFFFFF,1 ); 
				**/
				break;
			}
			
			case "upArrowDisabledSkin":
			case "downArrowDisabledSkin":
			{
				/**
   				var disFillColors:Array = [ fillColors[0], fillColors[1] ];
   				var disFillAlphas:Array = [ fillAlphas[0] - 0.15, fillAlphas[1] - 0.15 ];

				// border
				drawRoundRect(
					0, 0, w, h, 0,
					borderColors, 0.5);  

				// fill
				drawRoundRect(
					1, 1, w - 2, h - 2, 0,
					disFillColors, disFillAlphas);

				arrowColor = getStyle("disabledIconColor");
				**/
				break;
			}
			
			default:
			{
				drawRoundRect(
					0, 0, w, h, 0,
					0xFFFFFF, 0);
				
				return;
				break;
			}
		}

		// Draw up or down arrow
		g.beginFill(0xCCCCCC);
		if (upArrow)
		{
			g.moveTo(w / 2+1, 1);
			g.lineTo(w - 1+1, h - 1);
			g.lineTo(1+1, h - 1);
			g.lineTo(w / 2+1, 1);
		}
		else
		{
			g.moveTo(w / 2+1, h - 1);
			g.lineTo(w - 1+1, 1);
			g.lineTo(1+1, 1);
			g.lineTo(w / 2+1, h - 1);
		}
		g.endFill();
	}
}

}
