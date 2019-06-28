//
//  YMImageBrowserDelegate.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMImageBrowserCellDataProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@class YMImageBrowser;

@protocol YMImageBrowserDelegate <NSObject>

@optional

- (void)ym_imageBrowser:(YMImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YMImageBrowserCellDataProtocol>)data;

- (void)ym_imageBrowser:(YMImageBrowser *)imageBrowser respondsToLongPress:(UILongPressGestureRecognizer *)longPress;

- (void)ym_imageBrowser:(YMImageBrowser *)imageBrowser transitionAnimationEndedWithIsEnter:(BOOL)isEnter;

/** 点击发送按钮, 要回调并发送图片或视频 */
- (void)ym_imageBrowser:(YMImageBrowser *)imageBrowser clickSendButton:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
