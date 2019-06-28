//
//  MPConfig.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPConfig.h"
#import "GSKeyChainDataManager.h"

@implementation MPConfig

+ (MPConfig *)defaultConfig{
    static MPConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        config = [[MPConfig alloc] init];
        NSString *URL = MpushHostUrl;
        config.allotServer = URL;
        config.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC/V/CXu9bNjIuOYi9jRw2Jn8x59caK4W0TqB5usmIkN0w9GJlOkjTZl6ED+YycZ/+1yzIqF33ES7QfWiY7PgxJYkETEk5WBzh5mQ6zd1Byw6ctMcZJmCDWkDSLC1Y3fx0EkSRJdDeUyUpSXrw9eC4wj0ryVpSQVW0ovLcYvSqxSQIDAQAB";
        NSLog(@"%@",[GSKeyChainDataManager readUUID]);
        config.deviceId = [GSKeyChainDataManager readUUID];
        config.osName = @"ios";
        config.osVersion = [[UIDevice currentDevice] systemVersion];
        config.clientVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        config.maxHeartbeat = 30;
        config.minHeartbeat = 30;
        config.aesKeyLength = 16;
        config.compressLimit = 10240;
        
        config.maxConnectTimes = 6;
        config.maxHBTimeOutTimes = 2;
//        config.logEnabled = false;
//        config.enableHttpProxy = false;
    });
    return config;
}

@end
