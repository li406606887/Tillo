//
//  FMDBManager+GroupList.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager+GroupList.h"

@implementation FMDBManager (GroupList)
+ (BOOL)updateGroupListWithModel:(GroupModel *)model {
    __block BOOL result = NO;
    [FMDBManager selectGroupWithRoomId:model.roomId isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            result = [db executeUpdate:@"INSERT INTO GroupList (name, owner, room_id, avatar, inviteSwitch, memberCount, isCrypt) VALUES (?, ?, ?, ?, ?, ?, ?)",model.name,model.owner,model.roomId,model.avatar,@(model.inviteSwitch),@(model.memberCount), @(model.isCrypt)];
            if (result) {
                NSLog(@"插入成功");
            }
        } else {  // 如果已经存在,更新最后一条消息
            result = [db executeUpdate:@"UPDATE GroupList SET name =?, owner = ?, avatar = ?, inviteSwitch = ?, memberCount = ?, isCrypt = ? WHERE room_id = ?",model.name,model.owner,model.avatar,@(model.inviteSwitch),@(model.memberCount), @(model.isCrypt), model.roomId];
            NSLog(@"%@-----",model.owner);
            if (result) {
                NSLog(@"更新成功");
            }
        }
    }];
    return result;
}

+ (void)selectGroupWithRoomId:(NSString *)roomId isExist:(void (^)(BOOL, FMDatabase *))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [FMDBManager addColumn:@"inviteSwitch" columnType:@"BOOLEN" inTableWithName:@"GroupList" dataBase:db];
        [FMDBManager addColumn:@"memberCount" columnType:@"INT" inTableWithName:@"GroupList" dataBase:db];
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM GroupList WHERE room_id = ?", roomId];
        while (result.next) {
            e = YES;
            NSString *roomId = [result stringForColumnIndex:0];
            NSLog(@"%@",roomId);
            break;
        }
        [result close];
        exist(e, db);
    }];
}

+ (NSMutableArray *)selectedGroupList {
    NSMutableArray *modelArray = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM GroupList"];
        while (result.next) {
            GroupModel *model = [GroupModel initModelWithResult:result];
            if (![model.deflag isEqualToString:@"1"]) {
                [modelArray addObject:model];
            }
        }
        [result close];
    }];
    return modelArray;
}

+ (GroupModel *)selectGroupModelWithRoomId:(NSString*)roomId {
    __block GroupModel *model;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:@"SELECT * FROM GroupList WHERE room_id = ?",roomId];
        while (result.next) {
            model = [GroupModel initModelWithResult:result];
        }
        [result close];
    }];
    return model;
}
/* 根据keyword 查询群名称或者群成员名称
 * @param keyword 关键字
 */
+ (NSArray *)selectedGroupWithKeyword:(NSString *)keyword {
    if (keyword.length<1) {
        return nil;
    }
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM GroupList WHERE name LIKE '%%%@%%' ",keyword];
        FMResultSet *result = [db executeQuery:sql];//,keyword,keyword
        while (result.next) {
            GroupModel *model = [GroupModel initModelWithResult:result];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}

+ (BOOL)deleteGroupWithRoomId:(NSString *)roomId {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"DELETE FROM GroupList WHERE room_id = ?", roomId];
        result = [db executeUpdate:@"DELETE FROM Conversation WHERE room_id = ?",roomId];
    }];
    return result;
}

+ (BOOL)beDeletedWithRoomId:(NSString *)roomId deflag:(NSString *)deflag {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"UPDATE GroupList SET deflag = ? WHERE room_id = ?", deflag, roomId];
    }];
    return result;
}
/* modify group name
 * param friendModel
 */
+ (BOOL)updateGroupNameWithRoomId:(NSString *)roomId name:(NSString *)name {
    __block BOOL result = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"UPDATE GroupList SET name = ? WHERE room_id = ?",name ,roomId];
    }];
    return result;
}

+ (NSArray *)selectMemberWithRoomId:(NSString *)roomId keyWord:(NSString *)keyWord {
    __block NSMutableArray *array = [NSMutableArray array];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Member_%@ WHERE delFlag LIKE 0 AND name LIKE '%%%@%%' ",roomId,keyWord];
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            MemberModel *model = [MemberModel initMemberWithResult:result];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}

+ (void)updateGroupInviteSwitchWithRoomId:(NSString *)roomId state:(BOOL)state {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"UPDATE GroupList SET inviteSwitch = ? WHERE room_id = ?",@(state),roomId];
        if (result) {
            NSLog(@"更新房间邀请二维码的开关状态成功");
        }
    }];
}

@end
