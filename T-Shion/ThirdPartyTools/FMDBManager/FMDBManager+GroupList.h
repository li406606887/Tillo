//
//  FMDBManager+GroupList.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"
#import "GroupModel.h"

@interface FMDBManager (GroupList)
/*
 * 更新插入Group Conversation 列表
 */
+ (BOOL)updateGroupListWithModel:(GroupModel *)model;
/*
 * 根据roomid查询是否存在数据
 */
+ (void)selectGroupWithRoomId:(NSString *)roomId isExist:(void (^)(BOOL, FMDatabase *))exist ;
/*
 * 本地查询groupListTable
 */
+ (NSMutableArray *)selectedGroupList;
/* 根据keyword 查询群名称或者群成员名称
 * @param keyword 关键字
 */
+ (NSArray *)selectedGroupWithKeyword:(NSString *)keyword;
/* select group
 * param roomId
 */
+ (GroupModel *)selectGroupModelWithRoomId:(NSString*)roomId ;
/* modify group name
 * param friendModel
 */
+ (BOOL)updateGroupNameWithRoomId:(NSString *)roomId name:(NSString *)name;
/* 删除群组
 * param GroupModel
 */
+ (BOOL)deleteGroupWithRoomId:(NSString *)roomId;

/* 标记被移出群聊
 * param GroupModel
 */
+ (BOOL)beDeletedWithRoomId:(NSString *)roomId deflag:(NSString *)deflag;
/* select member with keyword
 * param friendModel
 */
+ (NSArray *)selectMemberWithRoomId:(NSString *)roomId keyWord:(NSString *)keyWord;
/**
 更新房间邀请二维码的开关状态
 @param roomId 房间号 state 开关状态 yes 开 no 关闭
 */
+ (void)updateGroupInviteSwitchWithRoomId:(NSString *)roomId state:(BOOL)state;
@end
