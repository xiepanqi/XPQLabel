//
//  XPQLabel.m
//  XPQLabel
//
//  Created by XPQ on 15/10/12.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#import "XPQLabel.h"

@interface XPQLabel () {
    XPQLabelPath *_path;
    
    NSMutableArray<NSAttributedString *> *_stringArray;
    
    /// 手势路径使能。
    BOOL _gesturePathEnable;
    /// 手势路径点坐标数组。
    NSMutableArray *_gesturePointArray;
}
@property (nonatomic, strong) NSMutableArray<CATextLayer *> *layerMutableArray;
@end

@implementation XPQLabel

-(instancetype)init {
    self = [super init];
    if (self) {
        [self configSelf];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configSelf];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
    }
    return self;
}

-(void)configSelf {
    _layerMutableArray = [NSMutableArray array];
    _textColor = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:17.0];
    _textHorizontalAlignment = XPQLabelHorizontalAlignmentLeft;
    _textVerticalAlignment = XPQLabelVerticalAlignmentCenter;
    _stringArray = [NSMutableArray array];
}

#pragma mark -文本操作
-(void)setText:(NSString *)text {
    _text = text;
    NSDictionary *attributes = @{NSFontAttributeName:_font, NSForegroundColorAttributeName:_textColor};
    self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(void)setFont:(UIFont *)font {
    _font = font;
    if (_text != nil) {
        NSDictionary *attributes = @{NSFontAttributeName:_font, NSForegroundColorAttributeName:_textColor};
        self.attributedText = [[NSAttributedString alloc] initWithString:_text attributes:attributes];
    }
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_text != nil) {
        NSDictionary *attributes = @{NSFontAttributeName:_font, NSForegroundColorAttributeName:_textColor};
        self.attributedText = [[NSAttributedString alloc] initWithString:_text attributes:attributes];
    }
}

#pragma mark -富文本
-(void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    _text = nil;
    [self string2ArrayWithWrap];
    
    [self updateLayerArrayCount];
    _layerArray = [NSArray arrayWithArray:self.layerMutableArray];
}

/**
 *  @brief  把字符串在换行符处拆分
 */
-(void)string2ArrayWithWrap {
    NSString *string = _attributedText.string;
    NSRange range = NSMakeRange(0, 0);
    do {
        NSUInteger begin = range.location + range.length;
        NSRange searchRange = NSMakeRange(begin, string.length - begin);
        range = [string rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:searchRange];
        if (range.location == NSNotFound) {
            [_stringArray addObject:[_attributedText attributedSubstringFromRange:searchRange]];
        }
        else {
            [_stringArray addObject:[_attributedText attributedSubstringFromRange:NSMakeRange(begin, range.location - begin)]];
        }
    } while (range.location != NSNotFound);
}

/// 更新图层个数
-(void)updateLayerArrayCount {
    NSInteger layerNum = self.layerMutableArray.count;
    NSInteger textLength = 0;
    // 这样计算字符长度去掉了换行符
    for (NSAttributedString *string in _stringArray) {
        textLength += string.length;
    }
    if (layerNum > textLength) {
        // 移除多余的layer
        NSRange removeRange = NSMakeRange(textLength, layerNum - textLength);
        
        while (layerNum > textLength) {
            CATextLayer *layer = [self.layerMutableArray objectAtIndex:textLength];
            [layer removeFromSuperlayer];
            textLength++;
        }
        
        [self.layerMutableArray removeObjectsInRange:removeRange];
    }
    else {
        // 添加少了的layer
        while (layerNum < textLength) {
            CATextLayer *layer = [CATextLayer layer];
            // 缩放因子
            layer.contentsScale = [UIScreen mainScreen].scale;
            [self.layerMutableArray addObject:layer];
            [self.layer addSublayer:layer];
            layerNum++;
        }
    }
    
    [self refreshLayer:NO];
}

#pragma mark - 刷新
-(void)refreshLayer:(BOOL)animation {
    // 如果设置了路径对齐无效
    if (_path != nil) {
        return;
    }
    
    if (!animation) {
        [CATransaction begin];
        // 关闭隐式动画
        [CATransaction setDisableActions:YES];
    }
    
    [self updateLayerString];
    [self updateLayerBounds];

    
    if (!animation) {
        [CATransaction commit];
    }
}

