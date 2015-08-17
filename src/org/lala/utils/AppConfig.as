package org.lala.utils
{
    import flash.net.SharedObject;

    /** 不能在配置界面设置的配置,存储于本地,也可以从flashvars传入 **/
    public class AppConfig
    {
        /** 默认的配置,及配置键 **/
        protected var _config:Object=
            {
              'state':'normal'
            };
        /**
        * @param _params 用来初始化的loadInfo
        **/
        public function AppConfig(_params:Object=null)
        {
            load(_params);
        }
        /**
        * 分别从loadInfo和sharedObject中加载配置.
        * 前者可以覆盖后者
        **/
        protected function load(_params:Object=null):void
        {
            var oldConfig:Object = null;
            try
            {
                var so:SharedObject = SharedObject.getLocal('MukioPlayer','/');
                var localConfig:Object= so.data['PlayerConfig'];
                if(localConfig)
                {
                    oldConfig = localConfig;
                }
            }
            catch(e:Error){}
            
            for(var k:String in _config)
            {
                if(oldConfig != null &&  oldConfig[k] != null)
                {
                    _config[k] = oldConfig[k];
                }
                if(_params != null && _params[k] != null)
                {
                    _config[k] = _params[k];
                }
            }
        }
        /**
        * 将配置保存在本地
        **/
        protected function save():void
        {
            try
            {
                var so:SharedObject = SharedObject.getLocal('MukioPlayer','/');
                so.data['PlayerConfig'] = _config;
                so.flush();
            }
            catch(e:Error){}   
        }
        /**
        * 播放器的布局状态
        **/
        public function get state():String
        {
            return _config['state'];
        }
        public function set state(value:String):void
        {
            if(value != _config['state'])
            {
                _config['state'] = value;
                save();
            }
        }
    }
}