package org.lala.utils
{

    import flash.events.EventDispatcher;
    import flash.net.SharedObject;
    
    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.collections.SortField;

    /**
     * 弹幕过滤器类,把原来的文件改改就拿来用了
     * @author aristotle9
     **/
    public class CommentFilter extends EventDispatcher
    {
        /** 过滤器数据数组 **/
        private var fArr:ArrayCollection;
        private var ids:int = 0;
        
        private static var Mode:Array = ['mode', 'color', 'text'];
        
        [Bindable(event="enableChange")]
        public var bEnable:Boolean = true;
        [Bindable(event="regChange")]
        public var bRegEnable:Boolean = false;
        [Bindable(event="whiteListChange")]
        public var bWhiteList:Boolean = false;
        
        private static var instance:CommentFilter;
        
        public function CommentFilter() 
        {
            if(instance != null)
            {
                throw new Error("class CommentFilter is a Singleton,please use getInstance()");
            }
            
            fArr = new ArrayCollection();
            var sort:Sort = new Sort();
            sort.fields = [new SortField('mode')];
            fArr.sort = sort;
            
            loadFromSharedObject();
        }
        public function get filterSource():ArrayCollection
        {
            return fArr;
        }
        /** 单件 **/
        public static function getInstance():CommentFilter
        {
            if(instance == null)
            {
                instance = new CommentFilter();
            }
            return instance;
        }
        public function setEnable(id:int, enable:Boolean):void
        {//because delete operate makes some fArr[id] to null,so has to search over
            for (var i:int = 0; i < fArr.length; i++)
            {
                if (fArr[i].id == id)
                {
                    fArr[i].enable = enable;
                    return;
                }
            }
        }
        public function deleteItem(id:int):void
        {//because delete operate makes some fArr[id] to null, so has to search over
            for (var i:int = 0; i < fArr.length; i++)
            {
                if (fArr[i].id == id)
                {
                    fArr.removeItemAt(i);
                    return;
                }
            }
        }
        public function savetoSharedObject():void
        {
            trace("savetoSharedObject");
            try
            {
                var cookie:SharedObject = SharedObject.getLocal("MukioPlayer", '/');
                cookie.data['CommentFilter'] = toString();
                cookie.flush();
            }
            catch (e:Error) { };
        }
        public function loadFromSharedObject():void
        {
            try
            {
                var cookie:SharedObject = SharedObject.getLocal("MukioPlayer", '/');
                fromString(cookie.data['CommentFilter']);
            }catch (e:Error) { };
        }
        
        override public function toString():String
        {
            var a:Array = [];
            a.push(fArr.source,bEnable,bRegEnable,bWhiteList);
            return JSON.stringify(a);
        }
        
        public function fromString(source:String):void
        {
            try
            {
                var a:Array = JSON.parse(source) as Array;
                fArr = new ArrayCollection(a[0]);
                bEnable = a[1];
                bRegEnable = a[2];
                bWhiteList = a[3];
            } catch(e:Error){}
        }
        
        public function addItem(keyword:String,enable:Boolean=true):void
        {
            var mod:int;
            var exp:String;
            
            if (keyword.length < 3)
            {
                mod = 2;
                exp = keyword;
            }
            else
            {
                var head:String = keyword.substr(0, 2);
                exp = keyword.substr(2);
                switch(head)
                {
                    case 'm=':
                        mod = 0;
                        break;
                    case 'c=':
                        mod = 1;
                        break;
                    case 't=':
                        mod = 2;
                        break;
                    default:
                        mod = 2;
                        exp = keyword;
                        break;
                }
            }
            add(mod, exp, keyword,enable);
            fArr.refresh();
        }
        private function add(mode:int, exp:String, data:String,enable:Boolean=true):void
        {
			//扫描现有关键字串。
			var expString:String = String(exp).replace(/(\^|\$|\\|\.|\*|\+|\?|\(|\)|\[|\]|\{|\}|\||\/)/g,'\\$1');
			for(var i:String in fArr)
			{
				if(fArr[i].data == data && fArr[i].normalExp == expString && fArr[i].mode == mode)
				{
					return;
				}
			}
            fArr.addItem( { 'mode':mode,
                'data':data,
                'exp':exp,
                'normalExp':expString,
                'id':ids++,
                'enable':enable} );
        }
        /**
         * 校验接口
         * @param item 弹幕数据
         * @return 通过校验允许播放时返回true
         **/
        public function validate(item:Object):Boolean
        {
            if (!bEnable)
            {
                return true;
            }
            var res:Boolean = !bWhiteList;
            for (var i:int = 0; i < fArr.length; i++)
            {
                var tmp:Object = fArr[i];
                if (!tmp.enable)
                {
                    continue;
                }
                if (tmp.mode == 0)
                {
                    if (tmp.exp == String(item.mode))
                    {
                        res = bWhiteList;
                        break;
                    }
                }
                else if (tmp.mode == 1)
                {
                    if (parseInt(tmp.exp, 16) == item.color)
                    {
                        res = bWhiteList;
                        break;
                    }
                }
                else
                {
                    if (bRegEnable)
                    {
                        if (String(item.text).search(tmp.exp) != -1)
                        {
                            res = bWhiteList;
                            break;
                        }
                    }
                    else
                    {
                        if (String(item.text).search(tmp.normalExp) != -1)
                        {
                            res = bWhiteList;
                            break;
                        }
                    }
                }
            }
            return res;
        }
    }
}