/// 更新图层上的字符
-(void)updateLayerString {
    int layerIndex = 0;
    for (NSAttributedString *string in _stringArray) {
        for (int i = 0; i < string.length && i < _layerMutableArray.count; i++) {
            _layerMutableArray[layerIndex++].string = [string attributedSubstringFromRange:NSMakeRange(i, 1)];
        }
    }
}

/// 更新图层位置和大小
-(void)updateLayerBounds {
    int layerIndex = 0;
    CGRect layerRect = CGRectMake(0, [self beginY], 0, 0);
    for (NSAttributedString *string in _stringArray) {
        layerRect.origin.x = [self lineBeginX:string];
        layerRect.origin.y += layerRect.size.height;
        layerRect.size.width = 0;
        layerRect.size.height = string.size.height;
        for (int i = 0; i < string.length; i++) {
            CGSize layerSize = ((NSAttributedString *)_layerMutableArray[layerIndex].string).size;
            layerRect.origin.x += layerRect.size.width;
            layerRect.origin.y += (layerRect.size.height - layerSize.height);
            layerRect.size.width = layerSize.width + _elementSpacing;
            layerRect.size.height = layerSize.height + _rowSpacing;
            
            _layerMutableArray[layerIndex].frame = layerRect;
            
            layerIndex++;
        }
    }
}

/// 行X起始坐标
-(CGFloat)lineBeginX:(NSAttributedString *)string {
    switch (_textHorizontalAlignment) {
        case XPQLabelHorizontalAlignmentLeft:
            return 0.0;
            
        case XPQLabelHorizontalAlignmentCenter:
            return (self.bounds.size.width - string.size.width) / 2;
            
        case XPQLabelHorizontalAlignmentRight:
            return self.bounds.size.width - string.size.width;
            
        default:
            return 0.0;
    }
}

/// 字符串Y起始坐标
-(CGFloat)beginY {
    switch (_textVerticalAlignment) {
        case XPQLabelVerticalAlignmentUp:
            return 0.0;
            
        case XPQLabelVerticalAlignmentCenter:
            return (self.bounds.size.height - _attributedText.size.height) / 2;
            
        case XPQLabelVerticalAlignmentDown:
            return self.bounds.size.height - _attributedText.size.height;
            
        default:
            return 0.0;
    }
}

/**
 *  @brief  通过字符的索引获取对应的layer位置和大小
 *  @param index 索引
 *  @return 位置和大小，如果是index无效则返回CGRectMake(0, 0, 0, 0)
 */
-(CGRect)layerRectWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.layerMutableArray.count) {
        CGPoint basePoint = [self basePoint];
        return CGRectMake(basePoint.x, basePoint.y, 0, 0);
    }
    else {
        CALayer *layer = [self.layerMutableArray objectAtIndex:index];
        return layer.frame;
    }
}

#pragma mark -对齐
-(CGPoint)basePoint {
    CGSize stringSize = self.attributedText.size;
    CGPoint basePoint = CGPointZero;
    switch (self.textHorizontalAlignment) {
        case XPQLabelHorizontalAlignmentLeft: {
            basePoint.x = 0;
        }
            break;
        case XPQLabelHorizontalAlignmentCenter: {
            basePoint.x = (self.bounds.size.width - stringSize.width) / 2;
        }
            break;
        case XPQLabelHorizontalAlignmentRight: {
            basePoint.x = self.bounds.size.width - stringSize.width;
        }
            break;
        default:
            break;
    }
    
    switch (self.textVerticalAlignment) {
        case XPQLabelVerticalAlignmentUp: {
            basePoint.y = stringSize.height;
        }
            break;
        case XPQLabelVerticalAlignmentCenter: {
            basePoint.y = (self.bounds.size.height + stringSize.height) / 2;
        }
            break;
        case XPQLabelVerticalAlignmentDown: {
            basePoint.y = self.bounds.size.height;
        }
            break;
        default:
            break;
    }
    
    return basePoint;
}

-(void)setTextVerticalAlignment:(XPQLabelVerticalAlignment)textVerticalAlignment {
    _textVerticalAlignment = textVerticalAlignment;
    [self refreshLayer:NO];
}

