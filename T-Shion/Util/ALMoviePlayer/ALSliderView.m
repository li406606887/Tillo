//
//  ALSliderView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALSliderView.h"
#import "UIView+ALFrame.h"

/** 滑块的大小 */
static const CGFloat kSliderBtnWH = 19.0;
/** 间距 */
static const CGFloat kProgressMargin = 2.0;
/** 进度的高度 */
static const CGFloat kProgressH = 2.0;
/** 拖动slider动画的时间*/
static const CGFloat kAnimate = 0.3;

@implementation ALSliderButton

// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    // 扩大点击区域
    bounds = CGRectInset(bounds, -20, -20);
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}

@end

@interface ALSliderView ()

/** 进度背景 */
@property (nonatomic, strong) UIImageView *bgProgressView;
/** 缓存进度 */
@property (nonatomic, strong) UIImageView *bufferProgressView;
/** 滑动进度 */
@property (nonatomic, strong) UIImageView *sliderProgressView;
/** 滑块 */
@property (nonatomic, strong) ALSliderButton *sliderBtn;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end



@implementation ALSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.allowTapped = YES;
        self.animate = YES;
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.allowTapped = YES;
    self.animate = YES;
    [self addSubViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 初始化frame
    if (self.sliderBtn.hidden) {
        self.bgProgressView.al_width   = self.al_width;
    } else {
        self.bgProgressView.al_width   = self.al_width - kProgressMargin * 2;
    }
    
    self.bgProgressView.al_centerY     = self.al_height * 0.5;
    self.bufferProgressView.al_centerY = self.al_height * 0.5;
    self.sliderProgressView.al_centerY = self.al_height * 0.5;
    self.sliderBtn.al_centerY          = self.al_height * 0.5;
    
    /// 修复slider  bufferProgress错位问题
    CGFloat finishValue = self.bgProgressView.al_width * self.bufferValue;
    self.bufferProgressView.al_width = finishValue;
    self.sliderProgressView.al_left = kProgressMargin;
    self.bufferProgressView.al_left = kProgressMargin;
    
    CGFloat progressValue  = self.bgProgressView.al_width * self.value;
    self.sliderProgressView.al_width = progressValue;
    self.sliderBtn.al_left = (self.al_width - self.sliderBtn.al_width) * self.value;
}


- (void)addSubViews {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgProgressView];
    [self addSubview:self.bufferProgressView];
    [self addSubview:self.sliderProgressView];
    [self addSubview:self.sliderBtn];
    
    // 初始化frame
    self.bgProgressView.frame = CGRectMake(kProgressMargin, 0, 0, kProgressH);
    self.bufferProgressView.frame = self.bgProgressView.frame;
    self.sliderProgressView.frame = self.bgProgressView.frame;
    self.sliderBtn.frame = CGRectMake(0, 0, kSliderBtnWH, kSliderBtnWH);
    
    // 添加点击手势
//    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//    [self addGestureRecognizer:self.tapGesture];
//    
//    // 添加滑动手势
//    UIPanGestureRecognizer *sliderGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGesture:)];
//    [self addGestureRecognizer:sliderGesture];
}

#pragma mark - Setter

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
    _bufferTrackTintColor = bufferTrackTintColor;
    self.bufferProgressView.backgroundColor = bufferTrackTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    self.bgProgressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    self.sliderProgressView.image = minimumTrackImage;
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    self.bufferProgressView.image = bufferTrackImage;
    self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setValue:(float)value {
    if (isnan(value)) return;
    _value = value;
    self.sliderBtn.al_left = (self.al_width - self.sliderBtn.al_width) * value;
    self.sliderProgressView.frame = CGRectMake(self.bgProgressView.al_x, self.bgProgressView.al_y, self.sliderBtn.al_centerX, self.bgProgressView.al_height);
    self.lastPoint = self.sliderBtn.center;
}

- (void)setBufferValue:(float)bufferValue {
    if (isnan(bufferValue)) return;
    _bufferValue = bufferValue;
    CGFloat finishValue = self.bgProgressView.al_width * bufferValue;
    self.bufferProgressView.al_width = finishValue;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
    [self.sliderBtn sizeToFit];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
    [self.sliderBtn sizeToFit];
}

- (void)setAllowTapped:(BOOL)allowTapped {
    _allowTapped = allowTapped;
    if (!allowTapped) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    if (isnan(sliderHeight)) return;
    _sliderHeight = sliderHeight;
    self.bgProgressView.al_height     = sliderHeight;
    self.bufferProgressView.al_height = sliderHeight;
    self.sliderProgressView.al_height = sliderHeight;
}

- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock {
    _isHideSliderBlock = isHideSliderBlock;
    // 隐藏滑块，滑杆不可点击
    if (isHideSliderBlock) {
        self.sliderBtn.hidden = YES;
        self.bgProgressView.al_left     = 0;
        self.bufferProgressView.al_left = 0;
        self.sliderProgressView.al_left = 0;
        self.allowTapped = NO;
    }
}

#pragma mark - User Action

- (void)sliderGesture:(UIGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self sliderBtnTouchBegin:self.sliderBtn];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            [self sliderBtnDragMoving:self.sliderBtn point:[gesture locationInView:self]];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self sliderBtnTouchEnded:self.sliderBtn];
        }
            break;
        default:
            break;
    }
}

- (void)sliderBtnTouchBegin:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(al_sliderTouchBegan:)]) {
        [self.delegate al_sliderTouchBegan:self.value];
    }
    if (self.animate) {
        [UIView animateWithDuration:kAnimate animations:^{
            btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(al_sliderTouchEnded:)]) {
        [self.delegate al_sliderTouchEnded:self.value];
    }
    if (self.animate) {
        [UIView animateWithDuration:kAnimate animations:^{
            btn.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn point:(CGPoint)touchPoint {
    // 点击的位置
    CGPoint point = touchPoint;
    // 获取进度值 由于btn是从 0-(self.width - btn.width)
    float value = (point.x - btn.al_width * 0.5) / (self.al_width - btn.al_width);
    // value的值需在0-1之间
    value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
    if (self.value == value) return;
    self.isForward = self.value < value;
    [self setValue:value];
    if ([self.delegate respondsToSelector:@selector(al_sliderValueChanged:)]) {
        [self.delegate al_sliderValueChanged:value];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    // 获取进度
    float value = (point.x - self.bgProgressView.al_left) * 1.0 / self.bgProgressView.al_width;
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    [self setValue:value];
    if ([self.delegate respondsToSelector:@selector(al_sliderTapped:)]) {
        [self.delegate al_sliderTapped:value];
    }
}

#pragma mark - getter

- (UIView *)bgProgressView {
    if (!_bgProgressView) {
        _bgProgressView = [UIImageView new];
        _bgProgressView.backgroundColor = [UIColor grayColor];
        _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bgProgressView.clipsToBounds = YES;
    }
    return _bgProgressView;
}

- (UIView *)bufferProgressView {
    if (!_bufferProgressView) {
        _bufferProgressView = [UIImageView new];
        _bufferProgressView.backgroundColor = [UIColor whiteColor];
        _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bufferProgressView.clipsToBounds = YES;
    }
    return _bufferProgressView;
}

- (UIView *)sliderProgressView {
    if (!_sliderProgressView) {
        _sliderProgressView = [UIImageView new];
        _sliderProgressView.backgroundColor = [UIColor redColor];
        _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}

- (ALSliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [ALSliderButton buttonWithType:UIButtonTypeCustom];
        [_sliderBtn setAdjustsImageWhenHighlighted:NO];
    }
    return _sliderBtn;
}


@end
