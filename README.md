# XPQLabel
让你的文字动起来！！！
让你的文字随路径轨迹办法！！！

## 效果图
![Flipboard playing multiple GIFs](https://github.com/xiepanqi/XPQLabel/blob/master/Dome.gif)
(图片较大，加载过程请耐心等待)

## 类说明
有2个OC类（XPQLabel/XPQLabelPath）和4个C++类(XPQPath/XPQLine/XPQRound/XPQBezier)。
### XPQLabel类
该类在XPQLabel.h和XPQLabel.m文件中，继承自UIView。主要功能是通过CATextLayer把文本显示出来。
### XPQLabelPath类
该类主要是把一段路径转换成点坐标数组，让XPQLabel类中的文本根据点坐标位置现实。
目前路径暂时只支持直线、圆曲线、贝塞尔曲线，暂不支持椭圆曲线（可能后面也支持不了，数学差是硬伤😢）。
该类其实是对4个C++类(XPQPath/XPQLine/XPQRound/XPQBezier)的封装。在使用XPQLabel的时候并不需要直接使用后面4个C++类，只需调用该类就行。

### XPQPath类
该类是各路径类的基类。
路径实现的思路是一条路径由n(n>=0)条子路径组成，并且所有路径都有起点和终点，而上一条子路径的终点与下一条路径的起点必定是重合的。经过一番深思熟虑之后决定每条子路径只需记录一个终点坐标就行，起点靠路径链路中的上一条路径的终点确定。如果上一条路径为空那就这点为整个路径的起点。
### XPQLine类
该类是直线类，继承自XPQPath。
最简单的一个类，就不说了。
### XPQRound类
该类是圆曲线类，继承自XPQPath。
确定一个圆的最低条件只需圆心和半径就行。因为起点以确定，所以我们只需传个圆心就可以求出半径从而确定这个圆。然后传一个圆曲线所占角度，就能得到需要的曲线，并求出终点。
所以该类的构造函数是XPQRound(XPQPoint centrePoint, double angle)。
### XPQBezier类
该类是二次贝塞尔曲线类，继承自XPQPath。
二次贝塞尔曲线需要三个点（起点、终点、锚点），起点已知，只需传终点和锚点。所以构造函数是XPQBezier(XPQPoint anchorPoint, XPQPoint endPoint)。


ps:关于路径类为什么要用C++实现？
有三个原因：1.不用C++实现怎么体现我会C++这门语言呢😊。2.贝塞尔曲线相关计算量大，为了效率。（而且网上求解贝塞尔曲线只有C++代码，可以偷把懒）。3.因为这个类可以实现游戏中精灵沿路径匀速移动，而cocod2x只能用C++写。