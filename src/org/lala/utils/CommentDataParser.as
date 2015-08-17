package org.lala.utils
{

    
    /**
     * 弹幕文件解析,编码类
     * 因兼容原来的弹幕格式缘故,解析代码有相似性.
     **/
    public class CommentDataParser
    {
        /** 弹幕计数 **/
        public static var length:Number = 0;
        /** 
         * 解析旧的acfun弹幕文件
         * @param xml 弹幕文件的xml
         * @param foo 对单个弹幕数据的处理函数:第一个参数为消息名,用来分类弹幕,第二个参数为data:Object
         **/
        public static function acfun_parse(xml:XML,foo:Function):void
        {
            var list:XMLList = xml.data;
            for each(var item:XML in list)
            {
                var obj:Object ={};
                obj.color = uint(item.message.@color);
                obj.size = uint(item.message.@fontsize);
                obj.mode = uint(item.message.@mode);
                obj.stime = parseFloat(item.playTime);
                obj.date = item.times;
                obj.text = text_string(item.message);
                obj.border = false;
                obj.user = null;
                obj.id = length ++;
                foo(String(obj.mode),obj);
            }
        }
        /** 
         * 解析新的acfun弹幕文件
         * @param xml 弹幕文件的xml
         * @param foo 对单个弹幕数据的处理函数:第一个参数为消息名,用来分类弹幕,第二个参数为data:Object
         **/
        public static function acfun_new_parse(xml:XML,foo:Function):void
        {
            var list:XMLList = xml.l;
            for each(var item:XML in list)
            {
                try{
                    var obj:Object ={};
                    var attrs:Array = String(item.@i).split(',');
                    obj.stime = parseFloat(attrs[0]);
                    obj.size = uint(attrs[1]);
                    obj.color = uint(attrs[2]);
                    obj.mode = uint(attrs[3]);
                    obj.date = date(new Date(parseInt(attrs[5])));
					obj.Fdate = fullDate(new Date(parseInt(attrs[5])));//创建长与短的时间类型
                    obj.author = attrs[4];
                    obj.text = text_string(item);
                    obj.border = false;
                    obj.id = length ++;
                    foo(String(obj.mode),obj);
                } catch (e:Error) {}
            }
        }
        /** 解析bili的常用数据 **/
        public static function bili_parse(xml:XML,foo:Function):void
        {
            var list:XMLList = xml.d;
            for each(var item:XML in list)
            {
                var attrs:Array = String(item.@p).split(',');
                var obj:Object ={};
                obj.stime = parseFloat(attrs[0]);
                obj.mode = uint(attrs[1]);
                obj.size = uint(attrs[2]);
                obj.color = uint(attrs[3]);
                obj.date = date(new Date(attrs[4] * 1000));
				obj.Fdate = fullDate(new Date(attrs[4] * 1000)); //创建长与短的时间类型				
                obj.border = false;
                obj.id = length ++;
                
                if (obj.mode < 7)
                {
                    obj.text = text_string(item);
                }
                else if (obj.mode == 7)
                {
                    try
                    {
                        var json:Object = JSON.parse(item);
                        obj.x = Number(json[0]);
                        obj.y = Number(json[1]);
                        obj.text = text_string(json[4]);
                        obj.rZ = obj.rY = 0;
                        if (json.length >= 7)
                        {
                            obj.rZ = Number(json[5]);
                            obj.rY = Number(json[6]);
                        }
                        obj.adv = false;//表示是无运动的弹幕
                        if (json.length >= 11)
                        {
                            obj.adv = true;//表示是有运动的弹幕
                            obj.toX = Number(json[7]);
                            obj.toY = Number(json[8]);
                            obj.mDuration = 0.5;//默认移动时间,单位秒
                            obj.delay = 0;//默认移动前的暂停时间
                            if (json[9] != '')
                            {
                                obj.mDuration = Number(json[9]) / 1000;
                            }
                            if (json[10] != '')
                            {
                                obj.delay = Number(json[10]) / 1000;
                            }
                        }
                        obj.duration = 2.5;
                        if (json[3] < 12 && json[3] != 1) {
                            obj.duration = Number(json[3]);
                        }
                        obj.inAlpha = obj.outAlpha = 1;
                        var aa:Array = String(json[2]).split('-');
                        if (aa.length >= 2)
                        {
                            obj.inAlpha = Number(aa[0]);
                            obj.outAlpha = Number(aa[1]);
                        }
                    } catch (e:Error) 
                    {
                        trace('不是良好的JSON格式:' + item);
                        continue;
                    }
                }
                else if(obj.mode == 9)
                {
                    try
                    {
                        var appendattr:Object = JSON.parse(item);
                        obj.text = text_string(appendattr[0]);
                        obj.x = appendattr[1];
                        obj.y = appendattr[2];
                        obj.alpha = appendattr[3];
                        obj.style = appendattr[4];
                        obj.duration = appendattr[5];
                        obj.inStyle = appendattr[6];
                        obj.outStyle = appendattr[7];
                        obj.position = appendattr[8];
                        obj.tStyle = appendattr[9];
                        obj.tEffect = appendattr[10];
                        foo(obj.style + obj.position, obj);
                    }
                    catch (error:Error)
                    {
                        trace('JSON decode failed!');
                    }
                    continue;
                }
                else if (obj.mode == 10)
                {
                    //脚本弹幕,假设服务器使用bili的格式来产生弹幕
                    obj.text = item;
                }
                foo(String(obj.mode),obj);
            }
        }
        /** 弹幕数据简单序列化
        *   输入:消息队列中的弹幕实体
        *   输出:与基本弹幕类似的结构,方便使用旧的数据存储服务器 
        **/
        public static function data_format(item:Object):Object
        {
            var data:Object = {};
            var textData:Array = [];
            data.user = item.user;
            if(item.type == 'normal')
            {
                data.mode = item.mode;
                data.color = item.color;
                data.size = item.size;
                data.stime = item.stime;
                data.message = item.text;
            }
            else if(item.type == 'zoome')
            {
                textData = [
                    item.text,
                    item.x,
                    item.y,
                    item.alpha,
                    item.style,
                    item.duration,
                    item.inStyle,
                    item.outStyle,
                    item.position,
                    item.tStyle,
                    item.tEffect,
                ];
                data.mode = item.mode;
                data.color = item.color;
                data.size = item.size;
                data.stime = item.stime;
                data.message = JSON.stringify(textData);
            }
            else if(item.type == 'bili')
            {
                //0~6
                textData = [
                    item.x,
                    item.y,
                    item.inAlpha+'-'+item.outAlpha,
                    item.duration,
                    item.text,
                    item.rZ,
                    item.rY
                ];
                if(item.adv)
                {
                    //7~11
                    //0~4
                    var extra:Array=[
                        item.toX,
                        item.toY,
                        item.mDuration,
                        item.delay
                    ];
                    textData = textData.concat(extra);
                }
                data.mode = item.mode;
                data.color = item.color;
                data.size = item.size;
                data.stime = item.stime;
                data.message = JSON.stringify(textData);
            }
            else if(item.type == 'script')
            {
                data.mode = item.mode;
                data.color = 0xffffff;
                data.size = 25;
                data.stime = item.stime;
                data.message = item.text;                
            }
            else
            {
                return null;
            }
            return data;
        }
        /** 弹幕的解析
        * 输入:服务器返回的弹幕组
        * 作用:解析每条弹幕并将数据广播
        **/
        public static function data_parse(items:Array,foo:Function):void
        {
            for(var i:int = 0;i<items.length;i++)
            {
                var item:Object = items[i];
                var obj:Object = {};
                
                obj.text = item.message;
                obj.stime = item.stime;
                obj.mode = item.mode;
                obj.size = item.size;
                obj.color = item.color;
                obj.date = CommentDataParser.date(new Date(item.postdate * 1000));
                obj.border = false;
                
                if(Number(obj.mode) == 9)
                {
                    try
                    {
                        var appendattr:Object = JSON.parse(item.message);
                        obj.text = CommentDataParser.text_string(appendattr[0]);
                        obj.x = appendattr[1];
                        obj.y = appendattr[2];
                        obj.alpha = appendattr[3];
                        obj.style = appendattr[4];
                        obj.duration = appendattr[5];
                        obj.inStyle = appendattr[6];
                        obj.outStyle = appendattr[7];
                        obj.position = appendattr[8];
                        obj.tStyle = appendattr[9];
                        obj.tEffect = appendattr[10];
                        foo(obj.style + obj.position, obj);
                    }
                    catch (error:Error)
                    {
                        trace('JSON decode failed:'+item.message);
                    }
                    continue;
                }
                else if(Number(obj.mode) == 7)
                {
                    try
                    {
                        var json:Object = JSON.parse(item.message);
                        obj.x = Number(json[0]);
                        obj.y = Number(json[1]);
                        obj.text = CommentDataParser.text_string(json[4]);
                        obj.rZ = obj.rY = 0;
                        if (json.length >= 7)
                        {
                            obj.rZ = Number(json[5]);
                            obj.rY = Number(json[6]);
                        }
                        obj.adv = false;//表示是无运动的弹幕
                        if (json.length >= 11)
                        {
                            obj.adv = true;//表示是有运动的弹幕
                            obj.toX = Number(json[7]);
                            obj.toY = Number(json[8]);
                            obj.mDuration = 0.5;//默认移动时间,单位秒
                            obj.delay = 0;//默认移动前的暂停时间
                            if (json[9] != '')
                            {
                                obj.mDuration = Number(json[9]) / 1000;
                            }
                            if (json[10] != '')
                            {
                                obj.delay = Number(json[10]) / 1000;
                            }
                        }
                        obj.duration = 2.5;
                        if (json[3] < 12 && json[3] != 1) {
                            obj.duration = Number(json[3]);
                        }
                        obj.inAlpha = obj.outAlpha = 1;
                        var aa:Array = String(json[2]).split('-');
                        if (aa.length >= 2)
                        {
                            obj.inAlpha = Number(aa[0]);
                            obj.outAlpha = Number(aa[1]);
                        }
                    } catch (e:Error) 
                    {
                        trace('不是良好的JSON格式:' + item.message);
                        continue;
                    }
                }
                foo(String(obj.mode),obj);
            }
        }
        /** 处理文本中的换行符 **/
        public static function text_string(input:String):String
        {
            return input.replace(/(\/n|\\n|\n|\r\n)/g, "\r");
        }
        /** 将日期转换为常用格式 **/
        public static function date(now:Date=null) : String
        {
            if (now == null)
            {
                now = new Date();
            }
			//不要年份了！！
            //return now.getFullYear() + "-" + zero(now.getMonth() + 1) + "-" + zero(now.getDate()) + " " + zero(now.getHours()) + ":" + zero(now.getMinutes()) + ":" + zero(now.getSeconds());
			return zero(now.getMonth() + 1) + "-" + zero(now.getDate()) + " " + zero(now.getHours()) + ":" + zero(now.getMinutes());
        }
		/** 将日期转换为常用格式 **/
		public static function fullDate(now:Date=null) : String
		{
			if (now == null)
			{
				now = new Date();
			}
			//要年份
			return now.getFullYear() + "-" + zero(now.getMonth() + 1) + "-" + zero(now.getDate()) + " " + zero(now.getHours()) + ":" + zero(now.getMinutes()) + ":" + zero(now.getSeconds());
			//return zero(now.getMonth() + 1) + "-" + zero(now.getDate()) + " " + zero(now.getHours()) + ":" + zero(now.getMinutes());
		}
        /** 数字个位前加0 **/
        public static function zero(nbr:Number):String 
        {
            if(nbr < 10)
            {
                return '0'+nbr;
            }
            else 
            {
                return ''+nbr;
            }
        }
        /** 去除换行,剪切长度 **/
        public static function cut(str:String, n:Number = 17):String
        {
            var tmp:Array = str.split("\n");
            str = tmp.join("");
            tmp = str.split("\r");
            str = tmp.join("");
            if (str.length <= n)
            {
                return str;
            }
            else
            {
                return str.substr(0, n)+'...';
            }
        }
    }
}