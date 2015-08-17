package org.lala.comments
{
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.filters.*;
    
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.events.TweenEvent;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Quad;
    import org.libspark.betweenas3.easing.Linear;

    /** bili新弹幕的表现类 **/
    public class FixedPosComment extends TextField implements IComment
    {
        /** 完成地调用的函数,无参数 **/
        protected var _complete:Function;
        /** 配置数据 **/
        protected var item:Object;
        /** 动作补间 **/
        private var _tw:ITween;
        /** 构造函数 **/
        public function FixedPosComment(data:Object)
        {
            /** 复制配置 **/
            item = {};
            for (var key:String in data)
            {
                item[key] = data[key]
            }
            init();
        }
        /** 开始播放 **/
        public function start():void
        {
            this.visible = true;
            this._tw.play();
        }
        /** 暂停 **/
        public function pause():void
        {
            this._tw.stop();
        }
        /** 恢复播放 **/
        public function resume():void
        {
            this._tw.play();
        }
        /**
         * 设置完成播放时调用的函数,调用一次仅一次
         * @param	foo 完成时调用的函数,无参数
         */
        public function set complete(foo:Function):void
        {
            this._complete = foo;
        }
        /**
         * 初始化,由构造函数最后调用
         */
        protected function init():void
        {
            this.visible = false;
            this.x = item.x;
            this.y = item.y;
            if (item.rY != 0 || item.rZ != 0)
            {
                this.rotationY = item.rY;
                this.rotationZ = item.rZ;
            }
            this.alpha = item.inAlpha;
            this.autoSize = 'left';
            this.filters =  [new GlowFilter(0, 0.7, 3,3)];
            this.defaultTextFormat = new TextFormat('simhei', item.size, item.color, false);
            this.text = item.text;
            var tw1:ITween = BetweenAS3.tween(this, { alpha:item.outAlpha }, { alpha:item.inAlpha }, item.duration, Quad.easeIn);
            if (!item.adv)
            {
                this._tw = tw1;
            } 
            else 
            {
                var tw2:ITween = BetweenAS3.tween(this, { x:item.toX, y:item.toY }, { x:item.x, y:item.y }, item.mDuration, Linear.easeIn);
                this._tw = BetweenAS3.parallel(tw1, BetweenAS3.delay(tw2, item.delay));
            }
            this._tw.addEventListener(TweenEvent.COMPLETE, completeHandler);
        }
        /**
         * 结束事件监听
         */
        private function completeHandler(event:TweenEvent):void
        {
            this._complete();
        }
    }
}