//
//  FMDBManager.h
//  T-Shion
//
//  Created by together on 2018/4/24.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendsModel.h"
#import "SessionModel.h"
#import "MessageModel.h"

@class PHAssetCollection;

@interface FMDBManager : NSObject
+ (FMDBManager *)shared;
/* db
 * 数据库
 */
@property (strong, nonatomic) FMDatabase *db;
/* DBQueue
 * 数据库线程
 */
@property (strong, nonatomic) FMDatabaseQueue *DBQueue;
/*
 * 获取相册
 */
+ (PHAssetCollection *)createdCollection;

/*
 * 照片存入相册
 */
+ (NSString *)saveImageIntoAlbum:(UIImage *)image;

/*
 * 删除照片相册
 */
+ (void)deleteImageWithImageName:(NSString *)fileName;

/* 查找本地文件是否存在
 * model - message 的模型
 */
+ (BOOL)seletedFileIsSaveWithPath:(MessageModel *)model;

/* 查找本地文件是否存在
 * filePath - 文件路径
 */
+ (BOOL)seletedFileIsSaveWithFilePath:(NSString *)filePath;

/* 查询本地文件是否存在
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (NSString *)getMessagePathWithMessage:(MessageModel*)model;

/* 查询本地图片文件是否存在
 * @prarm filePath 文件路径
 */
+ (NSString *)getImagePathWithFilePath:(NSString *)filePath;

/**
 获取位置消息地图截屏文件

 @param filePath 文件路径
 @return 文件路径
 */
+ (NSString *)getMapSnapshotPathWithFilePath:(NSString *)filePath;


/**
 获取本地视频文件夹

 @param filePath filePath 文件路径
 @return filePath
 */
+ (NSString *)getVideoPathWithFilePath:(NSString *)filePath;


/* 查询消息数据
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (void)updateUnsendMessageStatus;

/* 查询房间设置数据
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (NSDictionary *)selectedRoomSettingWithRoomId:(NSString *)roomId;

/* 查询房间是否免打扰
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (BOOL)selectedRoomDisturbWithRoomId:(NSString *)roomId;

/* 设置房间是否置顶
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (BOOL)selectedRoomTopWithRoomId:(NSString *)roomId;

/* 更新房间数据
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (void)updateRoomSettingWithRoomId:(NSString *)roomId disturb:(BOOL)disturb top:(BOOL)top;

/* 设置房间黑名单
 * @prarm roomId 房间id blacklistFlag 黑名单
 */
+ (void)setRoomBlackWithRoomId:(NSString *)roomId blacklistFlag:(BOOL)blacklistFlag;

/* 查询房间是否拉黑
 * @prarm roomId 房间号
 */
+ (BOOL)selectedRoomBlackWithRoomId:(NSString *)roomId;

/* 断线重发状态为发送中的消息
 * @prarm roomId 房间id disturb 是否打扰
 */
+ (void)resendUnsendMessage;


#pragma mark - 新增字段

/**
 数据库表新增字段

 @param column 字段名
 @param columnType 字段类型
 @param tableName 表名
 @param db 数据库
 @return 是否扩展成功
 */
+ (BOOL)addColumn:(NSString *)column
       columnType:(NSString *)columnType
  inTableWithName:(NSString *)tableName
         dataBase:(FMDatabase *)db;

@end
