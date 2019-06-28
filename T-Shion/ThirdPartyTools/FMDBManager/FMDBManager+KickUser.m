//
//  FMDBManager+KickUser.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/25.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "FMDBManager+KickUser.h"

@implementation FMDBManager (KickUser)

+ (BOOL)updateKickLog:(NSDictionary *)logDict {
    
    __block BOOL success = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            NSString *userId = logDict[@"user_id"];
            NSString *userName = logDict[@"userName"];
            NSString *requestURL = logDict[@"requestURL"];
            NSString *timeStr = logDict[@"timeStr"];
            NSString *deviceId = logDict[@"deviceId"];
            NSString *token = logDict[@"token"];

            BOOL result = [db executeUpdate:@"INSERT INTO KickUserLog (user_id, userName, requestURL, timeStr, deviceId, token) VALUES(?, ?, ?, ?, ?, ?);" withArgumentsInArray:@[userId, userName, requestURL, timeStr, deviceId, token]];

            success = result;
        }
    }];
    
    return success;
}

+ (BOOL)updateMpushConnectLog:(NSDictionary *)logDict {
    __block BOOL success = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            NSString *userId = logDict[@"user_id"];
            NSString *userName = logDict[@"userName"];
            NSString *requestURL = logDict[@"requestURL"];
            NSString *timeStr = logDict[@"timeStr"];
            NSString *deviceId = logDict[@"deviceId"];
            NSString *token = logDict[@"token"];
            
            BOOL result = [db executeUpdate:@"INSERT INTO MpushConnectLog (user_id, userName, requestURL, timeStr, deviceId, token) VALUES(?, ?, ?, ?, ?, ?);" withArgumentsInArray:@[userId, userName, requestURL, timeStr, deviceId, token]];
            
            success = result;
        }
    }];
    
    return success;
}

@end
