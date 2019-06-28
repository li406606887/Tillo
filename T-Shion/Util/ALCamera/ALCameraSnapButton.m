//
//  ALCameraSnapButton.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/15.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALCameraSnapButton.h"

//默认大小
static CGFloat kDefaultBtnWidth = 75;
static CGFloat kTouchViewWidth = 55;
static CGFloat kProgressWidth = 4;

//录制视频时的比例
static float kShootBtnScale = 1.6;
static float kShootTouchViewScale = 0.5;


@interface ALCameraSnapButton ()

@property (nonatomic, weak) UIView *touchView;
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, copy) ALCameraSnapTapBlock tapEventBlock;
@property (nonatomic, copy) ALCameraSnapLongPressBlock longPressEventBlock;


@end


@implementation ALCameraSnapButton

+ (instancetype)defaultSnapButton {
    ALCameraSnapButton *cameraButton = [[ALCameraSnapButton alloc] initWithFrame:CGRectMake(0, 0, kDefaultBtnWidth, kDefaultBtnWidth)];
    [cameraButton.layer setCornerRadius:(kDefaultBtnWidth / 2)];
    cameraButton.backgroundColor = RGBACOLOR(225, 225, 230, 1);
    
    // 设置camera view的点击按钮
    CGFloat touchViewX = (kDefaultBtnWidth - kTouchViewWidth) / 2;
    CGFloat touchViewY = (kDefaultBtnWidth - kTouchViewWidth) / 2;
    
    UIView *touchView = [[UIView alloc] initWithFrame:CGRectMake(touchViewX, touchViewY, kTouchViewWidth, kTouchViewWidth)];
    
    cameraButton.touchView = touchView;
    [cameraButton addSubview:touchView];
    [cameraButton.touchView.layer setCornerRadius:(cameraButton.touchView.bounds.size.width / 2)];
    touchView.backgroundColor = [UIColor whiteColor];
    [cameraButton initCircleAnimationLayer];
    return cameraButton;
}

#pragma mark - private method
// 初始化按钮路径
- (void)initCircleAnimationLayer {
    
    float centerX = self.bounds.size.width / 2.0;
    float centerY = self.bounds.size.height / 2.0;
    
    //半径
    float radius = (self.bounds.size.width - kProgressWidth) / 2.0;
    
    //创建贝塞尔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:(-0.5f * M_PI) endAngle:(1.5f * M_PI) clockwise:YES];
    
    //添加背景圆环
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = self.bounds;
    backLayer.fillColor =  [[UIColor clearColor] CGColor];
    backLayer.strokeColor  = RGBACOLOR(225, 225, 230, 1).CGColor;
    backLayer.lineWidth = kProgressWidth;
    backLayer.path = [path CGPath];
    backLayer.strokeEnd = 1;
    [self.layer addSublayer:backLayer];
    
    //创建进度layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    //指定path的渲染颜色
    _progressLayer.strokeColor  = [[UIColor blackColor] CGColor];
    _progressLayer.lineCap = kCALineCapSquare;//kCALineCapRound;
    _progressLayer.lineWidth = kProgressWidth;
    _progressLayer.path = [path CGPath];
    _progressLayer.strokeEnd = 0;
    
    //设置渐变颜色
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    
    // 渐变颜色
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[UIColor ALKeyColor].CGColor, (id)[UIColor ALKeyColor].CGColor,  nil]];
    
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [gradientLayer setMask:_progressLayer];     //用progressLayer来截取渐变层
    [self.layer addSublayer:gradientLayer];
}

- (void)setProgressPercentage:(CGFloat)progressPercentage {
    _progressPercentage = progressPercentage;
    _progressLayer.strokeEnd = progressPercentage;
    [_progressLayer removeAllAnimations];
}

#pragma mark - public
- (void)startShootAnimationWithDuration:(NSTimeInterval)duration {
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:duration animations:^{
        weakSelf.transform = CGAffineTransformMakeScale(kShootBtnScale, kShootBtnScale);
        weakSelf.touchView.transform = CGAffineTransformMakeScale(kShootTouchViewScale, kShootTouchViewScale);
    } completion:nil];
}

- (void)stopShootAnimation {
    self.transform = CGAffineTransformIdentity;
    self.touchView.transform = CGAffineTransformIdentity;
}

#pragma mark - 点击事件与长按事件
- (void)configureTapSnapButtonEventWithBlock:(ALCameraSnapTapBlock)tapEventBlock {
    self.tapEventBlock = tapEventBlock;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCameraButtonEvent:)];
    
    [self.touchView addGestureRecognizer:tapGestureRecognizer];
}

- (void)tapCameraButtonEvent:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.tapEventBlock) {
        self.tapEventBlock(tapGestureRecognizer);
    }
}

/**
 *  配置按压事件
 */
- (void)configureLongPressSnapButtonEventWithBlock:(ALCameraSnapLongPressBlock)longPressEventBlock {
    self.longPressEventBlock = longPressEventBlock;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCameraButtonEvent:)];
    
    [self.touchView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)longPressCameraButtonEvent:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (self.longPressEventBlock){
        self.longPressEventBlock(longPressGestureRecognizer);
    }
}



@end
