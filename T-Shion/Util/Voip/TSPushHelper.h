//
//  TSPushHelper.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/8.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSPushHelper : NSObject

+ (instancetype)shareInstance;

- (void)registerNotifications;

@end
