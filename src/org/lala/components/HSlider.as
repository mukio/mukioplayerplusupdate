package org.lala.components
{
		
			import  org.lala.components.skins.HSliderSkin;
			
			import flash.events.Event;
			import flash.events.MouseEvent;
			import flash.geom.Point;
			
			import mx.core.InteractionMode;
			import mx.events.ResizeEvent;
			
			import spark.components.Button;
			import spark.components.HSlider;
			import spark.effects.animation.Animation;
			
			/**
			 *  The color for the slider track when it is selected.
			 *  
			 *  @langversion 3.0
			 *  @playerversion Flash 10
			 *  @playerversion AIR 1.5
			 *  @productversion Flex 4
			 */
			[Style(name="accentColor", type="uint", format="Color", inherit="yes", theme="spark")]
			
			/**
			 *  Specifies whether to enable track highlighting between thumbs
			 *  (or a single thumb and the beginning of the track).
			 *
			 *  @default false
			 *  
			 *  @langversion 3.0
			 *  @playerversion Flash 10
			 *  @playerversion AIR 1.5
			 *  @productversion Flex 4
			 */
			[Style(name="showTrackHighlight", type="Boolean", inherit="no")]
			
			public class HSlider extends spark.components.HSlider
			{
				/**
				 *  @private
				 */
				private var animator:Animation = null;
				
				[SkinPart(required="false")]
				public var trackHighLight:Button;
				
				[Bindable]
				private var _accentColor:uint;
				private var accentColorChanged:Boolean
				
				[Bindable]
				private var _showTrackHighlight:Boolean = true;
				private var showTrackHighlightChanged:Boolean;
				
				public function HSlider()
				{
					super();
					setStyle("skinClass", HSliderSkin);
				}
				
				
				/**
				 *  @private
				 */
				override protected function updateSkinDisplayList():void
				{
					super.updateSkinDisplayList();
					if (!thumb || !track || !trackHighLight)
						return;
					
					var thumbRange:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
					var range:Number = maximum - minimum;
					
					// calculate new thumb position.
					var thumbPosTrackX:Number = (range > 0) ? ((pendingValue - minimum) / range) * thumbRange : 0;
					
					// convert to parent's coordinates.
					var thumbPos:Point = track.localToGlobal(new Point(thumbPosTrackX, 0));
					var thumbPosParentX:Number = thumb.parent.globalToLocal(thumbPos).x+thumb.getLayoutBoundsWidth()/2;
					
					//thumb.setLayoutBoundsPosition(Math.round(thumbPosParentX), thumb.getLayoutBoundsY());
					trackHighLight.setLayoutBoundsSize(Math.round(thumbPosParentX), trackHighLight.getLayoutBoundsHeight());
				}
				
				/**
				 *  @private
				 *  Warning: the goal of the listeners added here (and removed below) is to 
				 *  give the TrackBase a change to fixup the thumb's size and position
				 *  after the skin's BasicLayout has run.   This particular implementation
				 *  is a hack and it begs a solution to the general problem of what we've
				 *  called "cooperative layout".   More about that here:
				 *  http://opensource.adobe.com/wiki/display/flexsdk/Cooperative+Subtree+Layout
				 */
				override protected function partAdded(partName:String, instance:Object):void
				{
					super.partAdded(partName, instance);
					
					if (instance == trackHighLight)
					{
						trackHighLight.focusEnabled = false;
						trackHighLight.addEventListener(ResizeEvent.RESIZE, trackHighLight_resizeHandler);
						
						// track is only clickable if in mouse interactionMode
						if (getStyle("interactionMode") == InteractionMode.MOUSE)
							trackHighLight.addEventListener(MouseEvent.MOUSE_DOWN, trackHighLight_mouseDownHandler);
					}
				}
				
				/**
				 *  @private
				 */
				override protected function partRemoved(partName:String, instance:Object):void
				{
					super.partRemoved(partName, instance);
					
					if (instance == trackHighLight)
					{
						trackHighLight.removeEventListener(MouseEvent.MOUSE_DOWN, trackHighLight_mouseDownHandler);
						trackHighLight.removeEventListener(ResizeEvent.RESIZE, trackHighLight_resizeHandler);
					}
				}
				
				/**
				 *  @private
				 *  Handle mouse-down events for the slider track hightlight. We
				 *  calculate the value based on the new position and then
				 *  move the thumb to the correct location as well as
				 *  commit the value.
				 */
				protected function trackHighLight_mouseDownHandler(event:MouseEvent):void
				{
					this.track_mouseDownHandler(event);
				}
				
				/**
				 *  @private
				 */
				private function trackHighLight_resizeHandler(event:Event):void
				{
					updateSkinDisplayList();
				}
				
				/**
				 *  @private
				 */
				override public function styleChanged(styleProp:String):void
				{
					var anyStyle:Boolean = styleProp == null || styleProp == "styleName";
					
					super.styleChanged(styleProp);
					if (styleProp == "showTrackHighlight" || anyStyle)
					{
						showTrackHighlightChanged = true;
						invalidateProperties();
					}
					
					if (styleProp == "accentColor" || anyStyle)
					{
						accentColorChanged = true;
						invalidateProperties();
					}
					
					invalidateDisplayList();
				}
				
				override protected function commitProperties():void
				{
					super.commitProperties();
					
					if (showTrackHighlightChanged)
					{
						this.trackHighLight.visible = this._showTrackHighlight;
						showTrackHighlightChanged = false;
					}
					if(accentColorChanged){
						this.trackHighLight.setStyle("themeColor", this.accentColor);
						accentColorChanged = false;
					}
				}
				
				public function set accentColor(color:uint):void
				{
					this._accentColor = color;
					accentColorChanged = true;
					this.invalidateProperties();
				}
				
				
				public function get accentColor():uint
				{
					return this._accentColor;
				}
				
				public function set showTrackHighlight(show:Boolean):void
				{
					this._showTrackHighlight = show;
					showTrackHighlightChanged = true;
					this.invalidateProperties();
				}
				
				public function get showTrackHighlight():Boolean
				{
					return this._showTrackHighlight;
				}
		}

}