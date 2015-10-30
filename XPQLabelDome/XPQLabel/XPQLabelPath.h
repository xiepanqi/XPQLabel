//
//  XPQLabelPath.h
//  XPQLabel
//
//  Created by XPQ on 15/10/27.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  @brief  对XPQPath类的OC封装
 */
@interface XPQLabelPath : NSObject
/**
 *  @brief  构建路径起点。
 *  @param point 起点位置。
 *  @return 路径。
 */
+(instancetype)pathForBeginPoint:(CGPoint)point;

/**
 *  @brief  移动起点。
 *  @param point 起点位置。
 */
-(void)moveBeginPoint:(CGPoint)point;
/**
 *  @brief  添加直线。
 *  @param point 直线结束点。
 */
-(void)addLineToPoint:(CGPoint)point;
/**
 *  @brief  添加圆曲线，半径由上一条路径结束点和圆心共同确定。
 *  @param centrePoint 圆心点。
 *  @param angle       旋转角度。2π表示一圈。正数为逆时针，负数为顺时针。
 */
-(void)addArcWithCentrePoint:(CGPoint)centrePoint angle:(CGFloat)angle;
/**
 *  @brief  添加贝塞尔曲线。
 *  @param point       结束点。
 *  @param anchorPoint 锚点。
 */
-(void)addCurveToPoint:(CGPoint)point anchorPoint:(CGPoint)anchorPoint;

/**
 *  @brief  获取路径长度。
 *  @return 路径长度。
 */
-(CGFloat)getLength;
/**
 *  @brief  获取等距路径点数组。
 *  @param precision 点与点之间的间距。
 *  @return 路径点数组。
 */
-(NSArray<NSValue*> *)getPosTan:(CGFloat)precision;

/**
 *	@brief	强制刷新路径点坐标数组。
 */
-(void)setNeedsUpdate;

/**
 *  @brief  深度复制一条路径。
 *  @return 拷贝出来的对象。
 */
-(XPQLabelPath *)clone;
@end
