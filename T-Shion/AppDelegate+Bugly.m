//
//  AppDelegate+Bugly.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "AppDelegate+Bugly.h"
#import <Bugly/Bugly.h>
#import "GSKeyChainDataManager.h"

static NSString *kBuglyTestAppId = @"994d3334be";
static NSString *kBuglyReleaseAppId = @"792ec651a3";

@implementation AppDelegate (Bugly)

- (void)configureBugly {
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.unexpectedTerminatingDetectionEnable = YES;
    config.reportLogLevel = BuglyLogLevelWarn;
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 5;
    config.deviceIdentifier = [GSKeyChainDataManager readUUID];
    config.debugMode = YES;
    
#ifdef AilloTest
    [Bugly startWithAppId:kBuglyTestAppId config:config];
#endif
    
#ifdef AilloRelease
    [Bugly startWithAppId:kBuglyReleaseAppId config:config];
#endif
    
}

@end
