//
//  FMDBManager+Conversation.m
//  T+Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager+Conversation.h"
#import "AtManModel.h"

@implementation FMDBManager (Conversation)
#pragma mark 会话列表数据库操作
/* 根据friendID查询是否存在数据
 * @param friendID
 * @param exist 是否存在,且返回db以便下步操作
 */
+ (void)selectConversationWithRoomId:(NSString *)roomId isExist:(void (^)(BOOL, FMDatabase *))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Conversation WHERE room_id = ?", roomId];
        while (result.next) {
            e = YES;
            break;
        }
        [result close];
        exist(e, db);
    }];
}

/**
 * 去重插入最新会话列表数据
 * @param type singleChat 单聊 groupChat 群聊
 */
+ (void )insertSessionOfflineWithType:(NSString *)type message:(MessageModel *)message withCount:(int)count {
    [self selectConversationWithRoomId:message.roomId isExist:^(BOOL isExist, FMDatabase *db) {
        NSString *text;
        if (message.msgType == MESSAGE_AUDIO) {
            text = Localized(@"Chat_Msg_Voice");
        } else if (message.msgType == MESSAGE_IMAGE) {
            text = Localized(@"Chat_Msg_IMG");
        } else if (message.msgType == MESSAGE_TEXT) {
            text = message.content;
        } else if (message.msgType == MESSAGE_RTC) {
            text = message.content;
        } else if (message.msgType == MESSAGE_System) {
            text = message.content;
        } else if (message.msgType == MESSAGE_File) {
            text = Localized(@"Chat_Msg_File");
        } else if (message.msgType == MESSAGE_Location) {
            text = Localized(@"Chat_Msg_Localtion");
        } else if (message.msgType == MESSAGE_Video) {
            text = Localized(@"Chat_Msg_Video");
        } else if (message.msgType == MESSAGE_Contacts_Card) {
            text = Localized(@"Chat_Msg_Card");
        } else {
            text = message.content;
        }
        
        if (message.msgType > MESSAGE_Contacts_Card || message.msgType < MESSAGE_NotifyTime) {
            text = Localized(@"Chat_Msg_Unknow");
        }
        
        //是否被提醒
        __block  BOOL isMentioned = NO;
        FMResultSet *resultMentioned = [db executeQuery:@"SELECT * FROM Conversation WHERE room_id = ?",message.roomId];
        if (resultMentioned.next) {
            isMentioned = [resultMentioned boolForColumn:@"isMentioned"];
        }
        [resultMentioned close];
        
        if (message.sendType == OtherSender) {
            [[AtManModel mj_objectArrayWithKeyValuesArray:message.atModelList] enumerateObjectsUsingBlock:^(AtManModel *atManData, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([atManData.userId isEqualToString:[SocketViewModel shared].userModel.ID] || [atManData.userId isEqualToString:@"-1"]) {
                    isMentioned = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (!isExist) {
            //set isCryptSeesion, modify by chw 2019.04.18 for Encryption
            //由于一些消息没带是否加密，导致会话列表可能会出错，是否加密自己查询
            BOOL isCryptSeesion = NO;
            if (message.isCryptoMessage)
                isCryptSeesion = YES;
            else {
                FMResultSet *resultEncryption = [db executeQuery:@"SELECT * FROM Friend WHERE encryptRoomID=?", message.roomId];
                if (resultEncryption.next) {
                    isCryptSeesion = YES;
                }
                [resultEncryption close];
            }
            BOOL result = [db executeUpdate:@"INSERT INTO Conversation (room_id, offline_count, text, timestamp, type ,isMentioned, isCryptSeesion) VALUES (?, ?, ?, ?, ?, ?, ?)",message.roomId,@(count),text,message.timestamp,type,@(isMentioned), @(isCryptSeesion)];
            if (result) {
                NSLog(@"插入成功");
            }
        } else {  // 如果已经存在,更新最后一条消息
            BOOL result = [db executeUpdate:@"UPDATE Conversation SET offline_count = offline_count + ?, text = ?, timestamp = ? , isMentioned = ? WHERE room_id = ? AND timestamp <= ?",@(count),text,message.timestamp,@(isMentioned), message.roomId,message.timestamp];
            if (result) {
                NSLog(@"更新成功");
            }
        }
    }];
}

+ (void)insertSessionOnlineWithType:(NSString *)type message:(MessageModel *)message withCount:(int)count {
    [self selectConversationWithRoomId:message.roomId isExist:^(BOOL isExist, FMDatabase *db) {
        NSString *text;
        if (message.msgType == MESSAGE_AUDIO) {
            text = Localized(@"Chat_Msg_Voice");
        }else if (message.msgType == MESSAGE_IMAGE) {
            text = Localized(@"Chat_Msg_IMG");
        }else if (message.msgType == MESSAGE_TEXT) {
            text = message.content;
        } else if (message.msgType == MESSAGE_RTC) {
            text = message.content;
        } else if (message.msgType == MESSAGE_System) {
            text = message.content;
        } else if (message.msgType == MESSAGE_File) {
            text = Localized(@"Chat_Msg_File");
        } else if (message.msgType == MESSAGE_Location) {
            text = Localized(@"Chat_Msg_Localtion");
        } else if (message.msgType == MESSAGE_Video) {
            text = Localized(@"Chat_Msg_Video");
        }else if (message.msgType == MESSAGE_Contacts_Card) {
            text = Localized(@"Chat_Msg_Card");
        }else {
            text = message.content;
        }
        
        if (message.msgType > MESSAGE_Contacts_Card || message.msgType < MESSAGE_NotifyTime) {
            text = Localized(@"Chat_Msg_Unknow");
        }
        
        //是否被提醒
        __block  BOOL isMentioned = NO;
        FMResultSet *resultMentioned = [db executeQuery:@"SELECT * FROM Conversation WHERE room_id = ?",message.roomId];
        if (resultMentioned.next) {
            isMentioned = [resultMentioned boolForColumn:@"isMentioned"];
        }
        [resultMentioned close];
        
        if (message.sendType == OtherSender && !isMentioned) {
            [[AtManModel mj_objectArrayWithKeyValuesArray:message.atModelList] enumerateObjectsUsingBlock:^(AtManModel *atManData, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([atManData.userId isEqualToString:[SocketViewModel shared].userModel.ID] || [atManData.userId isEqualToString:@"-1"]) {
                    isMentioned = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (!isExist) {
            //set isCryptSeesion, modify by chw 2019.04.18 for Encryption
            //由于一些消息没带是否加密，导致会话列表可能会出错，是否加密自己查询
            BOOL isCryptSeesion = NO;
            if (message.isCryptoMessage)
                isCryptSeesion = YES;
            else {
                FMResultSet *resultEncryption = [db executeQuery:@"SELECT * FROM Friend WHERE encryptRoomID=?", message.roomId];
                if (resultEncryption.next) {
                    isCryptSeesion = YES;
                }
                [resultEncryption close];
            }
            BOOL result = [db executeUpdate:@"INSERT INTO Conversation (room_id, unreadcount, text, timestamp,type ,isMentioned, isCryptSeesion) VALUES (?, ?, ?, ?, ?,? ,?)",message.roomId,@(count),text,message.timestamp,type ,@(isMentioned), @(isCryptSeesion)];
            if (result) {
                NSLog(@"插入成功");
            }
        } else {  // 如果已经存在,更新最后一条消息
            BOOL result = [db executeUpdate:@"UPDATE Conversation SET unreadcount = unreadcount + ? , text = ?, timestamp = ? , isMentioned = ? WHERE room_id = ? AND timestamp <= ?",@(count),text,message.timestamp,@(isMentioned), message.roomId, message.timestamp];
            if (result) {
                NSLog(@"更新会话表显示的消息成功");
            }
        }
    }];
}
/**
 删除房间内最后一条消息 更新会话显示的内容
 @param type singleChat groupChat
 @param message 消息
 */
+ (void)updateOnlineWithType:(NSString *)type message:(MessageModel *)message {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *text;
        if (message.msgType == MESSAGE_AUDIO) {
            text = Localized(@"Chat_Msg_Voice");
        }else if (message.msgType == MESSAGE_IMAGE) {
            text = Localized(@"Chat_Msg_IMG");
        }else if (message.msgType == MESSAGE_TEXT) {
            text = message.content;
        } else if (message.msgType == MESSAGE_RTC) {
            text = message.content;
        } else if (message.msgType == MESSAGE_System) {
            text = message.content;
        } else if (message.msgType == MESSAGE_File) {
            text = Localized(@"Chat_Msg_File");
        } else if (message.msgType == MESSAGE_Location) {
            text = Localized(@"Chat_Msg_Localtion");
        } else if (message.msgType == MESSAGE_Video) {
            text = Localized(@"Chat_Msg_Video");
        }else if (message.msgType == MESSAGE_Contacts_Card) {
            text = Localized(@"Chat_Msg_Card");
        }else {
            text = message.content;
        }
        BOOL result = [db executeUpdate:@"UPDATE Conversation SET text = ?, timestamp = ? WHERE room_id = ? ",text,message.timestamp, message.roomId];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}
/*
 * 将离线消息数转换成在线消息数
 */
+ (BOOL )offlineCountConvertedToOnlineCountWithRoomId:(NSString *)roomId {
    __block BOOL state = YES;
    [self selectConversationWithRoomId:roomId isExist:^(BOOL isExist, FMDatabase *db) {
        if (isExist) {
            BOOL result = [db executeUpdate:@"UPDATE Conversation SET unreadcount = offline_count  WHERE room_id = ?",roomId];
            if (result) {
                NSLog(@"更新成功");
            }else {
                state = NO;
            }
            BOOL clearResult = [db executeUpdate:@"UPDATE Conversation SET offline_count = 0 WHERE room_id = ?",roomId];
            if (clearResult) {
                NSLog(@"清除成功");
            }else {
                state = NO;
            }
        }
    }];
    return state;
}

/*
 * 将在线消息数转换成离线消息数
 */
+ (BOOL )OnlineCountConvertedToOfflineCountWithRoomId:(NSString *)roomId {
    __block BOOL state = YES;
    [self selectConversationWithRoomId:roomId isExist:^(BOOL isExist, FMDatabase *db) {
        if (isExist) {
            BOOL result = [db executeUpdate:@"UPDATE Conversation SET offline_count = unreadcount  WHERE room_id = ?",roomId];
            if (result) {
                NSLog(@"更新成功");
            }else {
                state = NO;
            }
            BOOL clearResult = [db executeUpdate:@"UPDATE Conversation SET unreadcount = 0 WHERE room_id = ?",roomId];
            if (clearResult) {
                NSLog(@"清除成功");
            }else {
                state = NO;
            }
        }
    }];
    return state;
}


/* 清除会话表的角标
 * @prarm roomId房间ID
 */
+ (void)clearMessageUnreadCountWithRoomId:(NSString *)roomId {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"UPDATE Conversation SET unreadcount = 0 , offline_count = 0 , isMentioned = ? WHERE room_id = ?",@(NO),roomId];
        if (result) {
            NSLog(@"对话框消息数清除成功");
        }
    }];
}

+ (void)clearMessageOfflineCountWithRoomId:(NSString *)roomId {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"UPDATE Conversation SET offline_count = 0 WHERE room_id = ?",roomId];
        if (result) {
            NSLog(@"对话框消息数清除成功");
        }
    }];
}

/**
 * 查询本地好友列表数据
 *
 */
+ (NSMutableArray *)selectConversationTable {
    NSMutableArray *modelArray = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *topArray = [NSMutableArray array];
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Conversation ORDER BY timestamp DESC"];
        while (result.next) {
            SessionModel *model = [[SessionModel alloc] init];
            model.roomId = [result stringForColumn:@"room_id"];
            model.unReadCount = [result intForColumn:@"unreadcount"];
            model.offlineCount = [result intForColumn:@"offline_count"];
            model.type = [result stringForColumn:@"type"];
            model.timestamp = [result stringForColumn:@"timestamp"];
            model.text = [result stringForColumn:@"text"];
            model.isMentioned = [result boolForColumn:@"isMentioned"];
            model.draftContent = [result stringForColumn:@"draftContent"];
            model.isCrypt = [result boolForColumn:@"isCryptSeesion"];
            
            FMResultSet *resultTop = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",model.roomId];
            if (resultTop.next) {
                BOOL state = [resultTop boolForColumn:@"top"];
                model.top = state;
            }
            [resultTop close];
            
            FMResultSet *resultDisturb = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",model.roomId];
            if (resultDisturb.next) {
                BOOL state = [resultDisturb boolForColumn:@"disturb"];
                model.disturb = state;
            }
            [resultDisturb close];
            
            if ([model.type isEqualToString:@"singleChat"]) {
                FMResultSet *friendResult = nil;
                if (model.isCrypt)
                    friendResult = [db executeQuery:@"SELECT * FROM Friend WHERE encryptRoomID = ?",model.roomId];
                else
                    friendResult = [db executeQuery:@"SELECT * FROM Friend WHERE room_id = ?",model.roomId];
                while (friendResult.next) {
                    model.model = [FriendsModel initModelWithResult:friendResult];
                    if (model.top) {
                        [topArray addObject:model];
                    } else {
                        [modelArray addObject:model];
                    }
                }
                [friendResult close];
            }else {
                FMResultSet * groupResult = [db executeQuery:@"SELECT * FROM GroupList WHERE room_id = ?",model.roomId];
                while (groupResult.next) {
                    model.group = [GroupModel initModelWithResult:groupResult];
                    if (model.top) {
                        [topArray addObject:model];
                    }else {
                        [modelArray addObject:model];
                    }
                }
                [groupResult close];
            }
        }
        [result close];
        if (topArray.count>0) {
            for (NSInteger i = topArray.count-1; i>=0 ; i--) {
                SessionModel *model = topArray[i];
                [modelArray insertObject:model atIndex:0];
            }
        }
    }];
    return modelArray;
}

