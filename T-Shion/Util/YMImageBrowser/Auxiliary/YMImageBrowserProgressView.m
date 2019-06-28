//
//  YMImageBrowserProgressView.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/15.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowserProgressView.h"
#import <objc/runtime.h>

@implementation UIView (YMImageBrowserProgressView)

- (void)ym_showProgressViewWithValue:(CGFloat)progress {
    [self ym_showProgressView];
    [self.ym_progressView showProgress:progress];
}

- (void)ym_showProgressViewLoading {
    [self ym_showProgressView];
    [self.ym_progressView showLoading];
}

- (void)ym_showProgressViewWithText:(NSString *)text click:(nullable void (^)(void))click {
    [self ym_showProgressView];
    [self.ym_progressView showText:text click:click];
}

- (void)ym_showProgressView {
    YMImageBrowserProgressView *progressView = self.ym_progressView;
    if (!progressView) {
        progressView = [YMImageBrowserProgressView new];
        self.ym_progressView = progressView;
    }
    
    if (!progressView.superview) {
        [self addSubview:progressView];
        progressView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *layA = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *layB = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *layC = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *layD = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraints:@[layA, layB, layC, layD]];
    }
}

- (void)ym_hideProgressView {
    YMImageBrowserProgressView *progressView = self.ym_progressView;
    if (progressView && progressView.superview) {
        [progressView removeFromSuperview];
    }
}

- (void)setYm_progressView:(YMImageBrowserProgressView * _Nonnull)ym_progressView {
    objc_setAssociatedObject(self, "YMImageBrowserProgressView", ym_progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YMImageBrowserProgressView *)ym_progressView {
    return objc_getAssociatedObject(self, "YMImageBrowserProgressView");
}

@end


@interface YMImageBrowserProgressDrawView : UIView

@property (nonatomic, assign) CGFloat progress;

@end

@implementation YMImageBrowserProgressDrawView
- (void)drawRect:(CGRect)rect {
    if (self.isHidden) return;
    
    CGFloat radius = 17;
    CGFloat strokeWidth = 3;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    [[UIColor lightGrayColor] setStroke];
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    bottomPath.lineWidth = 4.0;
    bottomPath.lineCapStyle = kCGLineCapRound;
    bottomPath.lineJoinStyle = kCGLineCapRound;
    [bottomPath stroke];
    
    [[UIColor whiteColor] setStroke];
    UIBezierPath *activePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI / 2.0 endAngle:M_PI * 2 * _progress - M_PI / 2.0 clockwise:true];
    activePath.lineWidth = strokeWidth;
    activePath.lineCapStyle = kCGLineCapRound;
    activePath.lineJoinStyle = kCGLineCapRound;
    [activePath stroke];
    
    NSString *string = [NSString stringWithFormat:@"%.0lf%@", _progress * 100, @"%"];
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    CGSize size = atts.size;
    [atts drawAtPoint:CGPointMake(center.x - size.width / 2.0, center.y - size.height / 2.0)];
}

@end


typedef NS_ENUM(NSUInteger, YMImageBrowserProgressType) {
    YMImageBrowserProgressTypeProgress,
    YMImageBrowserProgressTypeLoad,
    YMImageBrowserProgressTypeText
};

@interface YMImageBrowserProgressView () {
    YMImageBrowserProgressType  _type;
}

@property (nonatomic, strong) UILabel     *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YMImageBrowserProgressDrawView *drawView;
@property (nonatomic, copy) void(^clickTextLabelBlock)(void);

@end


@implementation YMImageBrowserProgressView


#pragma mark - 生命周期
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        self.userInteractionEnabled = NO;
        
        [self addSubview:self.drawView];
        [self addSubview:self.textLabel];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)updateConstraints {
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layA = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:20];
    NSLayoutConstraint *layB = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-20];
    NSLayoutConstraint *layC = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layE = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *layF = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    self.drawView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *layG = [NSLayoutConstraint constraintWithItem:self.drawView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *layH = [NSLayoutConstraint constraintWithItem:self.drawView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *layI = [NSLayoutConstraint constraintWithItem:self.drawView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
    NSLayoutConstraint *layJ = [NSLayoutConstraint constraintWithItem:self.drawView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:50];
    
    [self addConstraints:@[layA, layB, layC, layE, layF, layG, layH, layI, layJ]];
    [super updateConstraints];
}

#pragma mark public

- (void)showProgress:(CGFloat)progress {
    self.userInteractionEnabled = NO;
    _type = YMImageBrowserProgressTypeProgress;
    self.drawView.hidden = NO;
    self.textLabel.hidden = YES;
    self.imageView.hidden = YES;
    [self stopImageViewAnimation];
    
    self.drawView.progress = progress;
    [self.drawView setNeedsDisplay];
}

- (void)showLoading {
    self.userInteractionEnabled = NO;
    _type = YMImageBrowserProgressTypeLoad;
    self.drawView.hidden = YES;
    self.textLabel.hidden = YES;
    self.imageView.hidden = NO;
    
    [self startImageViewAnimation];
    [self.drawView setNeedsDisplay];
}

- (void)startImageViewAnimation {
    CABasicAnimation *ra = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    ra.toValue = [NSNumber numberWithFloat:M_PI * 2];
    ra.duration = 1;
    ra.cumulative = YES;
    ra.repeatCount = HUGE_VALF;
    ra.removedOnCompletion = NO;
    ra.fillMode = kCAFillModeForwards;
    [self.imageView.layer addAnimation:ra forKey:@"ra"];
}

- (void)stopImageViewAnimation {
    [self.imageView.layer removeAllAnimations];
}

- (void)showText:(NSString *)text click:(void(^)(void))click {
    self.userInteractionEnabled = click ? YES : NO;
    _type = YMImageBrowserProgressTypeText;
    self.drawView.hidden = YES;
    self.textLabel.hidden = NO;
    self.imageView.hidden = YES;
    [self stopImageViewAnimation];
    
    self.textLabel.text = text;
    self.clickTextLabelBlock = click;
    [self.drawView setNeedsDisplay];
}

#pragma mark - touch event

- (void)respondsToTapTextlabel {
    if (self.clickTextLabelBlock) {
        self.clickTextLabelBlock();
    }
}

#pragma mark - getter

- (YMImageBrowserProgressDrawView *)drawView {
    if (!_drawView) {
        _drawView = [YMImageBrowserProgressDrawView new];
        _drawView.backgroundColor = [UIColor clearColor];
    }
    return _drawView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapTextlabel)];
        [_textLabel addGestureRecognizer:tapGesture];
        _textLabel.userInteractionEnabled = YES;
    }
    return _textLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImage *img = [UIImage imageNamed:@"ymib_pround"];
        _imageView = [UIImageView new];
        _imageView.image = img;
    }
    return _imageView;
}


@end
