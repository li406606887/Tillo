//
//  FMDBManager+Friend.m
//  T-Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager+Friend.h"

@implementation FMDBManager (Friend)

#pragma mark 好友列表数据库操作
/* 根据friendID查询是否存在数据
 * @param friendID
 * @param exist 是否存在,且返回db以便下步操作
 */
+ (void)selectFriendWithFriendId:(NSString *)friendId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id = ?", friendId];
        while (result.next) {
            e = YES;
            NSString *friendId = [result stringForColumnIndex:0];
            NSLog(@"%@",friendId);
            break;
        }
        [result close];
        exist(e, db);
    }];
}
/* 根据uid查询是否存在数据
 * @param uid 用户ID rqid 请求id  exist 是否存在,且返回db以便下步操作
 */
+ (void)selectFriendRequestWithUid:(NSString *)uid rqid:(NSString *)rqid isExist:(void(^)(BOOL isExist, FMDatabase *db))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM FirendRequest WHERE uid = ? AND requestId = ?",uid,rqid];
        while (result.next) {
            e = YES;
            break;
        }
        [result close];
        exist(e, db);
    }];
}
/**
 * 去重插入最新好友列表数据
 * @param array 好友的模型数组
 */
+ (void)refreshFriendTableWithArray:(NSArray *)array {
    if (array.count<1) {
        return;
    }
    for (FriendsModel *model in array) {
        NSString *friend_id = model.userId;
        NSString *room_id = model.roomId;
        NSString *name = model.name;
        NSString *avatar = model.avatar;
        NSString *mobile = model.mobile;
        NSString *show_name = model.showName;
        NSString *nick_name = model.nickName;
        [self selectFriendWithFriendId:friend_id isExist:^(BOOL isExist, FMDatabase *db) {
            // 判断不存在再插入数据库
            if (!isExist) {
                BOOL result = [db executeUpdate:@"INSERT INTO Friend (friend_id, room_id, name, avatar, mobile, show_name, nick_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",friend_id,room_id,name,avatar,mobile,show_name,nick_name];
                if (result) {
                    NSLog(@"插入成功");
                }
            } else {  // 如果已经存在,更新最后一条消息
                BOOL result = [db executeUpdate:@"UPDATE Friend SET room_id = ?,avatar = ?,mobile = ?,show_name = ?,nick_name = ?  WHERE friend_id = ?",room_id,name,avatar,mobile,show_name,nick_name,friend_id];
                if (result) {
                    NSLog(@"更新成功");
                }
            }
        }];
    }
}

/**
 * 查询本地好友列表数据
 *
 */
+ (NSMutableArray *)selectFriendTable {
    NSMutableArray *modelArray = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Friend"];
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


/* 根据roomID查询friend表
 * @return friendModel
 */
+ (FriendsModel *)selectFriendTableWithRoomId:(NSString *)roomId  {
    __block FriendsModel *model ;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Friend WHERE room_id = ? or encryptRoomID = ?",roomId, roomId];
        while (result.next) {
            model = [FriendsModel initModelWithResult:result];
        }
        [result close];
    }];
    return model;
}
/* 根据uid查询friend表
 * @return friendModel
 */
+ (FriendsModel *)selectFriendTableWithUid:(NSString *)uid {
    __block FriendsModel *model;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id = ?",uid];
        while (result.next) {
           model = [FriendsModel initModelWithResult:result];
        }
        [result close];
    }];
    return model;
}

/* 更新friend表
 * param friendModel
 */
