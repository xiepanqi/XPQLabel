# XPQLabel
让你的文字动起来！！！
让你的文字随路径轨迹办法！！！

XPQLabel能够只需简单的几句代码就让文本以各种轨迹显示和各种酷炫的动画效果。

## UML


![UML](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/uml.png)


##语言
主要语言为object-c和c++混编。其中object-c主要负责基本显示和操作，C++主要负责路径的计算。

##使用
XPQLabel使用非常简单，只需三步就可以完成使用。
###第一步，引入头文件
把XPQLabel文件夹和其中的文件全部拖进工程。引入头文件，#import "XPQLabel.h"。
###第二步，初始化
####使用代码初始化
```ios
XPQLabel *label = [[XPQLabel alloc] init];
```
####可视化初始化
只需先拖一个UIView到storyboard或者xib上，再Class属性设置成XPQLabel，然后在与某一对象关联就行。
###第三步，设置文本
####设置普通文本
#####代码设置
```ios
label.font = [UIFont systemFontOfSize:18.0];
label.textColor = [UIColor blackColor];
label.text = @"这里是一串普通的文本文字。";
```
#####storyboard或者xib设置
只需修改面板上的text属性和textColor属性，如下图：


![设置文本](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/setText.png)


####设置富文本
富文本只能通过代码设置
```ios
NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"this is attributed string."];
//把this的字体颜色变为红色
[attriString addAttribute:(NSString *)kCTForegroundColorAttributeName
value:(id)[UIColor redColor].CGColor
range:NSMakeRange(0, 4)];
//把is变为绿色
[attriString addAttribute:(NSString *)kCTForegroundColorAttributeName
value:(id)[UIColor greenColor].CGColor
range:NSMakeRange(5, 2)];
//改变attributed的字体
[attriString addAttribute:(NSString *)kCTFontAttributeName value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)[UIFont boldSystemFontOfSize:12].fontName, 20, NULL)) range:NSMakeRange(8, 10)];
//给string加上下划线
[attriString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble]
range:NSMakeRange(19, 6)];

label.attributedText = attriString;
```

##属性设置
当然，经过上面三部还只能简单的显示，如果需要一些额外的效果就需要设置一些属性了。
###文本对齐
文本对齐有两个属性textHorizontalAlignment和textVerticalAlignment，从字面意思就可以看出两个属性分别的作用。这两个属性分别对应下面两个枚举：
```ios
typedef enum : NSUInteger {
XPQLabelHorizontalAlignmentLeft,      // 左对齐
XPQLabelHorizontalAlignmentCenter,    // 水平居中
XPQLabelHorizontalAlignmentRight,     // 右对齐
} XPQLabelHorizontalAlignment;

typedef enum : NSUInteger {
XPQLabelVerticalAlignmentUp,          // 垂直居上
XPQLabelVerticalAlignmentCenter,      // 垂直居中
XPQLabelVerticalAlignmentDown,        // 垂直居下
} XPQLabelVerticalAlignment;
```
使用效果如下图：


![对齐效果图](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/alignmentDome.gif)


###路径
只需设置这个属性就能让文字沿着指定路径显示。
路径是XPQLabelPath对象，XPQLabelPath的使用也非常简单。
先使用XPQLabelPath的pathForBeginPoint方法创建路径起点。
```ios
XPQLabelPath *path = [XPQLabelPath pathForBeginPoint:CGPointMake(10.0, 10.0)];
```


再使用addLineToPoint:/addArcWithCentrePoint:angle:/addCurveToPoint:anchorPoint:来添加路径。


```ios
// 添加直线
[path addLineToPoint:CGPointMake(250.0, 50.0)];
// 添加圆曲线
[path addArcWithCentrePoint:CGPointMake(90.0, 70.0) angle:-M_PI];
// 添加贝塞尔曲线
[path addCurveToPoint:CGPointMake(300.0, 60.0) anchorPoint:CGPointMake(100.0, 0.0)];
```
最后再把路径赋值给path属性或者使用setPath:rotate:animation:方法
```ios
// 带旋转和动画
label.path = path;
// 旋转和动画可选择
[label setPath:path rotate:rotate animation:animation];
```
效果图如下：


![路径效果图](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/pathDome.gif)


###手势轨迹
这是一个很酷炫的功能（然而并没什么卵用）。
设置gesturePathEnable为YES后用手在XPQLabel上滑动，文字会根据手指滑动的轨迹显示，效果图如下：


![手势轨迹效果图](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/gestureDome.gif)


###入场出场动画
暂时只实现两种入场出场动画，调用函数分别为
startShowWithDirection:duration:bounce:stepTime:
startHideWithDirection:duration:stepTime:


![动画1](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/animationDome1.gif)


startFixedShowWithTransform: duration:stepTime:
startFixedHideWithTransform:duration:stepTime:


![动画2](https://github.com/xiepanqi/XPQLabel/blob/master/domeImage/animationDome2.gif)


> **PS:** 如果感觉写的不错请star下，谢谢。