-(void)setTextHorizontalAlignment:(XPQLabelHorizontalAlignment)textHorizontalAlignment {
    _textHorizontalAlignment = textHorizontalAlignment;
    [self refreshLayer:NO];
}

-(void)setTextVerticalAlignment:(XPQLabelVerticalAlignment)textVerticalAlignment animation:(BOOL)animation {
    _textVerticalAlignment = textVerticalAlignment;
    [self refreshLayer:animation];
}

-(void)setTextHorizontalAlignment:(XPQLabelHorizontalAlignment)textHorizontalAlignment animation:(BOOL)animation {
    _textHorizontalAlignment = textHorizontalAlignment;
    [self refreshLayer:animation];
}
@end


#pragma mark - 文本路径
@implementation XPQLabel (Path)
-(XPQLabelPath *)path {
    return _path;
}

-(void)setPath:(XPQLabelPath *)path {
    [self setPath:path rotate:YES animation:YES];
}

-(void)setPath:(XPQLabelPath *)path rotate:(BOOL)rotate animation:(BOOL)animation {
    _path = path;
    if (path == nil) {
        if (!animation) {
            [CATransaction begin];
            // 关闭隐式动画
            [CATransaction setDisableActions:YES];
        }

        for (CALayer *layer in _layerMutableArray) {
            layer.transform = CATransform3DIdentity;
        }
        
        if (!animation) {
            [CATransaction commit];
        }
        [self refreshLayer:animation];
        return;
    }
    
    NSArray<NSValue *> *pointArray = [_path getPosTan:1.0];
    double currentLength = 0.0;
    
    if (!animation) {
        [CATransaction begin];
        // 关闭隐式动画
        [CATransaction setDisableActions:YES];
    }
    
    for (int i = 0; i < self.layerArray.count; i++) {
        CALayer *layer = self.layerArray[i];
        NSUInteger pointIndex = currentLength + layer.bounds.size.width / 2;
        if (pointIndex + 1 < pointArray.count) {
            layer.position = pointArray[pointIndex].CGPointValue;
            if (rotate) {
                CGPoint lastPoint = pointArray[pointIndex - 1].CGPointValue;
                CGPoint nextPoint = pointArray[pointIndex + 1].CGPointValue;
                CGFloat angle = atan((nextPoint.y - lastPoint.y) / (nextPoint.x - lastPoint.x));
                if (nextPoint.x < lastPoint.x) {
                    angle += M_PI;
                }
                layer.transform = CATransform3DRotate(CATransform3DIdentity, angle, 0.0, 0.0, 1.0);
            }
            else {
                layer.transform = CATransform3DIdentity;
            }
            currentLength += layer.bounds.size.width;
        }
        else { // 超出路径部分文字按水平直线排列
            layer.transform = CATransform3DIdentity;
            if (i == 0) {
                CGPoint basePoint = [self basePoint];
                layer.frame = CGRectMake(basePoint.x, basePoint.y - layer.frame.size.height, layer.frame.size.width, layer.frame.size.height);
            }
            else {
                CALayer *lastLayer = self.layerArray[i - 1];
                layer.position = CGPointMake(lastLayer.position.x + (lastLayer.frame.size.width + layer.frame.size.width) / 2, lastLayer.position.y);
            }
        }
    }
    
    
    if (!animation) {
        [CATransaction commit];
    }
}
@end


@implementation XPQLabel (gesturePath)
-(BOOL)gesturePathEnable {
    return _gesturePathEnable;
}

-(void)setGesturePathEnable:(BOOL)gesturePathEnable {
    _gesturePathEnable = gesturePathEnable;
    if (gesturePathEnable == NO) {
        _gesturePointArray = nil;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_gesturePathEnable) {
        _gesturePointArray = [NSMutableArray array];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_gesturePathEnable && _gesturePointArray != nil) {
        CGPoint point = [touches.anyObject locationInView:self];
        [_gesturePointArray addObject:[NSValue valueWithCGPoint:point]];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_gesturePathEnable && _gesturePointArray != nil && _gesturePointArray.count > 0) {
        XPQLabelPath *path = [XPQLabelPath pathForBeginPoint:((NSValue *)_gesturePointArray[0]).CGPointValue];
        [path addCustomPoint:_gesturePointArray];
        self.path = path;
    }
}
@end

