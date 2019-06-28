//
//  FMDBManager+GroupMessage.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager+GroupMessage.h"

@implementation FMDBManager (GroupMessage)
#pragma mark 创建群聊天室成员表
+ (void)creatGroupMemberTableWithRoomId:(NSString *)roomId {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *messageSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Member_%@ (member_id TEXT NOT NULL, avatar TEXT, name TEXT, delFlag INTEGER, nickName TEXT)",roomId];
        BOOL friend = [db executeUpdate:messageSql];
        if (friend) {
            NSLog(@"创建member表成功");
        } else {
            NSLog(@"创建member表失败");
        }
    }];
}

+ (void)updateGroupMemberWithRoomId:(NSString *)roomId member:(MemberModel *)member {
    [FMDBManager selectGroupMemberWithRoomID:roomId member:member isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO Member_%@ (member_id, avatar, name, delFlag, nickName) VALUES (?, ?, ?, ?, ?)",roomId];
            BOOL result = [db executeUpdate:sql,member.userId,member.avatar,member.name, @(member.delFlag), member.groupName];
            if (!result) {
                NSLog(@"updateGroupMemberWithRoomId 群成员插入失败");
            }
        } else {  // 如果已经存在,更新最后一条消息
            NSString *sql = [NSString stringWithFormat:@"UPDATE Member_%@ SET avatar = ?, name = ?, delFlag = ?, nickName = ? WHERE member_id = ?",roomId];
            BOOL result = [db executeUpdate:sql,member.avatar,member.name,@(member.delFlag), member.groupName,member.userId];
            if (!result) {
                NSLog(@"updateGroupMemberWithRoomId 群成员更新失败");
            }
        }
    }];
}


+ (void)selectGroupMemberWithRoomID:(NSString *)ID member:(MemberModel *)member isExist:(void (^)(BOOL, FMDatabase *))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        //add by wsp :成员在群聊的昵称扩展字段， 2019.4.25
        NSString *tableName = [NSString stringWithFormat:@"Member_%@", ID];
        [FMDBManager addColumn:@"nickName" columnType:@"TEXT" inTableWithName:tableName dataBase:db];
        //end
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@ WHERE member_id = ?",ID];
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:sqlString,member.userId];
        while (result.next) {
            e = YES;
            NSString *friendId = [result stringForColumnIndex:0];
            NSLog(@"memberID ===  %@",friendId);
            break;
        }
        [result close];
        exist(e, db);
    }];
}

+ (void)updateGroupMemberDeflagWithRoomId:(NSString *)roomId memberId:(NSString *)memberId {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE Member_%@ SET delFlag = 1 WHERE member_id = ?",roomId];
        BOOL result = [db executeUpdate:sql,memberId];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}

+ (MemberModel *)selectedMemberWithRoomId:(NSString *)roomId memberID:(NSString *)memberID {
    __block MemberModel *model;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@ WHERE member_id = ?",roomId];
        FMResultSet *result = [db executeQuery:sqlString,memberID];
        while (result.next) {
            model = [MemberModel initMemberWithResult:result];
            FMResultSet * memberResult = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id = ?",model.userId];
            while (memberResult.next) {
                [FriendsModel initMemberWith:model result:memberResult];
            }
            [memberResult close];
        }
        [result close];
    }];
    return model;
}

+ (NSMutableArray *)selectGroupMessageWithTableName:(NSString *)tableName timestamp:(NSString *)timestamp count:(int)count {
    NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sqlString;
        FMResultSet *result;
        if (timestamp != nil) {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@  WHERE delFlag=0 AND timestamp < ? ORDER BY timestamp DESC limit %d",tableName,count];
            result = [db executeQuery:sqlString,timestamp];
        }else {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM Message_%@ WHERE delFlag=0 ORDER BY timestamp DESC LIMIT %d",tableName,count];
            result = [db executeQuery:sqlString];
        }
        while (result.next) {
            MessageModel *message = [MessageModel initMessageWithResult:result];
            [array addObject:message];
        }
        [result close];
    }];
    return array;
}

+ (NSMutableArray *)selectedAllMemberWithRoomId:(NSString *)roomId {
    NSMutableArray *array = [NSMutableArray array];
    if (roomId) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@",roomId];
            FMResultSet *result = [db executeQuery:sqlString];
            while (result.next) {
                MemberModel *model = [MemberModel initMemberWithResult:result];
                FMResultSet * memberResult = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id = ?",model.userId];
                while (memberResult.next) {
                    [FriendsModel initMemberWith:model result:memberResult];
                }
                [memberResult close];
                [array addObject:model];
            };
            [result close];
        }];
    }
    return array;
}

