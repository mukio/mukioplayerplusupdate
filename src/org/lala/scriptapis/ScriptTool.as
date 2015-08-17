package org.lala.scriptapis
{
    import flash.utils.setTimeout;

    /** 常用工具集 **/
    public class ScriptTool implements IScript
    {
        public function ScriptTool()
        {
            //TODO: implement function
        }
        
        public function get help():String
        {
            //TODO: implement function
            return 'T,方便工具箱:\n' +
                'hue(v:i):i,0 360色环\n' +
                'repeat(n:i)(f:f):计数循环的一种形式\n';
        }
        /** hue 0-360 **/
        public function hue(v:int):int
        {
            var r:Array = [0,120,240];
            var g:Array = [124,240,360];
            var b:Array = [240,360,480];
            
            var rp:Number = 0;
            var gp:Number = 0;
            var bp:Number = 0;
            v = v % 360;
            
            if(v > r[0] && v < r[2])
            {
                rp = 100 - 50 * Math.abs(v - r[1]) / 120; 
            }
            
            if(v > g[0] && v < g[2])
            {
                gp = 100 - 50 * Math.abs(v - g[1]) / 120; 
            }
            
            if(v > b[0] && v <= b[1]) 
            {
                bp = 100 - 50 * Math.abs(v - b[1]) / 120; 
            }
            else if(v + 360 >= b[1] && v + 360 < b[2])
            {
                bp = 100 - 50 * Math.abs(v + 360 - b[1]) / 120; 
            }
            
            return int(rp * 0xff / 100) << 16 | int(gp * 0xff / 100) << 8 | int(bp * 0xff / 100);
        }
        /** 
        * 重复:
        * @example T.repeat(5)(function(i,n){p(i+','+n +' ');});
        **/
        public function repeat(n:int=1):Function
        {
            return function(foo:Function):void
            {
                var i:int = 0;
                for(; i < n; i++)
                {
                    foo.apply(null,[i,n]);
                }
            };
        }
        /**
        * 延迟
        * 例子:T.delay(1000)(function(){p(1);});T.delay(500)(function(){p(2);});
        * @param time 毫秒
        **/
        public function delay(time:Number=1000):Function
        {
            if(time <= 0 || time > 15 * 1000)
            {
                time = 1000;
            }
            return function(foo:Function):void
            {
                setTimeout(foo,time);
            };
        }
    }
}