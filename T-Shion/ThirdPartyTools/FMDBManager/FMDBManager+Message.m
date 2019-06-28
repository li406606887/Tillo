//
//  FMDBManager+Message.m
//  T+Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager+Message.h"
#import "AtManModel.h"

@implementation FMDBManager (Message)
#pragma mark 创建聊天室表
+ (BOOL)creatMessageTableWithRoomId:(NSString *)roomId {
    __block BOOL state;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *messageSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Message_%@ (room_id TEXT NOT NULL, message_id TEXT NOT NULL, content TEXT, sender_id TEXT, backId TEXT, type TEXT NOT NULL, timestamp INTEGER, file_name TEXT, fileSize TEXT, duration TEXT, source_id TEXT, send_state TEXT DEFAULT 1, read_state TEXT DEFAULT 1, big_image TEXT ,rtc_status integer ,operType TEXT,atModelList TEXT , locationInfo TEXT, cryptoType INT32 DEFAULT 0, delFlag INT32 DEFAULT 0, isOffLine INT32 DEFAULT 0, fileKey TEXT)",roomId];
        state = [db executeUpdate:messageSql];
        if (!state) {
            NSLog(@"创建message表失败");
        }
    }];
    return state;
}

/*
 * 根据messageId查询是否存在数据
 */
+ (void)selectMessageWithMessageModel:(MessageModel *)model isExist:(void (^)(BOOL, FMDatabase *))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = [NSString stringWithFormat:@"Message_%@",model.roomId];
        [FMDBManager addColumn:@"atModelList" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
        [FMDBManager addColumn:@"locationInfo" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
        [FMDBManager addColumn:@"fileSize" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
        [FMDBManager addColumn:@"measure" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
       
        [FMDBManager addColumn:@"measureInfo" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
        
        [FMDBManager addColumn:@"videoIMGName" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE message_id = ?",model.roomId];
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:sqlString,model.messageId];
        while (result.next) {
            e = YES;
            NSString *messageId = [result stringForColumnIndex:0];
            NSLog(@"messageId == %@",messageId);
            break;
        }
        [result close];
        
        exist(e, db);
    }];
}

+ (void)selectMessageWithbackId:(MessageModel *)model isExist:(void (^)(BOOL, FMDatabase *))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE backId = ?",model.roomId];
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:sqlString,model.backId];
        while (result.next) {
            e = YES;
            NSString *backId = [result stringForColumn:@"backId"];
            NSLog(@"查询backId_%@",backId);
            break;
        }
        [result close];
        exist(e, db);
    }];
}

+ (BOOL)insertMessageWithContentModel:(MessageModel *)model {
    __block BOOL result = NO;
    [self selectMessageWithMessageModel:model isExist:^(BOOL isExist, FMDatabase *db) {
        NSString *atArrayStr = [model.atModelList mj_JSONString];
        if (!atArrayStr) atArrayStr = @"";
        NSLog(@"%@",atArrayStr);
        if (!isExist) {
            NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO Message_%@ (room_id , message_id , content, sender_id, type, timestamp, file_name, duration, source_id, send_state, read_state, big_image, rtc_status, atModelList, fileSize , locationInfo, measureInfo, videoIMGName, cryptoType, backId, isOffLine, fileKey) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",model.roomId];
            result = [db executeUpdate:sqlStr,model.roomId,model.messageId,model.content,model.sender, model.type,model.timestamp,model.fileName,model.duration,model.sourceId,model.sendStatus,model.readStatus,model.bigImage,@(model.rtcStatus),atArrayStr,model.fileSize,model.locationInfo, model.measureInfo, model.videoIMGName, @(model.cryptoType), model.backId, @(model.isOffLine), model.fileKey];
            if (!result) {
                if (model.roomId.length>5 && model.messageId.length>5) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        BOOL state = [FMDBManager creatMessageTableWithRoomId:model.roomId];
                        if (state) {
                            [FMDBManager insertMessageWithContentModel:model];
                        }
                    });
                }
            }
        } else {
            NSString *sqlStr =[NSString stringWithFormat:@"UPDATE Message_%@ SET room_id = ?, message_id = ?, content = ?, sender_id = ?, type = ?, timestamp = ?, file_name = ?, duration = ?, source_id = ?, send_state = ?, read_state = ?, fileSize = ?, atModelList = ?, locationInfo = ?, measureInfo = ?, videoIMGName = ?, rtc_status = ?, cryptoType = ?, backId = ?, isOffLine = ?, fileKey = ? WHERE message_id = ?",model.roomId];
            result = [db executeUpdate:sqlStr,model.roomId,model.messageId,model.content,model.sender, model.type,model.timestamp,model.fileName,model.duration,model.sourceId,model.sendStatus,model.readStatus,model.fileSize,atArrayStr, model.locationInfo,model.measureInfo, model.videoIMGName, @(model.rtcStatus), @(model.cryptoType), model.backId, @(model.isOffLine), model.fileKey, model.messageId];
            if (!result) {
                NSLog(@"更新message失败");
            }
        }
        
    }];
    return result;
}

