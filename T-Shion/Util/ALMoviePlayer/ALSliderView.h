//
//  ALSliderView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALSliderViewDelegate <NSObject>

@optional
// 滑块滑动开始
- (void)al_sliderTouchBegan:(float)value;

// 滑块滑动中
- (void)al_sliderValueChanged:(float)value;

// 滑块滑动结束
- (void)al_sliderTouchEnded:(float)value;

// 滑杆点击
- (void)al_sliderTapped:(float)value;

@end


@interface ALSliderButton : UIButton

@end


@interface ALSliderView : UIView

@property (nonatomic, weak) id <ALSliderViewDelegate> delegate;

/** 滑块 */
@property (nonatomic, strong, readonly) ALSliderButton *sliderBtn;

/** 默认滑杆的颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;

/** 滑杆进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;

/** 缓存进度颜色 */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;

/** 默认滑杆的图片 */
@property (nonatomic, strong) UIImage *maximumTrackImage;

/** 滑杆进度的图片 */
@property (nonatomic, strong) UIImage *minimumTrackImage;

/** 缓存进度的图片 */
@property (nonatomic, strong) UIImage *bufferTrackImage;

/** 滑杆进度 */
@property (nonatomic, assign) float value;

/** 缓存进度 */
@property (nonatomic, assign) float bufferValue;

/** 是否允许点击，默认是YES */
@property (nonatomic, assign) BOOL allowTapped;

/** 是否允许点击，默认是YES */
@property (nonatomic, assign) BOOL animate;

/** 设置滑杆的高度 */
@property (nonatomic, assign) CGFloat sliderHeight;

/** 是否隐藏滑块（默认为NO） */
@property (nonatomic, assign) BOOL isHideSliderBlock;

/// 是否正在拖动
@property (nonatomic, assign) BOOL isdragging;

/// 向前还是向后拖动
@property (nonatomic, assign) BOOL isForward;

//@property (nonatomic, assign) CGFloat ignoreMargin;

// 设置滑块背景色
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;

// 设置滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

@end


