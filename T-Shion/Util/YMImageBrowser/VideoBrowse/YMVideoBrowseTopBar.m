//
//  YMVideoBrowseTopBar.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/20.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMVideoBrowseTopBar.h"
#import "YMIBUtilities.h"

static CGFloat kTopBarDefaultsHeight = 50.0;

@interface YMVideoBrowseTopBar ()
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation YMVideoBrowseTopBar

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cancelButton];
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat hExtra = 0;
    if (YMIB_IS_IPHONEX && [UIScreen mainScreen].bounds.size.height < [UIScreen mainScreen].bounds.size.width) hExtra += YMIB_HEIGHT_EXTRABOTTOM;
    
    self.cancelButton.frame = CGRectMake(10 + hExtra, self.bounds.size.height - kTopBarDefaultsHeight, kTopBarDefaultsHeight, kTopBarDefaultsHeight);
    self.gradientLayer.frame = self.bounds;
    [super layoutSubviews];
}

#pragma mark - public

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize {
    CGFloat height = kTopBarDefaultsHeight;
    if (containerSize.height > containerSize.width && YMIB_IS_IPHONEX) height += YMIB_HEIGHT_STATUSBAR;
    return CGRectMake(0, 0, containerSize.width, height);
}

#pragma mark - event

- (void)clickCancelButton:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ym_videoBrowseTopBar:clickCancelButton:)]) {
        [self.delegate ym_videoBrowseTopBar:self clickCancelButton:button];
    }
}

#pragma mark - getter

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"ymib_cancel"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.endPoint = CGPointMake(0.5, 1);
        _gradientLayer.startPoint = CGPointMake(0.5, 0);
        _gradientLayer.colors = @[(id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0.3].CGColor, (id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0].CGColor];
    }
    return _gradientLayer;
}



@end