+ (NSMutableArray *)selectedMemberWithRoomId:(NSString *)roomId {
    NSMutableArray *array = [NSMutableArray array];
    if (roomId) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@",roomId];
            FMResultSet *result = [db executeQuery:sqlString];
            while (result.next) {
                MemberModel *model = [MemberModel initMemberWithResult:result];
                if (model.delFlag == 0) {
                    FMResultSet * memberResult = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id = ?",model.userId];
                    while (memberResult.next) {
                        [FriendsModel initMemberWith:model result:memberResult];
                    }
                    [memberResult close];
                    [array addObject:model];
                }
            };
            [result close];
        }];
    }
    return array;
}

+ (NSMutableArray *)selectedOtherMemberWithRoomId:(NSString *)roomId {
    NSMutableArray *array = [NSMutableArray array];
    if (roomId) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@",roomId];
            FMResultSet *result = [db executeQuery:sqlString];
            while (result.next) {
                MemberModel *model = [MemberModel initMemberWithResult:result];
                if (model.delFlag == 0) {
                    FMResultSet * memberResult = [db executeQuery:@"SELECT * FROM Friend WHERE friend_id = ?",model.userId];
                    while (memberResult.next) {
                        [FriendsModel initMemberWith:model result:memberResult];
                    }
                    [memberResult close];
                    if (![model.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
                        [array addObject:model];
                    }
                }
            };
            [result close];
        }];
    }
    return array;
}
/* 查询friend表 获取可添加成员
 * @return friendModel数组
 */
+ (NSMutableArray *)selectAbleMemberWithRoomId:(NSString *)roomId {
    NSMutableArray *array = [NSMutableArray array];
    if (roomId) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet * fresult = [db executeQuery:@"SELECT * FROM Friend"];
            while (fresult.next) {
                NSString *userId = [fresult stringForColumn:@"friend_id"];
                NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@ WHERE member_id = ?",roomId];
                FMResultSet *memresult = [db executeQuery:sqlString,userId];
                NSString *memberId;
                while (memresult.next) {
                    memberId = [memresult stringForColumn:@"member_id"];
                    BOOL deflag = [memresult boolForColumn:@"delFlag"];
                    if (deflag) {
                        memberId = nil;
                    }
                }
                [memresult close];
                if (!memberId) {
                    MemberModel *model = [[MemberModel alloc] init];
                    model.userId = userId;
                    model.roomId = roomId;
                    model.name = [fresult stringForColumn:@"show_name"];
                    model.avatar = [fresult stringForColumn:@"avatar"];
                    model.groupName = [fresult stringForColumn:@"nickName"];
                    [array addObject:model];
                }
            }
            [fresult close];
        }];
    }
    return array;
}
/* 查询friend表 创建群成员
 * @return MemberModel数组
 */
+ (NSMutableArray *)getMemberCreatGroup {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * fresult = [db executeQuery:@"SELECT * FROM Friend"];
        while (fresult.next) {
            NSString *userId = [fresult stringForColumn:@"friend_id"];
            MemberModel *model = [[MemberModel alloc] init];
            model.userId = userId;
            model.name = [fresult stringForColumn:@"show_name"];
            model.avatar = [fresult stringForColumn:@"avatar"];
            model.groupName = [fresult stringForColumn:@"nickName"];
            [array addObject:model];
        }
        [fresult close];
    }];
    return array;
}

+ (MemberModel *)selectedGroupMemberWithRoomId:(NSString *)roomId memberId:(NSString *)memberId {
    __block MemberModel *member = [[MemberModel alloc] init];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@ WHERE member_id = ?",roomId];
        FMResultSet *memresult = [db executeQuery:sqlString,memberId];
        while (memresult.next) {
            member = [MemberModel initMemberWithResult:memresult];
        };
        [memresult close];
    }];
    return member;
}
/**
 根据roomid查询群内有效人数
 
 @param roomId 房间号
 @return 群成员数量
 */
+ (int)selectedMemberCountWithRoomId:(NSString *)roomId {
    __block int count = 0;
    if (roomId) {
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM Member_%@",roomId];
            FMResultSet *result = [db executeQuery:sqlString];
            while (result.next) {
                MemberModel *model = [MemberModel initMemberWithResult:result];
                if (model.delFlag == 0) {
                    count ++;
                }
            };
            [result close];
        }];
    }
    return count;
}

//加密群聊用的查询群里成员的userId
+ (NSArray *)getAllMemberUserIdByGroupId:(NSString*)groupID {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT member_id FROM Member_%@ WHERE delFlag LIKE 0", groupID];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSString *string = [result stringForColumn:@"member_id"];
            [array addObject:string];
        }
        [result close];
    }];
    return array;
}
@end