+ (BOOL)updateFileNameWithMessageModel:(MessageModel *)model {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr =[NSString stringWithFormat:@"UPDATE Message_%@ SET file_name = ?,content = ? WHERE message_id = ?",model.roomId];
        result = [db executeUpdate:sqlStr,model.fileName,model.content,model.messageId];
        if (!result) {
            NSLog(@"更新fileName失败");
        }
    }];
    return result;
}

+ (BOOL)updateVideoThumbIMGNameWithMessageModel:(MessageModel *)model {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr =[NSString stringWithFormat:@"UPDATE Message_%@ SET videoIMGName = ? WHERE message_id = ?",model.roomId];
        result = [db executeUpdate:sqlStr,model.videoIMGName,model.messageId];
        if (!result) {
            NSLog(@"更新fileName失败");
        }
    }];
    return result;
}

+ (BOOL)insertUnsendMessageWithContentModel:(MessageModel *)model {
    __block BOOL result = NO;
    [self selectMessageWithMessageModel:model isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            NSString *atArrayStr = [model.atModelList mj_JSONString];
            if (!atArrayStr) atArrayStr = @"";
            
            NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO Message_%@ (room_id , message_id , content, sender_id, backId, type, timestamp, file_name, duration, big_image, send_state, read_state, fileSize, atModelList, locationInfo, measureInfo, videoIMGName, fileKey, cryptoType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",model.roomId];
            result = [db executeUpdate:sqlStr,model.roomId,model.messageId,model.content,model.sender, model.backId,model.type,model.timestamp,model.fileName,model.duration,model.bigImage,@"3",@"1",model.fileSize,atArrayStr,model.locationInfo, model.measureInfo, model.videoIMGName, model.fileKey, (model.cryptoType!=0 ? @(model.cryptoType) : (model.isCryptoMessage?@"1":@"0"))];
            
            if (!result) {
                if (model.roomId.length > 5 && model.messageId.length > 5) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        BOOL state = [FMDBManager creatMessageTableWithRoomId:model.roomId];
                        if (state) {
                            [FMDBManager insertMessageWithContentModel:model];
                        }
                    });
                }
            }
            
            NSString *sqlUnsend = [NSString stringWithFormat:@"INSERT INTO UnsendMessage (room_id , message_id , content, sender_id, backId, type, timestamp, duration, send_state, read_state, atModelList, locationInfo, isCryptSeesion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
            
            result = [db executeUpdate:sqlUnsend,model.roomId,model.messageId,model.content,model.sender, model.backId,model.type,model.timestamp,model.duration,@"3",@"1",atArrayStr, model.locationInfo, @(model.isCryptoMessage)];
            if (!result) {
                NSLog(@"向未发的送表插入消息失败");
            }
        }
    }];
    return result;
}