@implementation XPQLabel (Animation)
//TODO:设置路径后这个分类的动画表现都不好
#pragma mark -跳动动画
-(void)startBeatAnimationWithBeatHeight:(CGFloat)height beatTime:(NSTimeInterval)beatTime banTime:(NSTimeInterval)banTime stepTime:(NSTimeInterval)stepTime {
    if (self.layerArray.count == 0) {
        return;
    }
    
    CALayer *fristLayer = self.layerArray[0];
    CAAnimation *animation = [self beatAnimationWithY:fristLayer.position.y beatHeight:height beatTime:beatTime cycleTime:beatTime + banTime];
    for (int i = 0; i < self.layerArray.count; i++) {
        NSDictionary *dict = @{@"layer":self.layerArray[i],
                               @"animation":animation};
        [self performSelector:@selector(addAnimation:) withObject:dict afterDelay:i * stepTime];
    }
}

-(void)addAnimation:(NSDictionary *)dict {
    CALayer *layer = dict[@"layer"];
    CAAnimation *animation = dict[@"animation"];
    [layer addAnimation:animation forKey:@"beatAnimation"];
}

-(CAAnimation *)beatAnimationWithY:(CGFloat)y beatHeight:(CGFloat)height beatTime:(NSTimeInterval)beatTime cycleTime:(NSTimeInterval)cycleTime {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = [NSNumber numberWithFloat:y];
    animation.toValue = [NSNumber numberWithFloat:y - height];
    animation.autoreverses = YES;
    animation.duration = beatTime / 2;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation];
    group.duration = MAX(beatTime, cycleTime);
    group.repeatCount = FLT_MAX;
    
    return group;
}

-(void)stopBeatAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (CALayer *layer in self.layerArray) {
        [layer removeAnimationForKey:@"beatAnimation"];
    }
}

#pragma mark -抖动动画
-(void)startWiggleAnimation {
    for (CALayer *layer in self.layerArray) {
        [layer addAnimation:[self wiggleAnimationWithPosittion:layer.position] forKey:@"wiggleAnimation"];
    }
}

-(CAAnimation *)wiggleAnimationWithPosittion:(CGPoint)position {
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:-M_PI / 16];
    rotateAnimation.toValue = [NSNumber numberWithFloat:+M_PI / 16];
    rotateAnimation.autoreverses = YES;
    rotateAnimation.duration = 0.05;
    
    CABasicAnimation *moveAnimation1 = [CABasicAnimation animationWithKeyPath:@"position.x"];
    moveAnimation1.toValue = [NSNumber numberWithFloat:position.x + 2];
    moveAnimation1.autoreverses = YES;
    moveAnimation1.duration = 0.05;
    
    CABasicAnimation *moveAnimation2 = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveAnimation2.toValue = [NSNumber numberWithFloat:position.y + 2];
    moveAnimation2.autoreverses = YES;
    moveAnimation2.duration = 0.05;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[rotateAnimation, moveAnimation1, moveAnimation2];
    group.duration = 0.1;
    group.repeatCount = FLT_MAX;
    return group;
}

-(void)stopWiggleAnimation {
    for (CALayer *layer in self.layerArray) {
        [layer removeAnimationForKey:@"wiggleAnimation"];
    }
}
@end