+ (int)selectUnreadCountWithRoomId:(NSString *)roomId {
    __block int count = 0;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Conversation WHERE room_id = ?",roomId];
        while (result.next) {
            count = [result intForColumn:@"unreadcount"] + [result intForColumn:@"offline_count"];
        }
    }];
    return count;
}

+ (int)getMessageUnreadCount {
    __block int count = 0;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * onlineResult = [db executeQuery:@"SELECT SUM (unreadcount) FROM Conversation"];
        if (onlineResult.next) {
            count = [onlineResult intForColumnIndex:0];
        }
        [onlineResult close];
    }];
    return count;
}

+ (NSInteger)getSessionUnreadCount {
    __block int count = 0;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * onlineResult = [db executeQuery:@"SELECT * FROM Conversation WHERE unreadcount > 0"];
        while (onlineResult.next) {
            count++;
        }
        [onlineResult close];
    }];
    return count;
}

+ (BOOL)deleteConversationWithRoomId:(NSString *)roomId {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM Conversation WHERE room_id = ?"];
        result = [db executeUpdate:sqlString,roomId];
    }];
    return result;
}

+ (BOOL)cleanConversationTextWithRoomId:(NSString *)roomId {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"UPDATE Conversation SET text = ? WHERE room_id = ?"];
        result = [db executeUpdate:sqlString,@"",roomId];
    }];
    return result;
}

