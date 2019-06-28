//
//  YMDownLoadConfig.h
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/5/5.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDownloadItem.h"
#import "YMDownloader.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMDownLoadConfig : NSObject

/**
 设置用户标识
 */
@property (nonatomic, copy, nullable) NSString *uid;

/**
 文件保存根路径，默认是Library/Cache/YMDownload目录，系统磁盘不足时，会被系统清理
 更多信息:https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW2
 */
@property (nonatomic, copy, nullable) NSString *saveRootPath;

/**
 最大下载任务个数
 */
@property (nonatomic, assign) NSUInteger maxTaskCount;

@property (nonatomic, assign) YMDownloadTaskCacheMode taskCachekMode;

/**
 冷启动是否自动恢复下载中的任务，否则会暂停所有任务
 */
@property (nonatomic, assign) BOOL launchAutoResumeDownload;

@end

NS_ASSUME_NONNULL_END
