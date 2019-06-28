//
//  FMDBManager+GroupMessage.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"

@interface FMDBManager (GroupMessage)
/*
 * 根据房间ID创建member表
 */
+ (void)creatGroupMemberTableWithRoomId:(NSString *)roomId;
/*
 * 更新群成员
 */
+ (void)updateGroupMemberWithRoomId:(NSString *)roomId member:(MemberModel *)member;
/*
 * 更改群成员存在状态
 */
+ (void)updateGroupMemberDeflagWithRoomId:(NSString *)roomId memberId:(NSString *)memberId;
/*
 * 查询成员是否存在
 */
+ (void)selectGroupMemberWithRoomID:(NSString *)ID member:(MemberModel *)member isExist:(void (^)(BOOL, FMDatabase *))exist;
/*
 * 根据MemberID查询群成员
 */
+ (MemberModel *)selectedMemberWithRoomId:(NSString *)roomId memberID:(NSString *)memberID;
/*
 * 查询群历史消息
 */
+ (NSMutableArray *)selectGroupMessageWithTableName:(NSString *)tableName timestamp:(NSString*)timestamp count:(int)count;
/*
 * 根据roomid查询所有群成员
 */
+ (NSMutableArray *)selectedAllMemberWithRoomId:(NSString *)roomId ;
/*
 * 根据roomid查询所有有效群成员
 */
+ (NSMutableArray *)selectedMemberWithRoomId:(NSString *)roomId;
/*
 * 根据roomid查询所有群不包括群主有效成员
 */
+ (NSMutableArray *)selectedOtherMemberWithRoomId:(NSString *)roomId;

/* 查询friend表 获取可添加成员
 * @return MemberModel数组
 */
+ (NSMutableArray *)selectAbleMemberWithRoomId:(NSString *)roomId;
/* 查询friend表 创建群成员
 * @return MemberModel数组
 */
+ (NSMutableArray *)getMemberCreatGroup;


+ (MemberModel *)selectedGroupMemberWithRoomId:(NSString *)roomId memberId:(NSString *)memberId;

/**
 根据roomid查询群内有效人数

 @param roomId 房间号
 @return 群成员数量
 */
+ (int )selectedMemberCountWithRoomId:(NSString *)roomId;


//加密群聊用的查询群里成员的userId
+ (NSArray *)getAllMemberUserIdByGroupId:(NSString*)groupID;

@end
