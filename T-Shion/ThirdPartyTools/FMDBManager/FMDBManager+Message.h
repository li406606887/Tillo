//
//  FMDBManager+Message.h
//  T+Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"
#import "MessageModel.h"
#import "MemberModel.h"

@interface FMDBManager (Message)
/* 根据房间ID创建message表
 * @prarm roomId房间ID
 */
+ (BOOL)creatMessageTableWithRoomId:(NSString *)roomId ;
/* 插入消息
 * @prarm messageModel
 */
+ (BOOL)insertMessageWithContentModel:(MessageModel *)model;
/* 插入发送中的消息
 * @prarm messageModel
 */
+ (BOOL)insertUnsendMessageWithContentModel:(MessageModel *)model;
/**
 更新消息的fileName
 @prarm messageModel
 */
+ (BOOL)updateFileNameWithMessageModel:(MessageModel *)model;

/**
 更新t视频消息第一帧文件名
 @prarm messageModel
 */
+ (BOOL)updateVideoThumbIMGNameWithMessageModel:(MessageModel *)model;

/**
 更新未发送消息
 @prarm messageModel
 */
+ (BOOL)updateUnsendMessageWithContentModel:(MessageModel *)model;

/**
 修改消息状态由未读变已读
 @prarm messageModel
 */
+ (void)updateReadedMessageWithModel:(MessageModel *)model;

/**
 更新未发送消息的发送状态

 @param roomId 房间id
 @param backId 回执id
 @param sendState 消息发送状态 1是送达 2是失败 3是发送中
 @return 是否更新成功
 */
+ (BOOL)updateUnsendMessageStatusWithRoomId:(NSString *)roomId
                                     backId:(NSString *)backId
                                  sendState:(NSString *)sendState;

/* 更新 已发送的数据
 * @prarm messageModel
 */
+ (BOOL)updateSendSuccessMessageModelWithContentModel:(MessageModel *)model;
/*
 * 根据messageId查询是否存在大图片
 */
+ (NSString *)selectBigImageWithMessageModel:(MessageModel *)model ;
/* 更新 大图片地址
 * @prarm roomId房间ID messageId消息ID  bigName大图名称
 */
+ (BOOL)updateMessagBigImagePathWithRoomId:(NSString *)roomId messageId:(NSString *)messageId assetName:(NSString *)assetName fileName:(NSString*)fileName;
/**
 查询消息数据
 @prarm timestamp 时间戳  tableName 表名字
 */
+ (NSMutableArray *)selectMessageWithTableName:(NSString *)tableName timestamp:(NSString*)timestamp count:(int)count;
/**
 根据时间戳查询大于时间戳的消息数
 @prarm roomId 房间号 timestamp 时间戳
 @return 消息数量
 */
+ (int)selectedHistoryMsgWithRoomId:(NSString *)roomId timestamp:(NSString *)timestamp;
/**
 查询图片和视频数据
 @prarm timestamp 时间戳  tableName 表名字
 @return 以位置为键 数组为值的字典
 */
+ (NSDictionary *)selectImageOrVideoWithRoom:(NSString *)roomId messageId:(NSString *)messageId;
/**
 查询图片数据
 @prarm timestamp 时间戳  tableName 表名字
 @return 以位置为键 数组为值的字典
 */
+ (NSDictionary *)selectImageWithRoom:(NSString *)roomId messageId:(NSString *)messageId;
/**
 查询文件类型消息
 @prarm timestamp 时间戳  tableName 表名字
 @return 以位置为键 数组为值的字典
 */
+ (NSArray *)selectFileWithRoom:(NSString *)roomId keyWord:(NSString *)keyWord;
/**
 清空消息和文件
 @prarm roomid  房间号
 */
+ (BOOL)deleteAllMessageWithRoomId:(NSString *)roomid;

/* 删除单条消息和文件
 * @prarm model 模型
 */
+ (BOOL)deleteMessageWithMessage:(MessageModel *)model;

//是否已经存在该消息
+ (BOOL)isAlreadyHadMsg:(MessageModel *)msgModel;
/* 撤回消息
 * @prarm model
 */
+ (BOOL)withdrawMessageWithMsgId:(NSString *)msgId roomId:(NSString *)roomId;
/* 获取所有消息表的表名
 * @prarm nil
 */
+ (NSArray *)selectedAllMsgTableName;
/* 获取消息表所有符合字段的消息消息
 * @prarm keyWord 关键字 roomId 房间号
 */
+ (NSArray *)selectedAllHistoryMessageWithKeyWord:(NSString *)keyWord ;
/* 获取消息表所有符合字段的消息消息
 * @prarm keyWord 关键字 roomId 房间号
 */
+ (NSArray *)selectedMessageWithKeyWord:(NSString *)keyWord roomId:(NSString *)roomId;

/**
 清空加密聊天消息表数据
 
 @param roomid 房间id
 @param del 是否删除了会话（用于判断是否重新添加提示用）
 @return BOOL
 */
+ (BOOL)deleteCryptMessageWithRoomId:(NSString *)roomid isDeleteConversation:(BOOL)del;

//获取消息表中最后一条离线消息的时间戳
+ (NSString*)lastedOfflineMessageTimeWithRoomId:(NSString*)roomId;

/**
 改变所有消息的查看状态
 
 @param roomId 房间号
 */
+ (void)ChangeAllMessageReadStatusWithRoomId:(NSString*)roomId;
/**
 查询表内第一条未查看的消息
 
 @param roomId 房间号
 */
+ (MessageModel*)selectFirstUnReadMessageWithRoomId:(NSString*)roomId;
/**
 根据消息ID查询表内某一条消息
 
 @param roomId 房间号
 */
+ (MessageModel*)selectMessageWithRoomId:(NSString*)roomId msgId:(NSString *)msgId;
@end
