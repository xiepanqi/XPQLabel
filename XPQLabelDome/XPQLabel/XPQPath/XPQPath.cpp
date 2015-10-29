//
//  XPQLabelLine.cpp
//  XPQLabel
//
//  Created by XPQ on 15/10/21.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#include "XPQPath.h"
#include <math.h>

#pragma mark - XPQPath-----路径基类
XPQPath::XPQPath(XPQPoint point)
{
    m_lastPath = nullptr;
    m_nextPath = nullptr;
    m_endPoint = {point.x, point.y};
}

XPQPath::~XPQPath()
{
    if (m_lastPath != nullptr) {
        // 判断上一条路径的下一条路径指的是否还是自己
        if (m_lastPath->m_nextPath == this) {
            // 防止野指针
            m_lastPath->m_nextPath = nullptr;
        }
    }
    if (m_nextPath != nullptr) {
        delete m_nextPath;
    }
}

bool XPQPath::appendPath(XPQPath *path)
{
    if (path->m_lastPath != nullptr) {
        return false;
    }
    
    XPQPath *endPath = this;
    while (endPath->m_nextPath != nullptr) {
        endPath = endPath->m_nextPath;
    }
    endPath->setNextPath(path);
    path->setLastPath(endPath);
    
    return true;
}

bool XPQPath::removeFrontPath()
{
    if (this->m_lastPath == nullptr) {
        return false;
    }
    
    this->m_lastPath->m_nextPath = nullptr;
    this->m_lastPath = nullptr;
    
    return true;
}

bool XPQPath::removeBackPath(bool release)
{
    if (this->m_nextPath == nullptr) {
        return false;
    }
    
    if (release) {
        delete this->m_nextPath;
    }
    else {
        this->m_nextPath->m_lastPath = nullptr;
    }
    
    this->m_nextPath = nullptr;
    return true;
}

double XPQPath::getLength(bool isTotal)
{
    double length = getSelfLength();
    if (isTotal && m_nextPath != nullptr) {
        length += m_nextPath->getLength(true);
    }
    return length;
}

void XPQPath::getPosTan(double precision, std::vector<XPQPoint> *outBuffer)
{
    getSelfPosTan(precision, outBuffer);
    
    if (this->m_nextPath != nullptr) {
        this->m_nextPath->getPosTan(precision, outBuffer);
    }
}

XPQPath* XPQPath::clone()
{
    XPQPath *clone = new XPQPath(m_endPoint);
    if (m_nextPath != nullptr) {
        clone->appendPath(m_nextPath->clone());
    }
    return clone;
}

double XPQPath::getSelfLength()
{
    return 0.0;
}

void XPQPath::getSelfPosTan(double precision, std::vector<XPQPoint> *outBuffer)
{
    if (m_lastPath != nullptr) {
        outBuffer->push_back(m_lastPath->m_endPoint);
    }
}

void XPQPath::setLastPath(XPQPath *lastPath)
{
    m_lastPath = lastPath;
}

void XPQPath::setNextPath(XPQPath *nextPath)
{
    m_nextPath = nextPath;
}

#pragma mark - XPQLine-----直线
XPQLine::XPQLine(XPQPoint point) : XPQPath(point)
{
    
}

double XPQLine::getSelfLength()
{
    if (m_lastPath == nullptr) {
        return 0.0;
    }
    double xStep = m_endPoint.x - m_lastPath->m_endPoint.x;
    double yStep = m_endPoint.y - m_lastPath->m_endPoint.y;
    return sqrt(xStep * xStep + yStep * yStep);
}

void XPQLine::getSelfPosTan(double precision, std::vector<XPQPoint> *outBuffer)
{
    double length = getSelfLength();
    int pointCount = static_cast<int>(length / precision);
    double xSpike = (m_endPoint.x - m_lastPath->m_endPoint.x) / length * precision;
    double ySpike = (m_endPoint.y - m_lastPath->m_endPoint.y) / length * precision;
    for (int i = 0; i < pointCount; i++) {
        XPQPoint point = {m_lastPath->m_endPoint.x + i * xSpike, m_lastPath->m_endPoint.y + i * ySpike};
        outBuffer->push_back(point);
    }
}


