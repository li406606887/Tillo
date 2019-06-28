//
//  FMDBManager+SessionStore.m
//  SecureTest
//
//  Created by mac on 2019/3/29.
//  Copyright © 2019 mac. All rights reserved.
//

#import "FMDBManager+SessionStore.h"

@implementation FMDBManager (SessionStore)

- (SessionRecord *)loadSession:(NSString *)contactIdentifier
                               deviceId:(int)deviceId
                        protocolContext:(nullable id)protocolContext {
    __block SessionRecord *record = nil;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier];
        while (result.next) {
            record = [NSKeyedUnarchiver unarchiveObjectWithData:[result objectForColumn:@"session"]];
        }
        [result close];
    }];
    if (!record)
        record = [SessionRecord new];
    return record;
}

- (void)storeSession:(NSString *)contactIdentifier
            deviceId:(int)deviceId
             session:(SessionRecord *)session
     protocolContext:(nullable id)protocolContext {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier];
        BOOL isExist = NO;
        while (result.next) {
            isExist = YES;
            BOOL success = [db executeUpdate:@"UPDATE SessionRecord SET session = ? WHERE contactIdentifier = ?", [NSKeyedArchiver archivedDataWithRootObject:session], contactIdentifier];
            if (!success) {
                NSLog(@"保存SessionRecord失败");
            }
            break;
        }
        [result close];
        if (!isExist) {
            BOOL success = [db executeUpdate:@"INSERT INTO SessionRecord (contactIdentifier, session) VALUES (?, ?)", contactIdentifier, [NSKeyedArchiver archivedDataWithRootObject:session]];
            if (!success) {
                NSLog(@"插入SessionRecord失败：%@", contactIdentifier);
            }
        }
    }];
}

- (BOOL)containsSession:(NSString *)contactIdentifier
               deviceId:(int)deviceId
        protocolContext:(nullable id)protocolContext{
    __block BOOL ret = NO;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier, @(deviceId)];
        while (result.next) {
            ret = YES;
        }
        [result close];
    }];
    return ret;
}

- (void)deleteAllSessionsForContact:(NSString *)contactIdentifier protocolContext:(nullable id)protocolContext {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"DELETE FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier];
        if (!success) {
            NSLog(@"删除SessionRecord失败:%@", contactIdentifier);
        }
    }];
}

- (void)deleteSessionForContact:(nonnull NSString *)contactIdentifier deviceId:(int)deviceId protocolContext:(nullable id)protocolContext {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"DELETE FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier, @(deviceId)];
        if (!success) {
            NSLog(@"删除SessionRecord失败contactIdentifier:%@, deviceId:%d", contactIdentifier, deviceId);
        }
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (nonnull NSArray *)subDevicesSessions:(nonnull NSString *)contactIdentifier protocolContext:(nullable id)protocolContext {
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier];
        while (result.next) {
            SessionRecord *record = [NSKeyedUnarchiver unarchiveObjectWithData:[result objectForColumn:@"session"]];
            [array addObject:record];
        }
        [result close];
    }];
    return array;
}
#pragma clang diagnostic pop

- (void)archiveAllSessionsForContact:(NSString *)contactIdentifier{
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SessionRecord WHERE contactIdentifier=?", contactIdentifier];
        while (result.next) {
            SessionRecord *record = [NSKeyedUnarchiver unarchiveObjectWithData:[result objectForColumn:@"session"]];
            [record archiveCurrentState];
            [db executeUpdate:@"UPDATE SessionRecord SET session = ? WHERE contactIdentifier = ?", [NSKeyedArchiver archivedDataWithRootObject:record], contactIdentifier];
            
        }
        [result close];
    }];
}

#pragma mark - debug

- (void)resetSessionStore {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"DELETE FROM SessionRecord"];
        if (!success) {
            NSLog(@"清空表SessionRecord失败");
        }
    }];
}

@end
