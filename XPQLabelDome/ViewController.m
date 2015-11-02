//
//  ViewController.m
//  XPQLabelDome
//
//  Created by XPQ on 15/10/28.
//  Copyright © 2015年 com.xpq. All rights reserved.
//

#import "ViewController.h"
#import "XPQLabel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet XPQLabel *stringLabel;
@property (weak, nonatomic) IBOutlet XPQLabel *attributedLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *pathAnimationSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pathRotateSegment;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _stringLabel.text = @"这里是一串普\n通的文本文字。";
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"this is attributed \nstring."];
    //把this的字体颜色变为红色
    [attriString addAttribute:(NSString *)kCTForegroundColorAttributeName
                        value:(id)[UIColor redColor].CGColor
                        range:NSMakeRange(0, 4)];
    //把is变为绿色
    [attriString addAttribute:(NSString *)kCTForegroundColorAttributeName
                        value:(id)[UIColor greenColor].CGColor
                        range:NSMakeRange(5, 2)];
    //改变this的字体，value必须是一个CTFontRef
    [attriString addAttribute:(NSString *)kCTFontAttributeName value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)[UIFont boldSystemFontOfSize:12].fontName, 20, NULL)) range:NSMakeRange(8, 10)];
    //给this加上下划线，value可以在指定的枚举中选择
    [attriString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                        value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble]
                        range:NSMakeRange(19, 6)];
    
    _attributedLabel.attributedText = attriString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onHorizontalAlignmentChange:(UISegmentedControl *)sender {
    BOOL animation = (self.pathAnimationSegment.selectedSegmentIndex == 0);
    // 可以直接通过textHorizontalAlignment属性设置，默认是不带动画。
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.stringLabel setTextHorizontalAlignment:XPQLabelHorizontalAlignmentLeft animation:animation];
            [self.attributedLabel setTextHorizontalAlignment:XPQLabelHorizontalAlignmentLeft animation:animation];
            break;
            
        case 1:
            [self.stringLabel setTextHorizontalAlignment:XPQLabelHorizontalAlignmentCenter animation:animation];
            [self.attributedLabel setTextHorizontalAlignment:XPQLabelHorizontalAlignmentCenter animation:animation];
            break;
            
        case 2:
            [self.stringLabel setTextHorizontalAlignment:XPQLabelHorizontalAlignmentRight animation:animation];
            [self.attributedLabel setTextHorizontalAlignment:XPQLabelHorizontalAlignmentRight animation:animation];
            break;
        default:
            break;
    }
}

- (IBAction)onVerticalAlignmentChange:(UISegmentedControl *)sender {
    BOOL animation = (self.pathAnimationSegment.selectedSegmentIndex == 0);
    // 可以直接通过textVerticalAlignment属性设置，默认是不带动画。
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.stringLabel setTextVerticalAlignment:XPQLabelVerticalAlignmentUp animation:animation];
            [self.attributedLabel setTextVerticalAlignment:XPQLabelVerticalAlignmentUp animation:animation];
            break;
            
        case 1:
            [self.stringLabel setTextVerticalAlignment:XPQLabelVerticalAlignmentCenter animation:animation];
            [self.attributedLabel setTextVerticalAlignment:XPQLabelVerticalAlignmentCenter animation:animation];
            break;
            
        case 2:
            [self.stringLabel setTextVerticalAlignment:XPQLabelVerticalAlignmentDown animation:animation];
            [self.attributedLabel setTextVerticalAlignment:XPQLabelVerticalAlignmentDown animation:animation];
            break;
            
        default:
            break;
    }
}
- (IBAction)onSetPath:(UISegmentedControl *)sender {
    BOOL rotate = (self.pathRotateSegment.selectedSegmentIndex == 0);
    BOOL animation = (self.pathAnimationSegment.selectedSegmentIndex == 0);
    // 可以直接通过path属性设置，默认是带旋转带动画。
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.stringLabel setPath:nil rotate:rotate animation:animation];
            [self.attributedLabel setPath:nil rotate:rotate animation:animation];
            break;
            
        case 1: {
            XPQLabelPath *path = [XPQLabelPath pathForBeginPoint:CGPointMake(10.0, 10.0)];
            [path addLineToPoint:CGPointMake(250.0, 50.0)];
            [self.stringLabel setPath:path rotate:rotate animation:animation];
            XPQLabelPath *path2 = [XPQLabelPath pathForBeginPoint:CGPointMake(10.0, 50.0)];
            [path2 addLineToPoint:CGPointMake(220.0, 10.0)];
            [self.attributedLabel setPath:path2 rotate:rotate animation:animation];
        }
            break;
            
        case 2: {
            XPQLabelPath *path = [XPQLabelPath pathForBeginPoint:CGPointMake(20.0, 70.0)];
            [path addArcWithCentrePoint:CGPointMake(90.0, 70.0) angle:-M_PI];
            [self.stringLabel setPath:path rotate:rotate animation:animation];
            [self.attributedLabel setPath:path rotate:rotate animation:animation];
        }
            break;
            
        case 3: {
            XPQLabelPath *path = [XPQLabelPath pathForBeginPoint:CGPointMake(20.0, 60.0)];
            [path addCurveToPoint:CGPointMake(300.0, 60.0) anchorPoint:CGPointMake(100.0, 0.0)];
            [self.stringLabel setPath:path rotate:rotate animation:animation];
            [self.attributedLabel setPath:path rotate:rotate animation:animation];
        }
            break;
        default:
            break;
    }
}

- (IBAction)onEnterAnmation1:(id)sender {
    [self.stringLabel startShowWithDirection:XPQLabelAnimationDirectionDown duration:0.5 bounce:0.0 stepTime:0.2];
    [self.attributedLabel startShowWithDirection:XPQLabelAnimationDirectionRight duration:0.5 bounce:0.0 stepTime:0.2];
}

- (IBAction)onExitAnmation1:(id)sender {
    [self.stringLabel startHideWithDirection:XPQLabelAnimationDirectionRight duration:0.5 stepTime:0.2];
    [self.attributedLabel startHideWithDirection:XPQLabelAnimationDirectionDown duration:0.5 stepTime:0.2];
}

- (IBAction)onEnterAnmation2:(id)sender {
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.0, 0.0, 1.0);
    [self.stringLabel startFixedShowWithTransform:&transform duration:1.0 stepTime:0.1]; CATransform3DRotate(CATransform3DIdentity, 2 * M_PI, 0.0, 0.0, 1.0);
    [self.attributedLabel startFixedShowWithTransform:&transform duration:1.0 stepTime:0.1];
}

- (IBAction)onExitAnmation2:(id)sender {
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.0, 0.0, 1.0);
    [self.stringLabel startFixedHideWithTransform:&transform duration:1.0 stepTime:0.1];
    [self.attributedLabel startFixedHideWithTransform:&transform duration:1.0 stepTime:0.1];
}

- (IBAction)gestureSwitchChanged:(UISwitch *)sender {
    self.stringLabel.gesturePathEnable = sender.isOn;
    self.attributedLabel.gesturePathEnable = sender.isOn;
}
@end
