//
//  YMImageBrowserCellProtocol.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMImageBrowserCellDataProtocol.h"
#import "YMIBGestureInteractionProfile.h"
#import "YMIBLayoutDirectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YMImageBrowserCellProtocol <NSObject>

@required

- (void)ym_initializeBrowserCellWithData:(id<YMImageBrowserCellDataProtocol>)data
                         layoutDirection:(YMImageBrowserLayoutDirection)layoutDirection
                           containerSize:(CGSize)containerSize;

@optional
- (void)ym_browserLayoutDirectionChanged:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

@property (nonatomic, copy) void(^ym_browserDismissBlock)(void);


/**
 工具栏隐藏 hiddenType 0:显示 1:隐藏 2:相册选取预览，根据是否隐藏取反
 */
@property (nonatomic, copy) void(^ym_browserToolBarHiddenBlock)(NSInteger hiddenType);

@property (nonatomic, copy) void(^ym_browserScrollEnabledBlock)(BOOL enabled);

@property (nonatomic, copy) void(^ym_browserChangeAlphaBlock)(CGFloat alpha, CGFloat duration);

- (void)ym_browserPageIndexChanged:(NSUInteger)pageIndex ownIndex:(NSUInteger)ownIndex;

- (void)ym_browserBodyIsInTheCenter:(BOOL)isIn;

- (void)ym_browserInitializeFirst:(BOOL)isFirst;

- (void)ym_browserStatusBarOrientationBefore:(UIInterfaceOrientation)orientation;

- (__kindof UIView *)ym_browserCurrentForegroundView;

- (void)ym_browserSetGestureInteractionProfile:(YMIBGestureInteractionProfile *)giProfile;


@end

NS_ASSUME_NONNULL_END
