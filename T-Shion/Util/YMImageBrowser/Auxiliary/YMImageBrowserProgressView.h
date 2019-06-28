//
//  YMImageBrowserProgressView.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/15.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YMImageBrowserProgressView;

@interface UIView (YMImageBrowserProgressView)

- (void)ym_showProgressViewWithValue:(CGFloat)progress;

- (void)ym_showProgressViewLoading;

- (void)ym_showProgressViewWithText:(NSString *)text click:(nullable void(^)(void))click;

- (void)ym_hideProgressView;

@property (nonatomic, strong, readonly) YMImageBrowserProgressView *ym_progressView;

@end


@interface YMImageBrowserProgressView : UIView

- (void)showProgress:(CGFloat)progress;

- (void)showLoading;

- (void)showText:(NSString *)text click:(void(^)(void))click;

@end

