//
//  YMDownloadUtils.h
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/4/30.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define YM_DEVICE_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

NS_ASSUME_NONNULL_BEGIN

@interface YMDownloadUtils : NSObject

/**
 获取当前手机的空闲磁盘空间
 */
+ (int64_t)ym_fileSystemFreeSize;

/**
 将文件的字节大小，转换成更加容易识别的大小KB，MB，GB
 */
+ (NSString *)ym_fileSizeStringFromBytes:(int64_t)byteSize;

/**
 字符串md5加密
 
 @param string 需要MD5加密的字符串
 @return MD5后的值
 */
+ (NSString *)ym_md5ForString:(NSString *)string;

/**
 创建路径
 */
+ (void)ym_createPathIfNotExist:(NSString *)path;

+ (int64_t)ym_fileSizeWithPath:(NSString *)path;

+ (NSString *)ym_urlStrWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

+ (NSUInteger)sec_timestamp;

@end

NS_ASSUME_NONNULL_END