#pragma mark - 草稿相关
+ (void)updateDraftContentWithRoomId:(NSString *)roomId draftContentText:(NSString *)draftContentText isSingleChat:(BOOL)isSingleChat {
    [self selectConversationWithRoomId:roomId isExist:^(BOOL isExist, FMDatabase *db) {
        NSString *chatType = isSingleChat ? @"singleChat" : @"groupChat";
        NSString *timestamp = [NSDate getNowTimestamp];
        if (isExist) {
            //如果存在则更新
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE Conversation SET draftContent = '%@', type = '%@' WHERE room_id = '%@'",draftContentText, chatType, roomId];
            BOOL result = [db executeUpdate:updateSql];
            
            if (result) {
                NSLog(@"更新草稿成功");
            }
            
        } else {
            //如果不存在则插入
            BOOL isCryptSeesion = NO;
            if (isSingleChat) {
                FMResultSet *resultEncryption = [db executeQuery:@"SELECT * FROM Friend WHERE encryptRoomID=?", roomId];
                if (resultEncryption.next) {
                    isCryptSeesion = YES;
                }
                [resultEncryption close];
            }
            else {
                FMResultSet *result = [db executeQuery:@"SELECT * FROM GroupList WHERE room_id=? AND isCrypt = 1", roomId];
                if (result.next) {
                    isCryptSeesion = YES;
                }
                [result close];
            }
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO Conversation (room_id, draftContent, timestamp, type, isCryptSeesion) VALUES ('%@', '%@', '%@', '%@', %d)",roomId, draftContentText, timestamp, chatType, (int)isCryptSeesion];
            BOOL result = [db executeUpdate:insertSql];
            
            if (result) {
                NSLog(@"插入草稿成功");
            }
        }
    }];
}

