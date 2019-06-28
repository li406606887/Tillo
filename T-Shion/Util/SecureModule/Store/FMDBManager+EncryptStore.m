//
//  FMDBManager+EncrypteStore.m
//  T-Shion
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "FMDBManager+EncryptStore.h"

@implementation FMDBManager (EncryptStore)

- (void)createEncryptTable {
    __block NSNumber *ret = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM GroupList"];
        if (result.columnCount == 8)
            ret = @(YES);
        [result close];
    }];
    if (ret)
        return;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (db.open) {
            NSString *sql = @"CREATE TABLE IF NOT EXISTS YMEncryptionUserModel (userID TEXT NOT NULL, identity BLOB, nextPrekeyId INT64, currentSignedPrekeyId INT64, isSaveIdentity INT32)";
            BOOL success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"创建YMEncryptionUserModel失败");
            }
            
            sql = @"CREATE TABLE IF NOT EXISTS SignedPreKeyRecord (Id INT64, keyPair BLOB, signature BLOB, generatedAt DATE, wasAcceptedByService INT32)";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"创建SignedPreKeyRecord失败");
            }
            
            sql = @"CREATE TABLE IF NOT EXISTS PreKeyRecord (Id INT64, keyPair BLOB)";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"创建PreKeyRecord失败");
            }
            
            sql = @"CREATE TABLE IF NOT EXISTS SessionRecord (contactIdentifier TEXT NOT NULL, deviceId INT32, session BLOB)";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"创建SessionRecord失败");
            }
            
            sql = @"CREATE TABLE IF NOT EXISTS YMRecipientIdentity (recipientId TEXT NOT NULL, recipientIdentity BLOB)";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"创建SessionRecord失败");
            }
            
            //给好友表添加两个字段密聊的roomID和是否允许使用密聊
            sql = @"ALTER TABLE Friend ADD COLUMN encryptRoomID TEXT";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"好友表添加字段encryptRoomID失败");
            }
            
            sql = @"ALTER TABLE Friend ADD COLUMN enableEndToEndCrypt INT32";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"好友表添加字段enableEndToEndCrypt失败");
            }
            
            //给会话表添加是否是密聊的字段
            sql = @"ALTER TABLE Conversation ADD COLUMN isCryptSeesion INT32 NOT NULL DEFAULT 0";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"会话表添加字段isCryptSeesion失败");
            }
            
            sql = @"ALTER TABLE UnsendMessage ADD COLUMN isCryptSeesion INT32 NOT NULL DEFAULT 0";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"未发送消息表添加字段isCryptSeesion失败");
            }
            
            //给消息表添加加密类型字段、是否删除字段
            FMResultSet *messages = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type= 'table' ORDER BY name"];
            while (messages.next) {
                NSString *name = [messages stringForColumnIndex:0];
                if ([name hasPrefix:@"Message_"]) {
                    sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN cryptoType INT32 NOT NULL DEFAULT 0", name];
                    success = [db executeUpdate:sql];
                    if (!success) {
                        NSLog(@"消息表%@添加字段cryptoType失败", name);
                    }
                    
                    sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN delFlag INT32 NOT NULL DEFAULT 0", name];
                    success = [db executeUpdate:sql];
                    if (!success) {
                        NSLog(@"消息表%@添加字段delFlag失败", name);
                    }
                    //添加是否离线用于拉取离线消息获取时间戳用
                    sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN isOffLine INT32 NOT NULL DEFAULT 0", name];
                    success = [db executeUpdate:sql];
                    if (!success) {
                        NSLog(@"消息表%@添加字段isOffLine失败", name);
                    }
                    
                    //加密消息带附件的key
                    sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN fileKey TEXT", name];
                    success = [db executeUpdate:sql];
                    if (!success) {
                        NSLog(@"消息表%@添加字段fileKey失败", name);
                    }
                }
                if ([name hasPrefix:@"message_"]) {
                    //添加是否离线用于拉取离线消息获取时间戳用
                    sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN isOffLine INT32 NOT NULL DEFAULT 0", name];
                    success = [db executeUpdate:sql];
                    if (!success) {
                        NSLog(@"消息表%@添加字段isOffLine失败", name);
                    }
                    
                    sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN fileKey TEXT", name];
                    success = [db executeUpdate:sql];
                    if (!success) {
                        NSLog(@"消息表%@添加字段fileKey失败", name);
                    }
                }
            }
            [messages close];
            
            //给群聊列表添加是否加密字段
            sql = @"ALTER TABLE GroupList ADD COLUMN isCrypt INT32 NOT NULL DEFAULT 0";
            success = [db executeUpdate:sql];
            if (!success) {
                NSLog(@"群聊列表添加字段isCrypt失败");
            }
        }
    }];
}