/**
 * 更新未发送成功消息的发送状态
 */
+ (BOOL)updateUnsendMessageWithContentModel:(MessageModel *)model {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET send_state = 2 WHERE backId = ?",model.roomId];
        BOOL success = [db executeUpdate:sqlStr,model.backId];
        if (success) {
            NSLog(@"更改成功");
        }
    }];
    return result;
}
/**
 * 修改消息的查看状态由 由未查看 变成已查看 变成已读
 * @prarm messageModel
 */
+ (void)updateReadedMessageWithModel:(MessageModel *)model {
    if (model.msgType == MESSAGE_NotifyTime||model.msgType == MESSAGE_New_Msg) {
        return;
    }
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET read_state = %@ WHERE message_id = ?",model.roomId,model.readStatus];
        BOOL success = [db executeUpdate:sqlStr,model.messageId];
        if (success) {
            NSLog(@"更改成功");
        }
    }];
}
/* 更新未发送成功消息的发送状态
 * @prarm messageModel
 */
+ (BOOL)updateUnsendMessageStatusWithRoomId:(NSString *)roomId backId:(NSString *)backId sendState:(NSString *)sendState {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET send_state = ? WHERE backId = ?",roomId];
        BOOL success = [db executeUpdate:sqlStr,sendState,backId];
        if (success) {
            NSLog(@"更改成功");
        }
        NSString *sql = [NSString stringWithFormat:@"UPDATE UnsendMessage SET send_state = ? WHERE backId = ?"];
        BOOL result = [db executeUpdate:sql,sendState,backId];
        if (result) {
            NSLog(@"更改成功");
        }
    }];
    return result;
}
/* 更新发送成功的消息体
 * @prarm messageModel
 */
+ (BOOL)updateSendSuccessMessageModelWithContentModel:(MessageModel *)model {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *atArrayStr = [model.atModelList mj_JSONString];
        if (!atArrayStr) atArrayStr = @"";
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET message_id = ?, content = ?, sender_id = ?, type = ?, timestamp = ?, duration = ?, source_id = ?, send_state = 1 , atModelList = ?, locationInfo = ?, measureInfo = ?  WHERE backId = ?",model.roomId];
        result = [db executeUpdate:sqlStr,model.messageId,model.content,model.sender, model.type,model.timestamp,model.duration,model.sourceId,atArrayStr, model.locationInfo, model.measureInfo,model.backId];
        if (!result) {
            NSLog(@"更新发送的消息失败");
            
        } else {
            NSString *sqlUnsend = [NSString stringWithFormat:@"DELETE FROM UnsendMessage WHERE backId = ?"];
            result = [db executeUpdate:sqlUnsend,model.backId];
            if (!result) {
                NSLog(@"删除未发送的消息失败");
            }
        }
    }];
    return result;
}
/**
 查询图片信息的大图文件名
 
 @param model 消息模型
 @return 文件名
 */
+ (NSString *)selectBigImageWithMessageModel:(MessageModel *)model {
    __block NSString *fileName;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE message_id = ?",model.roomId];
        FMResultSet *result = [db executeQuery:sqlString,model.messageId];
        while (result.next) {
            fileName = [result stringForColumn:@"big_image"];
            break;
        }
        [result close];
    }];
    return fileName;
}
/**
 更新图片消息的文件名称

 @param roomId 房间ID
 @param messageId 消息ID
 @param assetName 资源名称
 @param fileName 文件名
 @return yes 更新成功 no 失败
 */
+ (BOOL)updateMessagBigImagePathWithRoomId:(NSString *)roomId messageId:(NSString *)messageId assetName:(NSString *)assetName fileName:(NSString*)fileName {
    __block BOOL state;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET file_name = ?, big_image = ? WHERE message_id = ?",roomId];
        state = [db executeUpdate:sqlStr,fileName,assetName,messageId];
        if (!state) {
            NSLog(@"更新大图片路径失败");
        }
    }];
    return state;
}
/**
 根据时间戳查询大于时间戳的消息

 @param tableName 表名
 @param timestamp 时间戳
 @param count 要查询的消息数量
 @return 消息数组
 */
