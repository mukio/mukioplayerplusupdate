##MukioPlayer for Discuz!
这个工程是为了兼容原有的Discuz!插件而设计的。

主要修改：
 - 配置文件改回conf.xml
 - 保留原有的Youku源解析风格

--------------------

MukioPlayer2.000,代号MukioPlayerPlus
源代码

### 使用协议:
 - JW Player的使用协议(src/JWPlayer-README.txt)
 - BetweenAS3的使用协议(libs/BetweenAS3-LICENSE.txt)
 - E3Engine的使用协议(libs/E3Engine-license.txt)
 - as3corelib的使用协议(libs/as3corelib-license.txt)
 - 其他部分的使用协议(MIT License) http://www.opensource.org/licenses/mit-license.php

### 编译环境:
 - Flex SDK 4.0
 - 运行需要FlashPlayer 10.0.0

####Ant编译方法:
请安装ant，进入cmd模式，cd 项目目录， ant  
使用ant编译前,把build.properties.sample改名为build.properties  
并修改其中的Flex SDK目录设置  

####FlashBuilder编译方法:
创建一个新的Flex项目  
指定路径为源代码路径,Flex SDK选4.0或更新的版本  
编译前指定程序入口 src/MukioPlayerPlus.mxml  

项目主页:http://code.google.com/p/mukioplayer/  

aristotle9  
2011年6月4日  

-------------------

## MukioPlayerPlusPlus
源代码

### 编译环境：
 - Flex SDK 4.7及以上，否则IE与Firefox浏览器下弹幕字体不正确
 - 请在编译选项中打开"在MX组件中使用Flash文本引擎"

项目主页：https://github.com/mukio/mukioplayerplusupdate

jiangming1399  
2015年8月6日  