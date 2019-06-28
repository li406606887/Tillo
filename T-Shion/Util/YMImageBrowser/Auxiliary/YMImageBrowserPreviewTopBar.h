//
//  YMImageBrowserPreviewTopBar.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/23.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMImageBrowserToolBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YMImageBrowserPreviewTopBar;

@protocol YMImageBrowserPreviewTopBarDelegate <NSObject>

/** 点击返回按钮 */
- (void)ym_imageBrowserPreviewTopBar:(YMImageBrowserPreviewTopBar *)topBar clickBackButton:(UIButton *)button;

@end

@interface YMImageBrowserPreviewTopBar : UIView<YMImageBrowserToolBarProtocol>

@property (nonatomic, weak) id <YMImageBrowserPreviewTopBarDelegate> delegate;

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize;

@end

NS_ASSUME_NONNULL_END