//存储该好友的密聊roomID
- (void)storeCryptRoomId:(NSString*)roomId userId:(NSString*)userID isSender:(BOOL)sender timeStamp:(NSTimeInterval)timeStamp {
    [FMDBManager creatCryptMessageTableWithRoomId:roomId userID:userID isSender:sender timeStamp:timeStamp];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"UPDATE Friend SET encryptRoomID=?, enableEndToEndCrypt=? WHERE friend_id=?", roomId, @(1), userID];
        if (!success) {
            NSLog(@"存储好友的密聊ID失败：%@", userID);
        }
    }];
}

+ (BOOL)isCryptMessageRoomExist:(NSString*)roomId
{
    __block BOOL isExist = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = [NSString stringWithFormat:@"message_%@", roomId];
        NSString * sql = [[NSString alloc]initWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",tableName];
        FMResultSet * rs = [db executeQuery:sql];
        while (rs.next) {
            NSString *name = [rs stringForColumn:@"name"];
            if ([name isEqualToString:tableName]) {
                isExist = YES;
            }
        }
        [rs close];
    }];
    return isExist;
}

+ (BOOL)creatCryptMessageTableWithRoomId:(NSString *)roomId userID:(NSString*)userID isSender:(BOOL)sender timeStamp:(NSTimeInterval)timeStamp {
    __block BOOL state;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = [NSString stringWithFormat:@"message_%@", roomId];
        
        NSString *messageSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (room_id TEXT NOT NULL, message_id TEXT NOT NULL, content TEXT, sender_id TEXT, backId TEXT, type TEXT NOT NULL, timestamp INTEGER, file_name TEXT, fileSize TEXT, duration TEXT, source_id TEXT, send_state TEXT, read_state TEXT, big_image TEXT ,rtc_status integer ,operType TEXT,atModelList TEXT , locationInfo TEXT, cryptoType INT32 DEFAULT 0, delFlag INT32 DEFAULT 0, isOffLine INT32 DEFAULT 0, fileKey TEXT)", tableName];
        state = [db executeUpdate:messageSql];
        if (!state) {
            NSLog(@"创建message表失败");
        }
        
        NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE message_id=999", tableName];
        FMResultSet *result = [db executeQuery:selectSql];
        while (result.next) {
            [result close];
            return;
        }
        [result close];
        
        FMResultSet *ret = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id=?", userID];
        NSString *name = nil;
        while (ret.next) {
            FriendsModel *model = [FriendsModel initModelWithResult:ret];
            if (model.showName)
                name = model.showName;
            else if (model.nickName)
                name = model.nickName;
            else
                name = model.mobile;
        }
        [ret close];
        NSString *text = nil;
        if (sender)
            text = [NSString stringWithFormat:Localized(@"crypt_invite_tip"), name];
        else
            text = [NSString stringWithFormat:Localized(@"crypt_invited_tip"), name];
        NSTimeInterval time = timeStamp-5;
        NSString *timeString = [NSString stringWithFormat:@"%ld", (long)time*1000];
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (room_id, message_id, backId, content, type, operType, send_state, read_state, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", tableName];
        BOOL success = [db executeUpdate:insertSql, @"999", @"999", roomId, text, @"system", @"system", @(1), @(1), timeString];
        if (!success) {
            NSLog(@"插入密聊系统提示1失败");
        }
        if (sender) {
            success = [db executeUpdate:@"INSERT INTO Conversation (room_id, offline_count, text, timestamp, type ,isMentioned,  isCryptSeesion) VALUES (?, ?, ?, ?, ? , ?, ?)", roomId, @(0), text, timeString, @"singleChat", @(0), @(1)];
            if (!success) {
                NSLog(@"插入密聊会话失败");
            }
        }
        
        text = [NSString stringWithFormat:@"%@\n%@\n%@", Localized(@"crypt_tip1"), Localized(@"crypt_tip3"), Localized(@"crypt_tip4")];
        time = timeStamp-4;
        timeString = [NSString stringWithFormat:@"%ld", (long)time*1000];
        success = [db executeUpdate:insertSql, @"1000", @"1000", roomId, text, @"system", @"system", @(1), @(1), timeString];
        if (!success) {
            NSLog(@"插入密聊系统提示2失败");
        }
    }];
    return state;
}

//存储该好友是否允许密聊
- (void)storeEnableCrypt:(BOOL)enabled userID:(NSString*)userID {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"UPDATE Friend SET enableEndToEndCrypt=? WHERE friend_id=?", @(enabled), userID];
        if (!success) {
            NSLog(@"存储好友的密聊ID失败：%@", userID);
        }
    }];
}

/**
 * 查询可以发起密聊的好友
 *
 */
- (NSMutableArray *)selectEncryptionFriend {
    NSMutableArray *modelArray = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Friend WHERE enableEndToEndCrypt = 1"];
        while (result.next) {
            FriendsModel *model = [FriendsModel initModelWithResult:result];
            FMResultSet *blackResult = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",model.roomId];
            BOOL state = NO;
            while (blackResult.next) {
                state = [blackResult boolForColumn:@"blacklistFlag"];
            }
            if (state == NO) {
                [modelArray addObject:model];
            }
            [blackResult close];
        }
        [result close];
    }];
    return modelArray;
}
@end
