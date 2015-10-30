//
//  XPQLabelPath.m
//  XPQLabel
//
//  Created by XPQ on 15/10/27.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#import "XPQLabelPath.h"
#import "XPQPath.h"

@interface XPQLabelPath () {
    XPQPath* _pathCpp;
}
@end

@implementation XPQLabelPath
-(instancetype)init {
    self = [super init];
    if (self) {
        _pathCpp = new XPQPath({0.0, 0.0});
    }
    return self;
}

+(instancetype)pathForBeginPoint:(CGPoint)point {
    XPQLabelPath *path = [[XPQLabelPath alloc] init];
    path->_pathCpp->m_endPoint.x = point.x;
    path->_pathCpp->m_endPoint.y = point.y;
    return path;
}

-(void)dealloc {
    if (_pathCpp != nil) {
        delete _pathCpp;
    }
}

-(void)moveBeginPoint:(CGPoint)point {
    _pathCpp->m_endPoint.x = point.x;
    _pathCpp->m_endPoint.y = point.y;
}

-(void)addLineToPoint:(CGPoint)point {
    _pathCpp->appendPath(new XPQLine({point.x, point.y}));
}

-(void)addArcWithCentrePoint:(CGPoint)centrePoint angle:(CGFloat)angle {
    _pathCpp->appendPath(new XPQRound({centrePoint.x, centrePoint.y}, angle));
}

-(void)addCurveToPoint:(CGPoint)point anchorPoint:(CGPoint)anchorPoint {
    _pathCpp->appendPath(new XPQBezier({anchorPoint.x, anchorPoint.y}, {point.x, point.y}));
}


-(CGFloat)getLength {
    return _pathCpp->getLength();
}

-(NSArray<NSValue*> *)getPosTan:(CGFloat)precision {
    std::vector<XPQPoint> *outBuffer = new std::vector<XPQPoint>();
    NSMutableArray *array = [NSMutableArray array];
    _pathCpp->getPosTan(precision, outBuffer);
    for (auto it = outBuffer->begin(); it != outBuffer->end(); ++it) {
        CGPoint point = {static_cast<CGFloat>((*it).x), static_cast<CGFloat>((*it).y)};
        [array addObject:[NSValue valueWithCGPoint:point]];
    }
    delete outBuffer;
    return array;
}

-(void)setNeedsUpdate {
    _pathCpp->setNeedsUpdate();
}

-(XPQLabelPath *)clone {
    XPQLabelPath *clone = [[XPQLabelPath alloc] init];
    clone->_pathCpp = _pathCpp->clone();
    return clone;
}
@end
