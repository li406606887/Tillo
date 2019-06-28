//
//  AppDelegate+Prometheus.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "AppDelegate+Prometheus.h"
#import "LEEAlert.h"

#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

@implementation AppDelegate (Prometheus)

- (void)checkNewPrometheus {
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self requestData];
        
        NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"];
        
        if (refreshToken.length > 0) {
//            [[SocketViewModel shared].refreshTokenCommand execute:@{@"refreshToken":refreshToken}];
        }

    });
}

- (void)requestData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        RequestModel *model = [TSRequest getRequetWithApi:api_get_newVersion withParam:nil error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                return;
            }
            @strongify(self);
            [self showAlertWithData:model.data];
        });
    });
}

- (void)showAlertWithData:(NSDictionary *)data {
    NSLog(@"%@",data);
    if (!data) {
        return;
    }
    
    NSString *versionNo = data[@"versionNo"];
    
    if ([versionNo compare:kAppVersion options:NSNumericSearch] != NSOrderedDescending) {
        return;
    }
    
    NSString *tempVersionNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"tempVersionNo"];
    
    switch ([data[@"online"] integerValue]) {
        case 0:
            break;
            
        case 1: {
            
            if ([versionNo compare:tempVersionNo options:NSNumericSearch] != NSOrderedDescending) {
                return;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:versionNo forKey:@"tempVersionNo"];
            [LEEAlert alert].config
            .LeeTitle(@"检测到新版本")
            .LeeContent(data[@"updateMsg"])
            .LeeAddAction(^(LEEAction *action) {
                action.type = LEEActionTypeDefault;
                action.title = @"以后再说";
                action.titleColor = [UIColor ALTextNormalColor];
            })
            .LeeAddAction(^(LEEAction *action) {
                action.type = LEEActionTypeDefault;
                action.title = @"现在更新";
                action.titleColor = [UIColor ALBlueColor];
                action.clickBlock = ^{
                    NSURL *url = [NSURL URLWithString:data[@"versionUrl"]];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                };
            })
            .LeeShow();
        }
            break;
            
        case 2: {
            
            [LEEAlert alert].config
            .LeeTitle(@"检测到新版本")
            .LeeContent(data[@"updateMsg"])
            .LeeAddAction(^(LEEAction *action) {
                action.type = LEEActionTypeDefault;
                action.title = @"现在更新";
                action.titleColor = [UIColor ALBlueColor];
                action.isClickNotClose = YES;
                action.clickBlock = ^{
                    NSURL *url = [NSURL URLWithString:data[@"versionUrl"]];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                };
            })
            .LeeShow();
            
        }
            break;
            
        default:
            break;
    }
}

@end
