//
//  NSString+Storage.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/5/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTCloudAppId  @"1111435842045702146"
#define kTCloudMD5KEY  @"275c6200656c4f0193a39d1e8a8b0b35"

@interface NSString (Storage)

/**
 获取图片原图地址

 @param sourceId 图片资源id
 @return 原图地址
 */
+ (NSString *)ym_imageUrlStringWithSourceId:(NSString *)sourceId;

/**
 根据图片id获取头像缩略图地址

 @param sourceId 图片资源id
 @return 头像缩略图地址
 */
+ (NSString *)ym_thumbAvatarUrlStringWithSourceId:(NSString *)sourceId;

/**
 根据原图地址获取头像缩略图

 @param originalString 原图地址
 @return 头像缩略图地址
 */
+ (NSString *)ym_thumbAvatarUrlStringWithOriginalString:(NSString *)originalString;

/**
 根据图片消息获取图片缩略图地址

 @param message 消息
 @return 缩略图地址
 */
+ (NSString *)ym_thumbImgUrlStringWithMessage:(MessageModel *)message;


/**
 根据文件id获取文件路径

 @param sourceId 文件id
 @return 文件路径
 */
+ (NSString *)ym_fileUrlStringWithSourceId:(NSString *)sourceId;

@end

