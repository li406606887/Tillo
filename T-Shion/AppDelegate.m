//
//  AppDelegate.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AppDelegate.h"
#import "VoipHelper.h"
#import "GSKeyChainDataManager.h"
#import "WebRTCHelper.h"
#import "AppDelegate+Prometheus.h"
#import "AppDelegate+Bugly.h"
#import "SettingViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlacePicker/GooglePlacePicker.h>

#import "YMDownloadSession.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self monitorNetworking];//开启网络监听
    [self saveUUID];
    [self loadingLanguage];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor blackColor];
    NSString *access = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if (access.length > 10 && userId.length > 10) {
        self.window.rootViewController = self.slideVC;
        [self setUpDownLoad];
    } else {
        self.window.rootViewController = self.nav;
    }
    [[UITextField appearance] setTintColor:[UIColor ALKeyColor]];
    
    [[VoipHelper shareInstance] initWithServer];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBzg4X2rwx8dvNHnwdsbnA6wAgP0bno9GE"];
    [GMSServices provideAPIKey:@"AIzaSyBzg4X2rwx8dvNHnwdsbnA6wAgP0bno9GE"];
    
    //检查版本
    [self checkNewPrometheus];
    //错误日志统计
    [self configureBugly];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setUpDownLoad {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    path = [path stringByAppendingPathComponent:@"YMDownload"];
    YMDownLoadConfig *config = [YMDownLoadConfig new];
    config.saveRootPath = path;
    config.uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    config.maxTaskCount = INT_MAX;
    config.taskCachekMode = YMDownloadTaskCacheModeDefault;
    config.launchAutoResumeDownload = NO;//冷启动不进行从新下载
    [YMDownloadManager mgrWithConfig:config];
    [YMVideoDownloadManager mgrWithConfig:config];
    
    config.maxTaskCount = 5;
    [YMImageDownloadManager mgrWithConfig:config];
    [YMImageDownloadManager allowsCellularAccess:YES];
    [YMVideoDownloadManager allowsCellularAccess:YES];
    [YMDownloadManager allowsCellularAccess:YES];
    
    [YMImageDownloadManager removeAllCache];
    [YMVideoDownloadManager removeAllCache];
    [YMDownloadManager removeAllCache];
    
    
//    id exitWillTerminate = [[NSUserDefaults standardUserDefaults] objectForKey:@"exitWillTerminate"];
//    
//    if (![exitWillTerminate boolValue]) {
//        //是否正常退出
//        [YMImageDownloadManager removeAllCache];
//        [YMVideoDownloadManager removeAllCache];
//        [YMDownloadManager removeAllCache];
//    } else {
//        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"exitWillTerminate"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    
//    [YMVideoDownloadManager pauseAllDownloadTask];
//    [YMImageDownloadManager pauseAllDownloadTask];
//    [YMDownloadManager pauseAllDownloadTask];
//    [YMImageDownloadManager removeAllCache];
//    [YMVideoDownloadManager removeAllCache];
//    [YMDownloadManager removeAllCache];
    
    if (![[YMDownloadManager manager].uid isEqualToString:config.uid]) {
        [YMDownloadManager updateUid:config.uid];
    }
    
    if (![[YMVideoDownloadManager manager].uid isEqualToString:config.uid]) {
        [YMVideoDownloadManager updateUid:config.uid];
    }
    
    if (![[YMImageDownloadManager manager].uid isEqualToString:config.uid]) {
        [YMImageDownloadManager updateUid:config.uid];
    }
}

/*
 * 加载本地语言
 * 根据本地语言选择显示
 */
- (void)loadingLanguage {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]) {
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        if ([language hasPrefix:@"zh-Hans"]) {//开头匹配
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
        }
    }
}

/**
 *  保存UDID
 */
- (void)saveUUID{
    NSString *udid = [GSKeyChainDataManager readUUID];
    if (udid == nil) {
        NSString *deviceUUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
        [GSKeyChainDataManager saveUUID:deviceUUID];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"应用退出第一响应");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"应用退出退到后台");
    [[SocketViewModel shared] endDisConnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    } else {
        // Fallback on earlier versions
    }
    
    [[SocketViewModel shared] beginConnect:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"exitWillTerminate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[WebRTCHelper sharedInstance] exitRoom:NO];
    [FMDBManager updateUnsendMessageStatus];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    } else {
        // Fallback on earlier versions
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - getter
- (TabBarViewController *)main {
    if (!_main) {
        _main = [[TabBarViewController alloc] init];
    }
    return _main;
}

- (BaseNavigationViewController *)nav {
    if (!_nav) {
        LoginViewController *login = [[LoginViewController alloc] init];
        @weakify(self)
        login.releaseBlock = ^{
            @strongify(self)
            [[SocketViewModel shared] uploadDeviceToken];
            self->_nav = nil;
            self.window.rootViewController = self.slideVC;
            [self.window makeKeyAndVisible];
            [self setUpDownLoad];
        };
        _nav = [[BaseNavigationViewController alloc] initWithRootViewController:login];
    }
    return _nav;
}

- (ALSlideMenu *)slideVC {
    if (!_slideVC) {
        _slideVC = [[ALSlideMenu alloc] initWithRootViewController:self.main];
        _slideVC.leftViewController = [SettingViewController new];
        @weakify(self);
        _slideVC.releaseBlock = ^{
            @strongify(self);
            [self->_slideVC removeCache];
            self->_slideVC = nil;
            self->_main = nil;
            self.window.rootViewController = self.nav;
            [self.window makeKeyAndVisible];
        };
        [FMDBManager updateUnsendMessageStatus];
    }
    return _slideVC;
}

@end
