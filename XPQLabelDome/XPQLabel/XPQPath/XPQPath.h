//
//  XPQLabelLine.hpp
//  XPQLabel
//
//  Created by XPQ on 15/10/21.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#ifndef XPQLabelPath_h
#define XPQLabelPath_h

#include <stdio.h>
#include <vector>

struct XPQPoint {
    double  x;
    double  y;
};

#pragma mark - 路径基类
class XPQPath {
public:
    XPQPath(XPQPoint point);
    ~XPQPath();
    
    /**
     *  @brief  在路径链结尾附加一个路径链。必须要附加路径链起点才能调用成功。
     *  @param path 要附加的路径。
     *  @return false-附加失败，true-附加成功。
     */
    bool appendPath(XPQPath *path);
    
    /**
     *  @brief  移除前面的路径，使自身成为起点。
     *  @return 如果本身就为起点返回false，反之返回true。
     */
    bool removeFrontPath();
    
    /**
     *  @brief  移除后续路径。
     *  @param release 是否要释放移除的路径
     *  @return 如果没有附加路径则会返回false，反之返回true。
     */
    bool removeBackPath(bool release = true);
    
    /**
     *  @brief  获取长度。
     *  @param isTotal true-包括后续路径；false-只有此路径。
     *  @return 路径长度。
     */
    double getLength(bool isTotal = false);
    /**
     *  @brief  获取路径的点坐标数组。
     *  @param precision 精度值，两点之间的距离。
     *  @param outBuffer 接收点坐标的容器。
     */
    void getPosTan(double precision, std::vector<XPQPoint> *outBuffer);
    
    void setNeedsUpdate();
    /**
     *  @brief  深度复制一条路径，包括后续路径。不过没有复制前面的路径，所以拷贝出来的对象是起点。
     *  @return 拷贝出来的对象。
     */
    virtual XPQPath *clone();
    
protected:
    // 子类只需重写下面两个方法就行
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
    // 属性方法也可重写
    virtual XPQPath* getLastPath() { return m_lastPath; };
    virtual void setLastPath(XPQPath *lastPath) { m_lastPath = lastPath; setNeedsUpdate(); };
    virtual XPQPath* getNextPath() { return m_nextPath; };
    virtual void setNextPath(XPQPath *nextPath) { m_nextPath = nextPath; };
    
public:
    /// 路径结束点
    XPQPoint m_endPoint;
    
protected:    
    bool m_needsUpdate;
    double m_length;
    std::vector<XPQPoint> *m_pointBuffer;
    
private:
    /// 上一条路径，如果为null则表示此对象是起点。
    XPQPath *m_lastPath;
    /// 下一条路径
    XPQPath *m_nextPath;
};

#pragma mark - 直线
class XPQLine : public XPQPath
{
public:
    XPQLine(XPQPoint point);
    
protected:
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
};

#pragma mark - 圆
class XPQRound : public XPQPath
{
public:
    /**
     *  @brief  圆曲线构造函数。
     *  @param centrePoint 圆心。圆半径由圆心和上一条路径结束点共同决定，如果上一条路径为空则半径为0.
     *  @param angle 路径旋转弧度，2π为一圈，正数为逆时针，负数为顺时针。
     */
    XPQRound(XPQPoint centrePoint, double angle);
    virtual XPQRound *clone();
    
protected:
    virtual void setLastPath(XPQPath *lastPath);
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
    
private:
    /// 旋转弧度
    double  m_angle;
    /// 开始弧度
    double  m_beginAngle;
    /// 半径
    double  m_radii;
    /// 圆心
    XPQPoint m_centrePoint;
};

#pragma mark - 贝塞尔曲线
class XPQBezier : public XPQPath
{
public:
    XPQBezier(XPQPoint anchorPoint, XPQPoint endPoint);
    virtual XPQBezier *clone();
    
protected:
    virtual void setLastPath(XPQPath *lastPath);
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
    
private:
    /// 锚点
    XPQPoint m_anchorPoint;
private:
    ///长度函数反函数，使用牛顿切线法求解
    double invertLength(double t, double l);
    double speed(double t);
    double getBezierLength(double t);
    
private:
    /// 下面都是求值过程中的中间变量
    int m_ax;
    int m_ay;
    int m_bx;
    int m_by;
    
    double m_A;
    double m_B;
    double m_C;
};

#endif /* XPQLabelPath_h */
