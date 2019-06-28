//
//  ALCameraSnapButton.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/15.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ALCameraSnapTapBlock)(UITapGestureRecognizer *tapGesture);
typedef void(^ALCameraSnapLongPressBlock)(UILongPressGestureRecognizer *longPressGesture);


@interface ALCameraSnapButton : UIView

/**
 *  设置进度条的录制视频时长百分比 = 当前录制时间 / 最大录制时间
 */
@property (nonatomic, assign) CGFloat progressPercentage;

+ (instancetype)defaultSnapButton;

/**
 *  配置点击事件
 */
- (void)configureTapSnapButtonEventWithBlock:(ALCameraSnapTapBlock)tapEventBlock;

/**
 *  配置按压事件
 */
- (void)configureLongPressSnapButtonEventWithBlock:(ALCameraSnapLongPressBlock)longPressEventBlock;

/**
 *  开始录制前的准备动画
 */
- (void)startShootAnimationWithDuration:(NSTimeInterval)duration;

/**
 *  结束摄影动画
 */
- (void)stopShootAnimation;


@end

