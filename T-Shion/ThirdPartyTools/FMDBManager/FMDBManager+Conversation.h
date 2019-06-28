//
//  FMDBManager+Conversation.h
//  T+Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"
#import "MessageModel.h"

@interface FMDBManager (Conversation)
/*
 * 根据roomid查询是否存在数据
 */
+ (void)selectConversationWithRoomId:(NSString *)roomId isExist:(void (^)(BOOL, FMDatabase *))exist;
/*
 * 向会话表添加离线数据
 */
+ (void )insertSessionOfflineWithType:(NSString *)type message:(MessageModel *)message withCount:(int)count;
/*
 * 向会话表添加在线数据
 */
+ (void )insertSessionOnlineWithType:(NSString *)type message:(MessageModel *)message withCount:(int)count;
/**
 删除房间内最后一条消息 更新会话显示的内容
 @param type singleChat groupChat
 @param message 消息
 */
+ (void)updateOnlineWithType:(NSString *)type message:(MessageModel *)message;
/*
 * 将离线消息数转换成在线消息数
 */
+ (BOOL )offlineCountConvertedToOnlineCountWithRoomId:(NSString *)roomId;
/*
 * 将在线消息数转换成离线消息数
 */
+ (BOOL )OnlineCountConvertedToOfflineCountWithRoomId:(NSString *)roomId;
/* 查询会话表
 * @return DialogueModel数组
 */
+ (NSMutableArray *)selectConversationTable ;
/* 查询会话表房间内未读消息数
 * @return DialogueModel数组
 */
+ (int)selectUnreadCountWithRoomId:(NSString *)roomId;
/* 清除在线消息数
 * @prarm roomId房间ID
 */
+ (void)clearMessageUnreadCountWithRoomId:(NSString *)roomId ;
/* 清除离线消息数
 * @prarm roomId房间ID
 */
+ (void)clearMessageOfflineCountWithRoomId:(NSString *)roomId ;
/* 获取所有会话消息数
 * @prarm roomId房间ID
 */
+ (int)getMessageUnreadCount;

+ (NSInteger)getSessionUnreadCount;
/* 清除离线消息数
 * @prarm roomId房间ID
 */
+ (BOOL)deleteConversationWithRoomId:(NSString *)roomId;
/* 清空会话内容
 * @prarm roomId房间ID
 */
+ (BOOL)cleanConversationTextWithRoomId:(NSString *)roomId;
#pragma mark - 草稿相关
/**
 更新或插入查稿

 @param roomId 房间id
 @param draftContentText 草稿内容
 @param isSingleChat 是否是单聊
 */
+ (void)updateDraftContentWithRoomId:(NSString *)roomId
                    draftContentText:(NSString *)draftContentText
                        isSingleChat:(BOOL)isSingleChat;


/**
 更新草稿内容at的人列表

 @param roomId 房间id
 @param draftAtList at的人列表
 */
+ (void)updateDraftAtListWithRoomId:(NSString *)roomId
                        draftAtList:(NSString *)draftAtList;

/**
 查询草稿内容

 @param roomId 房间id
 @return 查询结果返回字典 {draftContent:文字内容, draftAtList:群聊at模型数组}
 */
+ (NSDictionary *)selectConversationDraftDataWithRoomId:(NSString *)roomId;

@end