+ (NSMutableArray *)selectMessageWithTableName:(NSString *)tableName timestamp:(NSString *)timestamp count:(int)count {
    NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString;
        FMResultSet *result;
        if (timestamp != nil) {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE timestamp < ? AND delFlag = 0 ORDER BY timestamp DESC limit %d",tableName,count];
            result = [db executeQuery:sqlString,timestamp];
        }else {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag = 0 ORDER BY timestamp DESC LIMIT %d",tableName,count];
            result = [db executeQuery:sqlString];
        }
        while (result.next) {
            NSDictionary *aaa = result.resultDictionary;
            NSLog(@"%@",aaa);

            MessageModel *model = [MessageModel initMessageWithResult:result];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}
/**
 根据时间戳查询大于时间戳的所有历史消息

 @param roomId 房间ID
 @param timestamp 时间戳
 @return 消息数
*/
+ (int)selectedHistoryMsgWithRoomId:(NSString *)roomId timestamp:(NSString *)timestamp {
    __block int count = 0;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag = 0 AND timestamp >= ? ORDER BY timestamp DESC ",roomId];
        FMResultSet *result = [db executeQuery:sqlString,timestamp];
                
        while (result.next) {
            count ++;
//            MessageModel *model = [MessageModel initMessageWithResult:result];
//            [array addObject:model];
        }
        [result close];
    }];
    return count;
}

+ (NSDictionary *)selectImageOrVideoWithRoom:(NSString *)roomId messageId:(NSString *)messageId {
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    __block int index ;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag = 0 AND (type = 'image' OR type = 'video') ORDER BY timestamp ASC ",roomId];
        NSMutableArray *array = [NSMutableArray array];
        FMResultSet *result = [db executeQuery:sql];
        int count = 0;
        while (result.next) {
            MessageModel *model = [MessageModel initMessageWithResult:result];
            [array addObject:model];
            if ([model.messageId isEqualToString:messageId]||[model.backId isEqualToString:messageId]) {
                index = count;
            }
            count++;
        }
        [result close];
        [dictionary setObject:array forKey:@(index)];
    }];
    return dictionary;
}

+ (NSDictionary *)selectImageWithRoom:(NSString *)roomId messageId:(NSString *)messageId {
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    __block int index ;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag = 0 AND (type = 'image') ORDER BY timestamp ASC ",roomId];
        NSMutableArray *array = [NSMutableArray array];
        FMResultSet *result = [db executeQuery:sql];
        int count = 0;
        while (result.next) {
            MessageModel *model = [MessageModel initMessageWithResult:result];
            [array addObject:model];
            if ([model.messageId isEqualToString:messageId]||[model.backId isEqualToString:messageId]) {
                index = count;
            }
            count++;
        }
        [result close];
        [dictionary setObject:array forKey:@(index)];
    }];
    return dictionary;
}


+ (NSArray *)selectFileWithRoom:(NSString *)roomId keyWord:(NSString *)keyWord {
    __block NSMutableArray *dataArray = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql;
        FMResultSet *result;
        if (keyWord.length>0) {
            sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag = 10 AND type = 'file' AND file_name LIKE '%%%@%%' ORDER BY timestamp DESC ",roomId,keyWord];
            result = [db executeQuery:sql,keyWord];
        }else {
            sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag = 0 AND type = 'file' ORDER BY timestamp DESC ",roomId];
            result = [db executeQuery:sql];
        }
        while (result.next) {
            MessageModel *model = [MessageModel initMessageWithResult:result];
            [dataArray addObject:model];
        }
    }];
    return dataArray;
}