@implementation XPQLabel (ShowAndHide)
#pragma mark -直线移动动画
-(void)startShowWithDirection:(XPQLabelAnimationDirection)direction duration:(NSTimeInterval)duration bounce:(CGFloat)bounce stepTime:(NSTimeInterval)stepTime {
    for (int i = 0; i < self.layerArray.count; i++) {
        CALayer *layer = self.layerArray[i];
        [layer removeAllAnimations];
        
        CGPoint beginPoint;
        CGPoint offsetPoint = layer.position;
        switch (direction) {
            case XPQLabelAnimationDirectionDown: {
                beginPoint = [self convertPoint:CGPointMake(0.0, 0.0) fromView:self.window];
                beginPoint.x = layer.position.x;
                beginPoint.y -= layer.bounds.size.height;
                offsetPoint.y += (bounce * layer.bounds.size.height);
            }
                break;
                
            case XPQLabelAnimationDirectionUp: {
                beginPoint = [self convertPoint:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) fromView:self.window];
                beginPoint.x = layer.position.x;
                beginPoint.y += layer.bounds.size.height;
                offsetPoint.y -= (bounce * layer.bounds.size.height);
            }
                
            case XPQLabelAnimationDirectionRight: {
                beginPoint = [self convertPoint:CGPointMake(0.0, 0.0) fromView:self.window];
                beginPoint.x -= layer.bounds.size.width;
                beginPoint.y = layer.position.y;
                offsetPoint.x += (bounce * layer.bounds.size.width);
            }
                break;
                
            case XPQLabelAnimationDirectionLeft: {
                beginPoint = [self convertPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, 0.0) fromView:self.window];
                beginPoint.x += layer.bounds.size.width;
                beginPoint.y = layer.position.y;
                offsetPoint.x -= (bounce * layer.bounds.size.width);
            }
                break;
                
            default:
                break;
        }
        NSTimeInterval fixedTime = i * stepTime;
        if (direction == XPQLabelAnimationDirectionRight) {
            fixedTime = (self.layerArray.count - i) * stepTime;
        }
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.values = @[[NSValue valueWithCGPoint:beginPoint],
                             [NSValue valueWithCGPoint:beginPoint],
                             [NSValue valueWithCGPoint:layer.position],
                             [NSValue valueWithCGPoint:offsetPoint]];
        animation.keyTimes = @[@(0.0),
                               @(fixedTime / (duration + fixedTime + 0.2)),
                               @((duration + fixedTime) / (duration + fixedTime + 0.2)),
                               @((duration + fixedTime + 0.1) / (duration + fixedTime + 0.2)),
                               @(1.0)];
        animation.duration = duration + fixedTime + 0.2;

        [layer addAnimation:animation forKey:@"dropShowAnimation"];
    }
    self.hidden = NO;
}

-(void)stopDropShow {
    for (CALayer *layer in self.layerArray) {
        [layer removeAnimationForKey:@"dropShowAnimation"];
    }
}

-(void)startHideWithDirection:(XPQLabelAnimationDirection)direction duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime {
    for (int i = 0; i < self.layerArray.count; i++) {
        CALayer *layer = self.layerArray[i];
        CGPoint endPoint;
        switch (direction) {
            case XPQLabelAnimationDirectionUp: {
                endPoint = [self convertPoint:CGPointMake(0.0, 0.0) fromView:self.window];
                endPoint.x = layer.position.x;
                endPoint.y -= layer.bounds.size.height;
            }
                break;
                
            case XPQLabelAnimationDirectionDown: {
                endPoint = [self convertPoint:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) fromView:self.window];
                endPoint.x = layer.position.x;
                endPoint.y += layer.bounds.size.height;
            }
                break;
                
            case XPQLabelAnimationDirectionLeft: {
                endPoint = [self convertPoint:CGPointMake(0.0, 0.0) fromView:self.window];
                endPoint.x -= layer.bounds.size.width;
                endPoint.y = layer.position.y;
            }
                break;
                
            case XPQLabelAnimationDirectionRight: {
                endPoint = [self convertPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, 0.0) fromView:self.window];
                endPoint.x += layer.bounds.size.width;
                endPoint.y = layer.position.y;
            }
                break;
            default:
                break;
        }
        NSTimeInterval fixedTime = i * stepTime;
        if (direction == XPQLabelAnimationDirectionRight) {
            fixedTime = (self.layerArray.count - i) * stepTime;
        }
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.values = @[[NSValue valueWithCGPoint:layer.position],
                             [NSValue valueWithCGPoint:layer.position],
                             [NSValue valueWithCGPoint:endPoint]];
        animation.keyTimes = @[@(0.0),
                               @(fixedTime / (duration + fixedTime)),
                               @(1.0)];
        animation.duration = duration + fixedTime;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        
        [layer addAnimation:animation forKey:@"dropHideAnimation"];
        if ((direction != XPQLabelAnimationDirectionRight && i == self.layerArray.count - 1)
            || (direction == XPQLabelAnimationDirectionRight && i == 0)) {
            // 这里之所以不使用代理是为了防止其他分类重写了animationDidStop:finished造成BUG
            [self performSelector:@selector(dropHideAnimationEnd) withObject:nil afterDelay:duration + fixedTime];
        }
    }
}

