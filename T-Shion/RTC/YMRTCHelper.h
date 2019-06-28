//
//  YMRTCHelper.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/20.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMRTCDataItem.h"


@interface YMRTCHelper : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) YMRTCDataItem *currentRtcItem;

@end

