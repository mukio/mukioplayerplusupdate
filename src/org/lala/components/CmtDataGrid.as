package org.lala.components
{
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    
    import mx.controls.DataGrid;
    import mx.controls.listClasses.ListBaseContentHolder;
    import mx.core.FlexShape;
    /** 弹幕列表DataGrid **/
    public class CmtDataGrid extends DataGrid
    {
        public function CmtDataGrid()
        {
            super();
        }
        /** 自定义一下行的颜色,脚本弹幕突出显示 **/
        override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
        {
            var contentHolder:ListBaseContentHolder = ListBaseContentHolder(s.parent);
            var background:Shape;
            if (rowIndex < s.numChildren)
            {
                background = Shape(s.getChildAt(rowIndex));
            }
            else
            {
                background = new FlexShape();
                background.name = "background";
                s.addChild(background);
            }
            
            background.y = y;
            
            // Height is usually as tall is the items in the row, but not if
            // it would extend below the bottom of listContent
            var height:Number = Math.min(height,
                contentHolder.height -
                y);
            
            var g:Graphics = background.graphics;
            g.clear();
            
            var color2:uint;
			color2 = 0xFFFFFF;
            if(dataIndex<this.dataProvider.length)
            {;	
                if(String(this.dataProvider.getItemAt(dataIndex).mode) == '10')
                {
                    color2 = 0xFFE2FB ;
                }
                else
                {
                    color2 = 0xFFFFFF;
                }
            }
            else
            {
                color2 = 0xFFFFFF;
            }
            g.beginFill(color2, getStyle("backgroundAlpha"));
            g.drawRect(0, 0, contentHolder.width, height);
            g.endFill();
        }
    }
}