-(void)stopDropHide {
    for (CALayer *layer in self.layerArray) {
        [layer removeAnimationForKey:@"dropHideAnimation"];
    }
    self.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dropHideAnimationEnd) object:nil];
}

-(void)dropHideAnimationEnd {
    self.hidden = YES;
}

#pragma mark -固定位置动画
-(void)startFixedShowWithTransform:(CATransform3D *)transform duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime {
    self.hidden = NO;
    for (int i = 0; i < self.layerArray.count; i++) {
        NSTimeInterval fixedTime = i * stepTime;
        CALayer *layer = self.layerArray[i];
        [layer removeAllAnimations];
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@(0.0),
                                    @(0.0),
                                    @(1.0)];
        opacityAnimation.keyTimes = @[@(0.0),
                                      @(fixedTime / (duration + fixedTime)),
                                      @(1.0)];
        opacityAnimation.duration = duration + fixedTime;
        opacityAnimation.removedOnCompletion = NO;
        opacityAnimation.fillMode = kCAFillModeForwards;
        
        if (transform == nil) {
            if (i == self.layerArray.count - 1) {
                opacityAnimation.delegate = self;
            }
            [layer addAnimation:opacityAnimation forKey:@"fixedShowAnimation"];
        }
        else {
            CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            transformAnimation.values = @[[NSValue valueWithCATransform3D:*transform],
                                          [NSValue valueWithCATransform3D:*transform],
                                          [NSValue valueWithCATransform3D:layer.transform]];
            transformAnimation.keyTimes = @[@(0.0),
                                            @(fixedTime / (duration + fixedTime)),
                                            @(1.0)];
            transformAnimation.duration = duration + fixedTime;
            transformAnimation.removedOnCompletion = NO;
            transformAnimation.fillMode = kCAFillModeForwards;
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.duration = duration + fixedTime;
            group.animations = @[opacityAnimation, transformAnimation];
            [layer addAnimation:group forKey:@"fixedShowAnimation"];
        }
    }
}

-(void)stopFixedShow {
    for (CALayer *layer in self.layerArray) {
        [layer removeAnimationForKey:@"fixedShowAnimation"];
    }
}

-(void)startFixedHideWithTransform:(CATransform3D *)transform duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime {
    for (int i = 0; i < self.layerArray.count; i++) {
        NSTimeInterval fixedTime = i * stepTime;
        CALayer *layer = self.layerArray[i];
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@(1.0),
                                    @(1.0),
                                    @(0.0)];
        opacityAnimation.keyTimes = @[@(0.0),
                                      @(fixedTime / (duration + fixedTime)),
                                      @(1.0)];
        opacityAnimation.duration = duration + fixedTime;
        
        if (transform == nil) {
            if (i == self.layerArray.count - 1) {
                opacityAnimation.delegate = self;
            }
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [layer addAnimation:opacityAnimation forKey:@"fixedHideAnimation"];
        }
        else {
            CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            transformAnimation.values = @[[NSValue valueWithCATransform3D:layer.transform],
                                          [NSValue valueWithCATransform3D:layer.transform],
                                          [NSValue valueWithCATransform3D:*transform]];
            transformAnimation.keyTimes = @[@(0.0),
                                            @(fixedTime / (duration + fixedTime)),
                                            @(1.0)];
            transformAnimation.duration = duration + fixedTime;
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.duration = duration + fixedTime;
            group.animations = @[opacityAnimation, transformAnimation];
            group.removedOnCompletion = NO;
            group.fillMode = kCAFillModeForwards;
            [layer addAnimation:group forKey:@"fixedHideAnimation"];
        }
        if (i == self.layerArray.count - 1) {
            // 这里之所以不使用代理是为了防止其他分类重写了animationDidStop:finished造成BUG
            [self performSelector:@selector(fixedHideAnimationEnd) withObject:nil afterDelay:duration + fixedTime];
        }
    }
}

-(void)stopFixedHide {
    for (CALayer *layer in self.layerArray) {
        [layer removeAnimationForKey:@"fixedHideAnimation"];
    }
    self.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fixedHideAnimationEnd) object:nil];
}

-(void)fixedHideAnimationEnd {
    self.hidden = YES;
}
@end
