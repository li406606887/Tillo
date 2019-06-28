//
//  FMDBManager+Friend.h
//  T-Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"

@interface FMDBManager (Friend)


/* 根据friendID查询是否存在数据
 * @return friendModel数组
 */
+ (void)selectFriendWithFriendId:(NSString *)friendId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist ;
/* 刷新本地通讯录
 * 网络重连或登陆成功后调用 @return 查询friend表 返回的friendModel数组
 */
+ (void)refreshFriendTableWithArray:(NSArray *)array ;
/* 查询friend表
 * @return friendModel数组
 */
+ (NSMutableArray *)selectFriendTable ;
/* 根据roomID查询friend表
 * @return friendModel
 */
+ (FriendsModel *)selectFriendTableWithRoomId:(NSString *)roomId ;
/* 根据roomID查询friend表
 * @return friendModel
 */
+ (FriendsModel *)selectFriendTableWithUid:(NSString *)uid ;
/* 更新friend表
 * param friendModel
 */
+ (BOOL)updateFriendTableWithFriendsModel:(FriendsModel *)model ;
/* 根据keyword 查询好友
 * @param keyword 关键字
 */
+ (NSArray *)selectedFriendWithKeyword:(NSString *)keyword;
/* 消息置顶
 * param friendModel
 */
+ (BOOL)friendSesstionTopWithFriendsModel:(FriendsModel *)model ;
/* 删除好友
 * param friendModel
 */
+ (BOOL)deleteFriendWithFriendsModel:(FriendsModel *)model ;

#pragma mark - getter
/*
 * 查询黑名单人员
 */
+ (NSMutableArray *)selectBlackFriend ;
/* 更新数据库好友添加请求的数据
 * @prarm array 数据数组
 */
+ (void)updataFriendRequestData:(NSDictionary*)data;

/*
 查询数据库好友添加请求的数据
 * @prarm array 数据数组
 */
+ (NSMutableArray *)selectFriendRequest;
/*
 删除好友添加请求的数据
 * @prarm data 数据好友请求的数据
 */
+ (void)deleteFriendRequest:(NSDictionary*)data;
/*
 删除好友添加请求的全部数据
 */
+ (void)deleteAllFriendRequest;
@end
