//
//  DownSettingManager.m
//  AilloTest
//
//  Created by mac on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "YMDownSettingManager.h"
#import "FMDBManager.h"
#import <AFNetworking.h>
static YMDownSettingManager *manager = nil;

@interface YMDownSettingManager ()

@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation YMDownSettingManager

+ (instancetype)defaultManager {
    if (!manager) {
        manager = [[YMDownSettingManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseManager) name:@"exitLogin" object:nil];
    }
    return manager;
}
#pragma mark - public
+ (BOOL)photoAutoDownload {
    if ([YMDownSettingManager defaultManager].autoDownloadPhoto == 1 && [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi) {
        return YES;
    }
    else if ([YMDownSettingManager defaultManager].autoDownloadPhoto == 2)
        return YES;
    else
        return NO;
}
+ (BOOL)videoAutoDownload {
    if ([YMDownSettingManager defaultManager].autoDownloadVideo == 1 && [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi) {
        return YES;
    }
    else if ([YMDownSettingManager defaultManager].autoDownloadVideo == 2)
        return YES;
    else
        return NO;
}
+ (BOOL)fileAutoDownload {
    if ([YMDownSettingManager defaultManager].autoDownloadFile == 1 && [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi) {
        return YES;
    }
    else if ([YMDownSettingManager defaultManager].autoDownloadFile == 2)
        return YES;
    else
        return NO;
}

//退出登录时要清数据
+ (void)releaseManager {
    manager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"exitLogin" object:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        [self loadDBStore];
    }
    return self;
}

- (void)setAutoDownloadPhoto:(NSInteger)autoDownloadPhoto {
    _autoDownloadPhoto = autoDownloadPhoto;
    if (self.isLoaded) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"UPDATE YMDownloadSetting SET autoDownloadPhoto = ?", @(autoDownloadPhoto)];
            if (success) {
                NSLog(@"修改自动下载图片配置成功");
            }
        }];
    }
}

- (void)setAutoDownloadVideo:(NSInteger)autoDownloadVideo {
    _autoDownloadVideo = autoDownloadVideo;
    if (self.isLoaded) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"UPDATE YMDownloadSetting SET autoDownloadVideo = ?", @(autoDownloadVideo)];
            if (success) {
                NSLog(@"修改自动下载视频配置成功");
            }
        }];
    }
}

- (void)setAutoDownloadFile:(NSInteger)autoDownloadFile {
    _autoDownloadFile = autoDownloadFile;
    if (self.isLoaded) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"UPDATE YMDownloadSetting SET autoDownloadFile = ?", @(autoDownloadFile)];
            if (success) {
                NSLog(@"修改自动下载文件配置成功");
            }
        }];
    }
}

- (void)setAutoSavePhoto:(BOOL)autoSavePhoto {
    _autoSavePhoto = autoSavePhoto;
    if (self.isLoaded) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"UPDATE YMDownloadSetting SET autoSavePhoto = ?", @(autoSavePhoto)];
            if (success) {
                NSLog(@"修改自动保存视频配置成功");
            }
        }];
    }
}

- (void)setAutoSaveVideo:(BOOL)autoSaveVideo {
    _autoSaveVideo = autoSaveVideo;
    if (self.isLoaded) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"UPDATE YMDownloadSetting SET autoSaveVideo = ?", @(autoSaveVideo)];
            if (success) {
                NSLog(@"修改自动保存图片配置成功");
            }
        }];
    }
}

- (void)loadDBStore {
    @weakify(self)
    self.isLoaded = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMDownloadSetting"];
        @strongify(self)
        if (result.next) {
            self.autoDownloadPhoto = [result intForColumn:@"autoDownloadPhoto"];
            self.autoDownloadVideo = [result intForColumn:@"autoDownloadVideo"];
            self.autoDownloadFile = [result intForColumn:@"autoDownloadFile"];
            self.autoSavePhoto = [result boolForColumn:@"autoSavePhoto"];
            self.autoSaveVideo = [result boolForColumn:@"autoSaveVideo"];
        }
        else {
            self.autoSavePhoto = 0;
            self.autoSaveVideo = 0;
            self.autoDownloadFile = 1;
            self.autoDownloadPhoto = 1;
            self.autoDownloadVideo = 1;
            BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS YMDownloadSetting (autoDownloadPhoto INT32, autoDownloadVideo INT32, autoDownloadFile INT32, autoSavePhoto INT32, autoSaveVideo INT32)"];
            if (success) {
                success = [db executeUpdate:@"INSERT INTO YMDownloadSetting (autoDownloadPhoto, autoDownloadVideo, autoDownloadFile, autoSavePhoto, autoSaveVideo) VALUES (?, ?, ?, ?, ?)", @"1", @"1", @"1", @"0", @"0"];
                if (success) {
                    NSLog(@"保存自动下载配置默认值成功");
                }
            }
        }
        [result close];
        self.isLoaded = YES;
    }];
}

@end
