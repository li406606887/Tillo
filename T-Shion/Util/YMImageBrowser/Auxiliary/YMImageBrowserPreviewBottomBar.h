//
//  YMImageBrowserPreviewBottomBar.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/23.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMImageBrowserToolBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YMImageBrowserPreviewBottomBar;

@protocol YMImageBrowserPreviewBottomBarDelegate <NSObject>

/** 点击发送按钮, 要回调并发送图片或视频 */
- (void)ym_imageBrowserPreviewBottomBar:(YMImageBrowserPreviewBottomBar *)topBar clickSendButton:(UIButton *)button;

@end


@interface YMImageBrowserPreviewBottomBar : UIView<YMImageBrowserToolBarProtocol>

@property (nonatomic, weak) id <YMImageBrowserPreviewBottomBarDelegate> delegate;

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize;

@end

NS_ASSUME_NONNULL_END
