//
//  XPQLabel.h
//  XPQLabel
//
//  Created by XPQ on 15/10/12.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "XPQLabelPath.h"

typedef enum : NSUInteger {
    XPQLabelHorizontalAlignmentLeft,
    XPQLabelHorizontalAlignmentCenter,
    XPQLabelHorizontalAlignmentRight,
} XPQLabelHorizontalAlignment;

typedef enum : NSUInteger {
    XPQLabelVerticalAlignmentUp,
    XPQLabelVerticalAlignmentCenter,
    XPQLabelVerticalAlignmentDown,
} XPQLabelVerticalAlignment;

@interface XPQLabel : UIView
/**
 *  要显示的文本，和attributedText互诉，设置了text自动会将attributedText设为nil。
 */
@property(nonatomic, copy) IBInspectable NSString *text;
/**
 *  文本颜色
 */
@property(nonatomic, strong) IBInspectable UIColor *textColor;
/**
 *  文本字体
 */
@property(nonatomic, strong) UIFont *font;
/**
 *  富文本，和text互诉，设置了attributedText自动会将text设为nil。
 */
@property(nonatomic, copy)   NSAttributedString *attributedText;
/**
 *  字符层数组
 */
@property(nonatomic, strong, readonly) NSArray<CATextLayer*> *layerArray;
/**
 *  @brief  刷新图层，一般用在设置attributedText后修改属性使用，其他地方不需调用。如果attributedText为nil则该函数没有任何效果。
 *  @param  animation  YES-有动画效果，NO-无动画效果。
 */
-(void)refreshLayer:(BOOL)animation;

/**
 *  水平方向对齐，默认值为XPQLabelHorizontalAlignmentLeft。改变时没有动画效果，如果需要动画效果可以参考setTextHorizontalAlignment:animation。
 */
@property(nonatomic) XPQLabelHorizontalAlignment textHorizontalAlignment;
/**
 *  垂直方向对齐，默认值为XPQLabelVerticalAlignmentCenter。改变时没有动画效果，如果需要动画效果可以参考setTextVerticalAlignment:animation。
 */
@property(nonatomic) XPQLabelVerticalAlignment textVerticalAlignment;
/**
 *  @brief  设置文本水平对齐方向
 *  @param textHorizontalAlignment 水平对齐方向。
 *  @param animation               YES-有动画效果，NO-无动画效果。
 */
-(void)setTextHorizontalAlignment:(XPQLabelHorizontalAlignment)textHorizontalAlignment animation:(BOOL)animation;
/**
 *  @brief  设置文本垂直对齐方向
 *  @param textVerticalAlignment 垂直对齐方向。
 *  @param animation             YES-有动画效果，NO-无动画效果。
 */
-(void)setTextVerticalAlignment:(XPQLabelVerticalAlignment)textVerticalAlignment animation:(BOOL)animation;
@end

@interface XPQLabel (Path)

/**
 *  字符路径
 */
@property(nonatomic) XPQLabelPath *path;

-(void)setPath:(XPQLabelPath *)path rotate:(BOOL)rotate animation:(BOOL)animation;
@end

#pragma mark - 文本动画效果
/**
 *  这个分类主要是实现一些动画效果。
 */
@interface XPQLabel (Animation)
/**
 *  @brief  启动跳动动画
 *  @param height   跳动幅度
 *  @param beatTime 跳一次所用时间
 *  @param banTime  两次跳动之间的禁止时间
 *  @param stepTime 两个字符之间跳动的间隔时间
 */
-(void)startBeatAnimationWithBeatHeight:(CGFloat)height beatTime:(NSTimeInterval)beatTime banTime:(NSTimeInterval)banTime stepTime:(NSTimeInterval)stepTime;
/**
 *  @brief  停止跳动动画
 */
-(void)stopBeatAnimation;

/**
 *  @brief  启动抖动动画
 */
-(void)startWiggleAnimation;

/**
 *  @brief  停止抖动动画
 */
-(void)stopWiggleAnimation;
@end


#pragma mark - 文本显示隐藏动画效果
/**
 动画移动方向
 */
typedef enum : NSUInteger {
    XPQLabelAnimationDirectionDown,
    XPQLabelAnimationDirectionUp,
    XPQLabelAnimationDirectionLeft,
    XPQLabelAnimationDirectionRight,
} XPQLabelAnimationDirection;

/**
 *  这个分类主要是实现显示和隐藏过程中的动画效果。
 */
@interface XPQLabel (ShowAndHide)
/**
 *  @brief  启动显示动画（直线移动）。
 *  @param direction 移动方向。
 *  @param duration  单个字符移动时间。
 *  @param bounce    弹性系数，反弹距离为bounce * 字体大小。
 *  @param stepTime  两个字符之间动画间隔时间。
 */
-(void)startShowWithDirection:(XPQLabelAnimationDirection)direction duration:(NSTimeInterval)duration bounce:(CGFloat)bounce stepTime:(NSTimeInterval)stepTime;
/**
 *  @brief  停止显示动画（直线移动）。
 */
-(void)stopDropShow;

/**
 *  @brief  启动隐藏动画（直线移动）。
 *  @param direction 移动方向。
 *  @param duration  单个字符移动时间。
 *  @param stepTime  两个字符之间动画间隔时间。
 */
-(void)startHideWithDirection:(XPQLabelAnimationDirection)direction duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime;
/**
 *  @brief  停止隐藏动画（直线移动）。
 */
-(void)stopDropHide;

/**
 *  @brief  启动显示动画（固定位置）。
 *  @param transform 显示过程中变化值，此值是指开始时的状态。
 *  @param duration  单个字符持续时间。
 *  @param stepTime  两个字符之间动画间隔时间。
 */
-(void)startFixedShowWithTransform:(CATransform3D *)transform duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime;
/**
 *  @brief  停止显示动画（固定位置）。
 */
-(void)stopFixedShow;

/**
 *  @brief  启动隐藏动画（固定位置）。
 *  @param transform 隐藏过程中变化值，此值是指结束时的状态。
 *  @param duration  单个字符持续时间。
 *  @param stepTime  两个字符之间动画间隔时间。
 */
-(void)startFixedHideWithTransform:(CATransform3D *)transform duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime;
/**
 *  @brief  停止隐藏动画（固定位置）。
 */
-(void)stopFixedHide;
@end