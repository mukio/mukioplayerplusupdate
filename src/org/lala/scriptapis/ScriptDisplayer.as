package org.lala.scriptapis
{
    import org.lala.event.EventBus;
    import org.lala.event.MukioEvent;

    /**
    * 弹幕相关的显示接口
    * 包括:脚本生成弹幕预览功能
    * 生成对象
    **/
    public class ScriptDisplayer implements IScript
    {
        private var _texts:Object={};
        
        private var _width:int = 540;    
        private var _height:int = 432;    

        public function get height():int
        {
            return _height;
        }

        public function get width():int
        {
            return _width;
        }

        public function ScriptDisplayer()
        {
        }
        
        public function get help():String
        {
            return "弹幕相关的显示接口Display:\n" +
                "width:i,height:i弹幕平面宽高\n" +
                "cmt(text:s,color:i,size:i|s,mode:s):void,预览一个普通弹幕\n" +
                "bili(...):void,预览一个bili的高级弹幕\n" +
                "bili2(...):void,预览一个bili的高级弹幕,高级版本\n" +
                "zoome(...):void,预览一个zoome弹幕,未完成\n" +
                "createText(...):ScriptText,生成一个ScriptText对象\n" +
                "text(name:String):ScriptText,按名称取得一个舞台上的ScriptText对象\n" +
                "removeText(name:*):void,按名称或者对象引用删除一个ScriptText对象,删除后名字清空,对象摧毁\n" +
                "clean():void,清空所有对象";
        }
        /**
        * 预览普通弹幕
        **/
        public function cmt(text:String,color:int=0xffffff,size:String='middle',mode:String='toLeft'):void
        {
            var data:Object = {
                type:'normal',
                preview:true,
                text:text,
                color:color,
                size:size,
                mode:mode
            };
            EventBus.getInstance().sendMukioEvent(MukioEvent.DISPLAY,data);
        }
        /** 
        * 预览bili弹幕,初阶版本
        * @param text 文本 
        * @param x x点坐标
        * @param y y点坐标
        * @param color 颜色
        * @param size 字号
        * @param rZ 旋转值
        * @param rY 翻转值
        * @param duration 总时间
        * @param inAlpha 起始透明
        * @param outAlpha 结束透明
        **/
        public function bili(text:String,x:int=0,y:int=0,color:int=0xffffff,size:int=25,rZ:int=0,rY:int=0,duration:Number=4.5,inAlpha:Number=1,outAlpha:Number=1):void
        {
            var data:Object = {};
            data.type = 'bili';
            data.mode = 7;
            data.preview = true;
            
            data.text = text;
            data.x = x;
            data.y = y;
            data.color = color;
            data.size = size;
            data.rZ = rZ;
            data.rY = rY;
            data.duration = duration;
            data.inAlpha = inAlpha;
            data.outAlpha = outAlpha;
            //未开启高级功能
            data.adv = false;

            EventBus.getInstance().sendMukioEvent(MukioEvent.DISPLAY,data);
        }
        /** 
        * 预览bili弹幕,高级版本
        * @param text 文本 
        * @param x x点坐标
        * @param y y点坐标
        * @param color 颜色
        * @param size 字号
        * @param rZ 旋转值
        * @param rY 翻转值
        * @param duration 总时间
        * @param inAlpha 起始透明
        * @param outAlpha 结束透明
        * @param toX 目标x点坐标
        * @param toY 目标y点坐标
        * @param mDuration 移动持续时间,毫秒 
        * @param delay 移动前停留,毫秒
        **/
        public function bili2(text:String,x:int=0,y:int=0,color:int=0xffffff,size:int=25,rZ:int=0,rY:int=0,duration:Number=4.5,inAlpha:Number=1,outAlpha:Number=1,
        toX:int=0,toY:int=0,mDuration:Number=500,delay:Number=0):void
        {
            var data:Object = {};
            data.type = 'bili';
            data.mode = 7;
            data.preview = true;
            
            data.text = text;
            data.x = x;
            data.y = y;
            data.color = color;
            data.size = size;
            data.rZ = rZ;
            data.rY = rY;
            data.duration = duration;
            data.inAlpha = inAlpha;
            data.outAlpha = outAlpha;
            //开启高级功能
            data.adv = true;
            data.toX = toX;
            data.toY = toY;
            data.mDuration = mDuration / 1000;
            data.delay = delay / 1000;

            EventBus.getInstance().sendMukioEvent(MukioEvent.DISPLAY,data);
        }
        /** 创建弹幕文本 **/
        public function createText(name:String,str:String):ScriptText
        {
            if(_texts[name])
            {
                removeText(name);
            }
            _texts[name] = new ScriptText(name,str);
            return _texts[name];
        }
        /** 按名称取得弹幕文本 **/
        public function text(name:String):ScriptText
        {
            return _texts[name];
        }
        /** 
        * 删除文本,删除名字
        * 知道一个文本变量,删除它的方法是Display.removeText(t.name);
        ***/
        public function removeText(name:String):void
        {
            var t:ScriptText;
            t = text(name);
            if(t)
            {
                t.hide();
                _texts[t.name] = null;
            }
        }
        /** 清空弹幕文本 **/
        public function clean():void
        {
            for(var k:String in _texts)
            {
                removeText(k);
            }
        }
    }
}