#pragma mark - XPQRound-----圆
XPQRound::XPQRound(XPQPoint centrePoint, double angle) : XPQPath(centrePoint)
{
    m_angle = angle;
    m_centrePoint = centrePoint;
}

XPQRound* XPQRound::clone()
{
    XPQRound *clone = new XPQRound(m_centrePoint, m_angle);
    if (m_nextPath != nullptr) {
        clone->appendPath(m_nextPath->clone());
    }
    return clone;
}

void XPQRound::setLastPath(XPQPath *lastPath)
{
    XPQPath::setLastPath(lastPath);
    if (lastPath == nullptr) {
        m_radii = 0.0;
        m_beginAngle = 0.0;
        m_endPoint.x = m_centrePoint.x;
        m_endPoint.y = m_centrePoint.y;
    }
    else
    {
        double xStep = m_endPoint.x - m_lastPath->m_endPoint.x;
        double yStep = m_endPoint.y - m_lastPath->m_endPoint.y;
        m_radii = sqrt(xStep * xStep + yStep * yStep);
        m_beginAngle = atan((lastPath->m_endPoint.x - m_centrePoint.x) / (lastPath->m_endPoint.y - m_centrePoint.y));
        m_endPoint.x = m_centrePoint.x + m_radii * sin(m_beginAngle + m_angle);
        m_endPoint.y = m_centrePoint.y + m_radii * cos(m_beginAngle + m_angle);
    }
}

double XPQRound::getSelfLength()
{
    if (m_lastPath == nullptr) {
        return 0.0;
    }
    return fabs(m_angle) * m_radii;
}

void XPQRound::getSelfPosTan(double precision, std::vector<XPQPoint> *outBuffer)
{
    double length = getSelfLength();
    int pointCount = static_cast<int>(length / precision);
    double angleSpike = m_angle / pointCount;
    for (int i = 0; i < pointCount; i++) {
        XPQPoint point = {m_centrePoint.x + m_radii * sin(m_beginAngle + i * angleSpike), m_centrePoint.y + m_radii * cos(m_beginAngle + i * angleSpike)};
        outBuffer->push_back(point);
    }
}


#pragma mark - XPQBezier-----贝塞尔曲线
XPQBezier::XPQBezier(XPQPoint anchorPoint, XPQPoint endPoint) : XPQPath(endPoint)
{
    m_anchorPoint = anchorPoint;
}

XPQBezier* XPQBezier::clone()
{
    XPQBezier *clone = new XPQBezier(m_anchorPoint, m_endPoint);
    if (m_nextPath != nullptr) {
        clone->appendPath(m_nextPath->clone());
    }
    return clone;
}

void XPQBezier::setLastPath(XPQPath *lastPath)
{
    XPQPath::setLastPath(lastPath);
    
    if (lastPath == nullptr) {
        
    }
    else {
        m_ax = lastPath->m_endPoint.x - 2 * m_anchorPoint.x + m_endPoint.x;
        m_ay = lastPath->m_endPoint.y - 2 * m_anchorPoint.y + m_endPoint.y;
        m_bx = 2 * m_anchorPoint.x - 2 * lastPath->m_endPoint.x;
        m_by = 2 * m_anchorPoint.y - 2 * lastPath->m_endPoint.y;
        
        m_A = 4 * (m_ax * m_ax + m_ay * m_ay);
        m_B = 4 * (m_ax * m_bx + m_ay * m_by);
        m_C = m_bx * m_bx + m_by * m_by;
    }
}

//长度函数
/*
 L(t) = Integrate[s[t], t]
 
 L(t_) = ((2*Sqrt[A]*(2*A*t*Sqrt[C + t*(B + A*t)] + B*(-Sqrt[C] + Sqrt[C + t*(B + A*t)])) + (B^2 - 4*A*C) (Log[B + 2*Sqrt[A]*Sqrt[C]] - Log[B + 2*A*t + 2 Sqrt[A]*Sqrt[C + t*(B + A*t)]])) /(8* A^(3/2)));
 */
