//
//  YMIBLayoutDirectionManager.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YMImageBrowserLayoutDirection) {
    // 未知.
    YMImageBrowserLayoutDirectionUnknown,
    // 垂直.
    YMImageBrowserLayoutDirectionVertical,
    // 水平.
    YMImageBrowserLayoutDirectionHorizontal
};


@interface YMIBLayoutDirectionManager : NSObject

- (void)startObserve;

@property (nonatomic, copy) void(^layoutDirectionChangedBlock)(YMImageBrowserLayoutDirection);

+ (YMImageBrowserLayoutDirection)getLayoutDirectionByStatusBar;

@end