+ (BOOL)updateFriendTableWithFriendsModel:(FriendsModel *)model {
    __block BOOL result = NO;
    __block BOOL way = NO;
    NSString *friend_id = model.userId;
    NSString *room_id = model.roomId;
    NSString *name = model.name;
    NSString *avatar = model.avatar;
    NSString *mobile = model.mobile;
    NSString *show_name = model.showName;
    NSString *nick_name = model.nickName;
    NSString *sex = model.sex;
    NSString *dailCode = model.dialCode;
    NSNumber *enableEndToEndCrypt = [NSNumber numberWithBool:model.enableEndToEndCrypt];
    if (show_name.length<1) {
        if (nick_name.length<1) {
            show_name = name;
        }else {
            show_name = nick_name;
        }
    }
//    NSString *block = model.block;
//    NSString *distub = model.distub;
    // 判断不存在再插入数据库
    [self selectFriendWithFriendId:friend_id isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            result = [db executeUpdate:@"INSERT INTO Friend (friend_id, room_id, name, avatar, mobile, sex, show_name, nick_name, dialCode, enableEndToEndCrypt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",friend_id,room_id,name,avatar,mobile,sex,show_name,nick_name,dailCode, enableEndToEndCrypt];
            if (result) {
                NSLog(@"插入成功");
                way = YES;
            }
        } else {  // 如果已经存在,更新最后一条消息
            result = [db executeUpdate:@"UPDATE Friend SET name = ?, avatar = ?, mobile = ?, sex = ?, show_name = ?,nick_name = ? ,dialCode = ?, enableEndToEndCrypt = ? WHERE friend_id = ?",name,avatar,mobile,sex,show_name,nick_name,dailCode,enableEndToEndCrypt, friend_id];
            if (result) {
                NSLog(@"更新成功");
            }
        }
    }];
    if (way) {
        BOOL state = [FMDBManager offlineCountConvertedToOnlineCountWithRoomId:room_id];
        if (state) {
            NSLog(@"消息数转换成功");
        }
    }
    return result;
}
/* 根据keyword 查询好友
 * @param keyword 关键字
 */
+ (NSArray *)selectedFriendWithKeyword:(NSString *)keyword {
    if (keyword.length<1) {
        return nil;
    }
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Friend WHERE name LIKE '%%%@%%' OR show_name LIKE '%%%@%%' OR nick_name LIKE '%%%@%%'",keyword,keyword,keyword];
        FMResultSet *result = [db executeQuery:sql];//,keyword,keyword
        while (result.next) {
            FriendsModel *model = [FriendsModel initModelWithResult:result];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}

+ (BOOL)friendSesstionTopWithFriendsModel:(FriendsModel *)model {
    __block BOOL result = NO;
     [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
//         result = [db executeUpdate:@"UPDATE Friend SET top = ? WHERE friend_id = ?", model.top, model.ID];
     }];
    return result;
}

+ (BOOL)deleteFriendWithFriendsModel:(FriendsModel *)model {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"DELETE FROM Friend WHERE friend_id = ?", model.userId];
    }];
    return result;
}

#pragma mark - 黑名单
/* 根据friendID 查询黑名单人员
 * @param friendID
 */
+ (NSMutableArray *)selectBlackFriend {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM RoomSetting WHERE blacklistFlag = ?",@(YES)];
        while (result.next) {
            NSString *roomId = [result stringForColumn:@"room_id"];
            FMResultSet * fResult = [db executeQuery:@"SELECT * FROM Friend WHERE room_id = ?",roomId];
            while (fResult.next) {
                FriendsModel *model = [FriendsModel initModelWithResult:fResult];
                [array addObject:model];
            }
            [fResult close];
        }
        [result close];
    }];
    return array;
}

+ (void)updataFriendRequestData:(NSDictionary*)data {
    NSString *uid = [NSString stringWithFormat:@"%@",data[@"id"]];
    NSString *rqid = [NSString stringWithFormat:@"%@",data[@"requestId"]];
    NSString *json = [NSString dictionaryToJson:data];
    [self selectFriendRequestWithUid:uid rqid:rqid isExist:^(BOOL isExist, FMDatabase *db) {
        // 判断不存在再插入数据库
        if (!isExist) {
            BOOL result = [db executeUpdate:@"INSERT INTO FirendRequest (uid,requestId,data) VALUES (?, ?, ?)",uid,rqid,json];
            if (result) {
                NSLog(@"插入成功");
            }
        } else { // 如果已经存在,更新最后一条消息
            BOOL result = [db executeUpdate:@"UPDATE FirendRequest SET data = ? WHERE uid = ? AND requestId = ?",json,uid,rqid];
            if (result) {
                NSLog(@"更新成功");
            }
        }
    }];
}

+ (NSMutableArray *)selectFriendRequest {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM FirendRequest"];
        while (result.next) {
            NSString *data = [result stringForColumn:@"data"];
            NSDictionary *dic = [NSString dictionaryWithJsonString:data];
            [array addObject:dic];
        }
        [result close];
    }];
    return array;
}

+ (void)deleteFriendRequest:(NSDictionary*)data {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"DELETE FROM FirendRequest WHERE uid = ?",data[@"id"]];
        if (result) {
            NSLog(@"删除成功");
        }
    }];
}

+ (void)deleteAllFriendRequest {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"DELETE FROM FirendRequest"];
        if (result) {
            NSLog(@"删除成功");
        }
    }];
}
@end
