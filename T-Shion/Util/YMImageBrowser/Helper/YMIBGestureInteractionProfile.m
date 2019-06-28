//
//  YMIBGestureInteractionProfile.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMIBGestureInteractionProfile.h"

@implementation YMIBGestureInteractionProfile

- (instancetype)init {
    self = [super init];
    if (self) {
        self.disable = NO;
        self.dismissScale = 0.22;
        self.dismissVelocityY = 800;
        self.restoreDuration = 0.15;
        self.triggerDistance = 3;
        self.isPreviewType = NO;
    }
    return self;
}

@end