+ (void)updateDraftAtListWithRoomId:(NSString *)roomId draftAtList:(NSString *)draftAtList {
    [self selectConversationWithRoomId:roomId isExist:^(BOOL isExist, FMDatabase *db) {
        NSString *chatType = @"groupChat";
        NSString *timestamp = [NSDate getNowTimestamp];
        if (isExist) {
            //如果存在则更新
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE Conversation SET draftAtList = '%@', type = '%@' WHERE room_id = '%@'",draftAtList, chatType, roomId];
            BOOL result = [db executeUpdate:updateSql];
            
            if (result) {
                NSLog(@"更新草稿成功");
            }
            
        } else {
            //如果不存在则插入
            BOOL isCryptSeesion = NO;
            FMResultSet *resultEncryption = [db executeQuery:@"SELECT * FROM GroupList WHERE room_id=?", roomId];
            if (resultEncryption.next) {
                isCryptSeesion = YES;
            }
            [resultEncryption close];
            
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO Conversation (room_id, draftAtList, timestamp, type, isCryptSeesion) VALUES ('%@', '%@', '%@', '%@', %d)",roomId, draftAtList, timestamp, chatType, (int)isCryptSeesion];
            BOOL result = [db executeUpdate:insertSql];
            
            if (result) {
                NSLog(@"插入草稿成功");
            }
        }
    }];
}

+ (NSDictionary *)selectConversationDraftDataWithRoomId:(NSString *)roomId {
    
    __block NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *draft;
        NSString *draftAtList;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Conversation WHERE room_id = ?", roomId];
        while (result.next) {
            draft = [result stringForColumn:@"draftContent"];
            draftAtList = [result stringForColumn:@"draftAtList"];
            if (draft) {
                [dataDict setObject:draft forKey:@"draftContent"];
            }
            
            if (draftAtList) {
                [dataDict setObject:draftAtList forKey:@"draftAtList"];
            }
            
            break;
        }
        [result close];
    }];
    return dataDict;
}

@end
