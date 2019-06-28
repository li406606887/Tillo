//
//  YMRTCCallingView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YMRTCDataItem.h"

@class YMRTCCallingView;
@protocol YMRTCCallingViewDelegate <NSObject>

@optional
//点击挂断
- (void)callingViewDidHangupBtnClick:(YMRTCCallingView *)callingView;

//接收者点击拒绝
- (void)callingViewDidRefuseBtnClick:(YMRTCCallingView *)callingView;

//接收者点击接听
- (void)callingViewDidAcceptBtnClick:(YMRTCCallingView *)callingView;

//点击切换语音
- (void)callingViewDidSwapAudioBtnClick:(YMRTCCallingView *)callingView;


@end

@interface YMRTCCallingView : UIView

- (instancetype)initWithDataItem:(YMRTCDataItem *)dataItem;

@property (nonatomic, weak) id <YMRTCCallingViewDelegate> delegate;

- (void)initOperateViews;
- (void)removeBlurView;
- (void)swapAudioBtnClick:(UIButton *)sender;


@end

