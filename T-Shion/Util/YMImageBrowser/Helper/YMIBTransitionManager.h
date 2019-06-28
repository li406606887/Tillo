//
//  YMIBTransitionManager.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMImageBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMIBTransitionManager : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) YMImageBrowser *imageBrowser;

@property (nonatomic, assign, readonly) BOOL transitioning;

@end

NS_ASSUME_NONNULL_END
