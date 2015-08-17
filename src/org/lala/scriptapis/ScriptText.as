package org.lala.scriptapis
{
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import org.lala.event.EventBus;
    import org.lala.plugins.CommentView;
    import org.lala.utils.CommentConfig;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Quadratic;
    import org.libspark.betweenas3.tweens.ITween;
    
    /**
     * 脚本使用的文本类,提供基本样式操作,控制权完全交给脚本
     * 还没有想到把文本放在哪一层????
     **/
    public class ScriptText implements IScript
    {
        private var _text:TextField;
        private var _name:String;
        private var config:CommentConfig = CommentConfig.getInstance();
        private var _format:TextFormat;
        private var _size:int;
        private var _tween:ITween;
        
        public function ScriptText(nm:String,str:String)
        {
            _text = new TextField();
            _text.autoSize = 'left';
            _format = new TextFormat(config.font,25,0xffffff,config.bold);
            _text.defaultTextFormat = _format;
            _name = nm;
            _text.text = str;
        }
        
        public function get help():String
        {
            return "弹幕文本类";
        }
        public function show():void
        {
            if(_text.parent == null)
            {
                CommentView.getInstance().clip.addChild(_text);
            }
        }
        /**
        * 只是不显示对象,
        * 要完全删除请使用Display.clean();
        **/
        public function hide():void
        {
            if(_text.parent)
            {
                CommentView.getInstance().clip.removeChild(_text);
            }            
        }
        /**
        * 移动
        * 例子:
        var t = Display.createText('t','Text');
        t.show();
        t.moveTo(200,200,1,function(){t.moveTo(200,400);});
        **/
        public function moveTo(x:int,y:int,duration:Number = 1,foo:Function=null):void
        {
            if(_tween && _tween.isPlaying)
            {
                _tween.stop();
            }
            _tween = BetweenAS3.tween(_text,{x:x,y:y},{x:_text.x,y:_text.y},duration,Quadratic.easeOut);
            _tween.onComplete = function():void
            {
                if(foo != null)
                {
                    foo.apply(null,[]);
                }
            };
            _tween.play();
        }
        /**
        * 补间功能
        * 使用目标对象,先过滤属性,再执行
        * 与moveTo使用相同的补间对象
        * 例子:
        var t = Display.createText('t','Text');
        t.show();
        t.tween({x:200,y:200,size:40,alpha:0.3,color:0xff0000},1,function(){t.tween({x:200,y:400,alpha:1});});
        **/
        public function tween(target:Object,duration:Number = 1,foo:Function=null):void
        {
            var properties:Object = {
                x:'',
                y:'',
                size:'',
                alpha:'',
                color:''
            };
            var to:Object = {};
            var from:Object = {};
            var i:int = 0;
            for(var k:String in properties)
            {
                if(target[k] != null)
                {
                    to[k] = target[k];
                    from[k] = this[k];
                    i++;
                }
            }
            if(i == 0)
            {
                EventBus.getInstance().log('目标为空,不执行任何动作.');
                return;
            }
            if(_tween && _tween.isPlaying)
            {
                _tween.stop();
            }
            _tween = BetweenAS3.tween(this,to,from,duration,Quadratic.easeOut);
            _tween.onComplete = function():void
            {
                if(foo != null)
                {
                    foo.apply(null,[]);
                }
            };
            _tween.play();
        }
        public function set text(value:String):void
        {
            _text.text = value;
        }
        public function get text():String
        {
            return _text.text;
        }
        
        public function set color(value:int):void
        {
            _format.color = value;
            _text.setTextFormat(_format);
        }
        public function get color():int
        {
            return int(_text.defaultTextFormat.color);
        }

        public function get alpha():Number
        {
            return _text.alpha;
        }

        public function set alpha(value:Number):void
        {
            _text.alpha = value;
        }

        public function get name():String
        {
            return _name;
        }

        public function get x():int
        {
            return _text.x;
        }

        public function set x(value:int):void
        {
            _text.x = value;
        }

        public function get y():int
        {
            return _text.y;
        }

        public function set y(value:int):void
        {
            _text.y = value;
        }

        public function get size():int
        {
            return int(_text.defaultTextFormat.size);
        }

        public function set size(value:int):void
        {
            _format.size = value;
            _text.setTextFormat(_format);
        }


    }
}