double XPQBezier::getSelfLength()
{
    if (m_lastPath == nullptr) {
        return 0.0;
    }
    
    double temp1 = sqrt(m_A + m_B + m_C);
    double temp2 = (2 * m_A * temp1 + m_B * (temp1 - sqrt(m_C)));
    double temp3 = log(m_B + 2 * sqrt(m_A) * sqrt(m_C));
    double temp4 = log(m_B + 2 * m_A + 2 * sqrt(m_A) * temp1);
    double temp5 = 2 * sqrt(m_A) * temp2;
    double temp6 = (m_B * m_B - 4 * m_A * m_C) * (temp3 - temp4);
    
    return (temp5 + temp6) / (8 * pow(m_A, 1.5));
}

void XPQBezier::getSelfPosTan(double precision, std::vector<XPQPoint> *outBuffer)
{
    double length = getSelfLength();
    int pointCount = static_cast<int>(length / precision);
    for (int i = 0; i < pointCount; i++) {
        double t = (double)i / pointCount;
        //如果按照线形增长,此时对应的曲线长度
        double l = t * length;
        //根据L函数的反函数，求得l对应的t值
        t = invertLength(t, l);
        
        XPQPoint point;
        //根据贝塞尔曲线函数，求得取得此时的x,y坐标
        point.x = (1 - t) * (1 - t) * m_lastPath->m_endPoint.x
        + 2 * (1 - t) * t * m_anchorPoint.x
        + t * t * m_endPoint.x;
        point.y = (1 - t) * (1 - t) * m_lastPath->m_endPoint.y
        + 2 * (1 - t) * t * m_anchorPoint.y
        + t * t * m_endPoint.y;
        outBuffer->push_back(point);
    }
}

//长度函数反函数，使用牛顿切线法求解
/*
 X(n+1) = Xn - F(Xn)/F'(Xn)
 */
double XPQBezier::invertLength(double t, double l)
{
    double t1 = t, t2;
    
    do
    {
        t2 = t1 - (getBezierLength(t1) - l) / speed(t1);
        if(fabs(t1 - t2) < 0.0001) break;
        t1 = t2;
    } while(true);
    
    return t2;
}

//速度函数
/*
 s(t_) = Sqrt[A*t*t+B*t+C]
 */
double XPQBezier::speed(double t)
{
    if (t > 1.0) {
        t = 1.0;
    }
    else if (t <= 0.0) {
        t = 0.0;
    }
    return sqrt(m_A * t * t + m_B * t + m_C);
}

//长度函数
/*
 L(t) = Integrate[s[t], t]
 
 L(t_) = ((2*Sqrt[A]*(2*A*t*Sqrt[C + t*(B + A*t)] + B*(-Sqrt[C] + Sqrt[C + t*(B + A*t)])) + (B^2 - 4*A*C) (Log[B + 2*Sqrt[A]*Sqrt[C]] - Log[B + 2*A*t + 2 Sqrt[A]*Sqrt[C + t*(B + A*t)]])) /(8* A^(3/2)));
 */
double XPQBezier::getBezierLength(double t)
{
    if (t > 1.0) {
        t = 1.0;
    }
    else if (t <= 0.0) {
        return 0.0;
    }
    
    double temp1 = sqrt(m_C + t * (m_B + m_A * t));
    double temp2 = (2 * m_A * t * temp1 + m_B * (temp1 - sqrt(m_C)));
    double temp3 = log(m_B + 2 * sqrt(m_A) * sqrt(m_C));
    double temp4 = log(m_B + 2 * m_A * t + 2 * sqrt(m_A) * temp1);
    double temp5 = 2 * sqrt(m_A) * temp2;
    double temp6 = (m_B * m_B - 4 * m_A * m_C) * (temp3 - temp4);
    
    return (temp5 + temp6) / (8 * pow(m_A, 1.5));
}