+ (BOOL)deleteAllMessageWithRoomId:(NSString *)roomid {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"UPDATE Message_%@ SET delFlag = 1",roomid];
        result = [db executeUpdate:sqlString];
    }];
    if (roomid.length>10) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *finderPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:roomid];
        if ([fileManager fileExistsAtPath:finderPath]) {
            if ([fileManager removeItemAtPath:finderPath error:NULL]) {
                NSLog(@"Removed successfully");
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteAllMessage" object:nil];
    return result;
}

+ (BOOL)deleteCryptMessageWithRoomId:(NSString *)roomid isDeleteConversation:(BOOL)del {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"UPDATE Message_%@ SET delFlag = 1",roomid];
        result = [db executeUpdate:sqlString];
        if (del) {
            NSString *delSql = [NSString stringWithFormat:@"DELETE FROM Message_%@ WHERE message_id=999 OR message_id=1000", roomid];
            BOOL delSuccess = [db executeUpdate:delSql];
            if (!delSuccess) {
                NSLog(@"删除加密聊天系统提示1、2失败");
            }
        }
        else {
            NSString *delSql = [NSString stringWithFormat:@"UPDATE Message_%@ SET timestamp = 0, delFlag = 0 WHERE message_id=999 OR message_id=1000", roomid];
            BOOL delSuccess = [db executeUpdate:delSql];
            if (!delSuccess) {
                NSLog(@"删除加密聊天系统提示1、2失败");
            }
        }
    }];
    if (roomid.length>10) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *finderPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:roomid];
        if ([fileManager fileExistsAtPath:finderPath]) {
            if ([fileManager removeItemAtPath:finderPath error:NULL]) {
                NSLog(@"Removed successfully");
            }
        }
    }
   
    return result;
}

+ (BOOL)deleteMessageWithMessage:(MessageModel *)model {
    __block BOOL result = NO;
    if (model.msgType == MESSAGE_AUDIO) {
        NSString *filePath = [[[[TShionSingleCase doucumentPath] stringByAppendingPathComponent:model.roomId] stringByAppendingString:@"Images"] stringByAppendingString:model.fileName];
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL]) {
            NSLog(@"Removed successfully");
        }
    }else if (model.msgType == MESSAGE_IMAGE) {
        NSString *filePath = [[[[TShionSingleCase doucumentPath] stringByAppendingPathComponent:model.roomId] stringByAppendingString:@"Images"] stringByAppendingString:model.fileName];
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL]) {
            NSLog(@"Removed successfully");
        }
    }
    
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"UPDATE Message_%@ SET delFlag = 1 WHERE message_id = ?",model.roomId];
        result = [db executeUpdate:sqlString,model.messageId];
    }];
    
    return result;
}

//是否已经存在该消息(chw添加backId也去重，安卓出现backId一样messageId不一样的情况)
+ (BOOL)isAlreadyHadMsg:(MessageModel *)msgModel {
    __block BOOL isAlreadyHadMsg;
    
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = nil;
        NSString *sqlString = nil;
        if (msgModel.backId.length > 5) {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE message_id = ? OR backId = ?",msgModel.roomId];
            result = [db executeQuery:sqlString,msgModel.messageId, msgModel.backId];
        }
        else {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE message_id = ?",msgModel.roomId];
            result = [db executeQuery:sqlString, msgModel.messageId];
        }
        if (result.next) {
            isAlreadyHadMsg = YES;
        } else {
            isAlreadyHadMsg = NO;
        }
        [result close];
    }];
    
    return isAlreadyHadMsg;
}

+ (BOOL)withdrawMessageWithMsgId:(NSString *)msgId roomId:(NSString *)roomId {
    __block BOOL state;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET type = 'withdraw' WHERE message_id = ?",roomId];
        state = [db executeUpdate:sqlStr,msgId];
    }];
    return state;
}

/* 获取所有消息表的表名
 * @prarm nil
 */
