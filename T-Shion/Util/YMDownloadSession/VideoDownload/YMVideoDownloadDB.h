//
//  YMVideoDownloadDB.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/4.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef YMDownload_Mgr_Item
#if __has_include(<YMDownloadItem.h>)
#define YMDownload_Mgr_Item 1
#import <YMDownloadItem.h>
#elif __has_include("YMDownloadItem.h")
#define YMDownload_Mgr_Item 1
#import "YMDownloadItem.h"
#else
#define YMDownload_Mgr_Item 0
#endif
#endif

@interface YMVideoDownloadDB : NSObject

+ (NSArray <YMDownloadTask *> *)fetchAllDownloadTasks;
+ (YMDownloadTask *)taskWithTid:(NSString *)tid;
+ (NSArray <YMDownloadTask *> *)taskWithUrl:(NSString *)url;
+ (NSArray <YMDownloadTask *> *)taskWithStid:(NSInteger)stid; //TODO: add url
+ (void)removeAllTasks;
+ (BOOL)removeTask:(YMDownloadTask *)task;
+ (BOOL)saveTask:(YMDownloadTask *)task;
+ (void)saveAllData;


@end


#if YMDownload_Mgr_Item
@interface YMVideoDownloadDB(item)
+ (NSArray <YMDownloadItem *> *)fetchAllDownloadItemWithUid:(NSString *)uid;
+ (NSArray <YMDownloadItem *> *)fetchAllDownloadedItemWithUid:(NSString *)uid;
+ (NSArray <YMDownloadItem *> *)fetchAllDownloadingItemWithUid:(NSString *)uid;
+ (NSArray <YMDownloadItem *> *)itemsWithUrl:(NSString *)downloadUrl uid:(NSString *)uid;
+ (YMDownloadItem *)itemWithTaskId:(NSString *)taskId;
+ (YMDownloadItem *)itemWithFid:(NSString *)fid uid:(NSString *)uid;
+ (void)removeAllItemsWithUid:(NSString *)uid;
+ (BOOL)removeItemWithTaskId:(NSString *)taskId;
+ (BOOL)saveItem:(YMDownloadItem *)item;
@end
#endif
