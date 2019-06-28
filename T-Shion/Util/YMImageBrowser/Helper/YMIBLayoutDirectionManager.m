//
//  YMIBLayoutDirectionManager.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMIBLayoutDirectionManager.h"

@implementation YMIBLayoutDirectionManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

+ (YMImageBrowserLayoutDirection)getLayoutDirectionByStatusBar {
    UIInterfaceOrientation obr = [UIApplication sharedApplication].statusBarOrientation;
    if ((obr == UIInterfaceOrientationPortrait) || (obr == UIInterfaceOrientationPortraitUpsideDown)) {
        return YMImageBrowserLayoutDirectionVertical;
    } else if ((obr == UIInterfaceOrientationLandscapeLeft) || (obr == UIInterfaceOrientationLandscapeRight)) {
        return YMImageBrowserLayoutDirectionHorizontal;
    } else {
        return YMImageBrowserLayoutDirectionUnknown;
    }
}

- (void)applicationDidChangeStatusBarOrientationNotification:(NSNotification *)note {
    if (self.layoutDirectionChangedBlock) {
        self.layoutDirectionChangedBlock([self.class getLayoutDirectionByStatusBar]);
    }
}


@end