+ (NSArray *)selectedAllMsgTableName {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type= 'table' ORDER BY name"];
        while (result.next) {
            NSString *name = [result stringForColumnIndex:0];
            if ([name containsString:@"Message_"]||[name containsString:@"message_"]) {
                [array addObject:name];
                NSLog(@"%@",name);
            }
        }
        [result close];
    }];
    return array;
}
/* 获取消息表所有符合字段的消息消息
 * @prarm keyWord 关键字 roomId 房间号
 */
+ (NSArray *)selectedAllHistoryMessageWithKeyWord:(NSString *)keyWord {
    __block NSMutableArray *array = [NSMutableArray array];
    __block NSArray *roomArray = [FMDBManager selectedAllMsgTableName];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        for (NSString *tableName in roomArray) {
            if ([tableName containsString:@"message_"]) {
                NSMutableArray *cryptoMessageArray = [NSMutableArray array];
                NSString *cryptoSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE content LIKE '%%%@%%' AND type = 'text' AND delFlag < 1 ORDER BY timestamp ASC",tableName,keyWord];//
                FMResultSet *cryptoResult = [db executeQuery:cryptoSql];
                while (cryptoResult.next) {
                    MessageModel *model = [MessageModel initMessageWithResult:cryptoResult];
                    model.cryptoType = 1;
                    [cryptoMessageArray addObject:model];
                }
                [cryptoResult close];
                if (cryptoMessageArray.count>0) {
                    [array addObject:cryptoMessageArray];
                }
            }else if([tableName containsString:@"Message_"]){
                NSMutableArray *messageArray = [NSMutableArray array];
                NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE content LIKE '%%%@%%' AND type = 'text' AND cryptoType < 1 AND delFlag < 1 ORDER BY timestamp ASC",tableName,keyWord];//
                FMResultSet *result = [db executeQuery:sql];
                while (result.next) {
                    MessageModel *model = [MessageModel initMessageWithResult:result];
                    [messageArray addObject:model];
                }
                [result close];
                if (messageArray.count>0) {
                    [array addObject:messageArray];
                }
            }
        }
    }];
    return array;
}
/* 获取消息表所有符合字段的消息消息
 * @prarm keyWord 关键字 roomId 房间号
 */
+ (NSArray *)selectedMessageWithKeyWord:(NSString *)keyWord roomId:(NSString *)roomId {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE content like '%%%@%%' AND type = 'text' ORDER BY timestamp ASC",roomId,keyWord];//AND type like 'text'
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            MessageModel *model = [MessageModel initMessageWithResult:result];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}

//获取消息表中最后一条离线消息的时间戳
+ (NSString*)lastedOfflineMessageTimeWithRoomId:(NSString*)roomId {
    __block NSString *time = @"0";
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT max(timestamp) AS timestamp FROM Message_%@ WHERE isOffLine = 1", roomId];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            if ([result stringForColumn:@"timestamp"])
                time = [result stringForColumn:@"timestamp"];
            break;
        }
        [result close];
    }];
    return time;
}

+ (void)ChangeAllMessageReadStatusWithRoomId:(NSString*)roomId {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET read_state = '2' WHERE read_state = '3'",roomId];
        [db executeUpdate:sqlStr];
    }];
}

+ (MessageModel*)selectFirstUnReadMessageWithRoomId:(NSString*)roomId {
    __block MessageModel *msg;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE read_state = '3' AND delFlag = 0 ORDER BY timestamp ASC limit 1", roomId];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            msg = [MessageModel initMessageWithResult:result];
        }
        [result close];
    }];
    return msg;
}

+ (MessageModel*)selectMessageWithRoomId:(NSString*)roomId msgId:(NSString *)msgId {
    __block MessageModel *msg;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE message_id = ?", roomId];
        FMResultSet *result = [db executeQuery:sql,msgId];
        while (result.next) {
            msg = [MessageModel initMessageWithResult:result];
        }
        [result close];
    }];
    return msg;
}
@end
