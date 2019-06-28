//
//  NSFileManager+AL.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (AL)

/**
 *  图片 — 聊天
 */
+ (NSString *)pathUserChatImage:(NSString*)imageName;

/**
 *  图片 — 用户头像
 */
+ (NSString *)pathUserAvatar:(NSString *)imageName;


/**
 *  聊天语音
 */
+ (NSString *)pathUserChatVoice:(NSString *)voiceName;


/**
 *  数据库 — 通用
 */
+ (NSString *)pathDBCommon;

/**
 *  数据库 — 聊天
 */
+ (NSString *)pathDBMessage;

/**
 *  缓存
 */
+ (NSString *)cacheForFile:(NSString *)filename;


@end

