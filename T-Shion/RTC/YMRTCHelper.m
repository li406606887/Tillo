//
//  YMRTCHelper.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/20.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "YMRTCHelper.h"

@implementation YMRTCHelper

static YMRTCHelper *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


@end
