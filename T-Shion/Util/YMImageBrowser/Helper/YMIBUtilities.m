//
//  YMIBUtilities.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMIBUtilities.h"
#import <sys/utsname.h>

UIWindow *YMIBGetNormalWindow(void) {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *temp in windows) {
            if (temp.windowLevel == UIWindowLevelNormal) {
                window = temp; break;
            }
        }
    }
    return window;
}

UIViewController *YMIBGetTopController(void) {
    UIViewController *topController = nil;
    UIWindow *window = YMIBGetNormalWindow();
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:UIViewController.class]) {
        topController = nextResponder;
    } else {
        topController = window.rootViewController;
    }
    
    while ([topController isKindOfClass:UITabBarController.class] || [topController isKindOfClass:UINavigationController.class]) {
        if ([topController isKindOfClass:UITabBarController.class]) {
            topController = ((UITabBarController *)topController).selectedViewController;
        } else if ([topController isKindOfClass:UINavigationController.class]) {
            topController = ((UINavigationController *)topController).topViewController;
        }
    }
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


BOOL YMIBLowMemory(void) {
    static BOOL lowMemory = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned long long physicalMemory = [[NSProcessInfo processInfo] physicalMemory];
        lowMemory = physicalMemory > 0 && physicalMemory < 1024 * 1024 * 1500;
    });
    return lowMemory;
}

@implementation YMIBUtilities

+ (BOOL)isIphoneX {
    static BOOL isIphoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet *platformSet = [NSSet setWithObjects:@"iPhone10,3", @"iPhone10,6", @"iPhone11,8", @"iPhone11,2", @"iPhone11,4", @"iPhone11,6", nil];
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"]) {
            platform = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
        }
        isIphoneX = [platformSet containsObject:platform];
    });
    return isIphoneX;
}


@end
