//
//  VoipHelper.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/8.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "VoipHelper.h"
#import "TSPushHelper.h"

@interface VoipHelper () <PKPushRegistryDelegate>


@end

@implementation VoipHelper

static VoipHelper *instance = nil;

+ (VoipHelper *)shareInstance {
    if (!instance) {
        instance = [[super allocWithZone:NULL] init];
    }
    return instance;
}

- (void)initWithServer {
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    [[TSPushHelper shareInstance] registerNotifications];
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    if([pushCredentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@",pushCredentials.token];
    NSString *_tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"device_token is %@" , _tokenStr);
    
    [SocketViewModel shared].deviceToken = _tokenStr;
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if (userId.length > 10) {
        [[SocketViewModel shared] uploadDeviceToken];
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
   
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveIncomingPushWithPayload:)]) {
        [self.delegate didReceiveIncomingPushWithPayload:payload];
    }
    
}

@end
