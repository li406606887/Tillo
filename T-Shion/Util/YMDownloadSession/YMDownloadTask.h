//
//  YMDownloadTask.h
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/4/30.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 下载完成后的数据处理行为
 - YMDownloadTaskCacheModeDefault: 下载完成后，删除库中的下载数据
 - YMDownloadTaskCacheModeKeep: 下载完成后，不删除库中的下载数据
 */

typedef NS_ENUM(NSUInteger, YMDownloadTaskCacheMode) {
    YMDownloadTaskCacheModeDefault,
    YMDownloadTaskCacheModeKeep
};


@class YMDownloadTask;

typedef void (^YMDownloadStatusHandler)(NSNumber *downloadStatus);

typedef void (^YMCompletionHandler)(NSString  * _Nullable localPath, NSError * _Nullable error);
typedef void (^YMProgressHandler)(NSProgress * _Nonnull progress,YMDownloadTask * _Nonnull task);

@interface YMDownloadTask : NSObject

@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, copy, readonly, nonnull) NSString *taskId;
@property (nonatomic, copy, readonly, nonnull) NSString *downloadURL;

@property (nonatomic, assign, readonly) int64_t fileSize;
@property (nonatomic, assign) int64_t downloadedSize;

@property (nonatomic, copy, nonnull) NSString *version;

/**
 default value: NSURLSessionTaskPriorityDefault
 option: NSURLSessionTaskPriorityDefault NSURLSessionTaskPriorityLow NSURLSessionTaskPriorityHigh
 poiority float value range: 0.0 - 1.0
 */
@property (nonatomic, assign, readonly) float priority;
@property (nonatomic, assign, readonly) BOOL isRunning;
@property (nonatomic, strong, readonly, nonnull) NSProgress *progress;

@property (nonatomic, copy, nullable) YMProgressHandler progressHandler;
@property (nonatomic, copy, nullable) YMCompletionHandler completionHandler;
@property (nonatomic, strong, nonnull) NSData *extraData;

/**
 if no downloadTask, state = -1
 */
@property (nonatomic, assign, readonly) NSURLSessionTaskState state;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - 公用方法
- (void)updateTask;

+ (nonnull instancetype)taskWithRequest:(nonnull NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion;

+ (nonnull instancetype)taskWithRequest:(nonnull NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion priority:(float)priority;

+ (nonnull NSString *)downloaderVerison;


@end

//========================  YMResumeData ===========================

@interface YMResumeData: NSObject

@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, strong) NSMutableURLRequest *currentRequest;
@property (nonatomic, strong) NSMutableURLRequest *originalRequest;
@property (nonatomic, assign) NSInteger downloadSize;
@property (nonatomic, copy) NSString *resumeTag;
@property (nonatomic, assign) NSInteger resumeInfoVersion;
@property (nonatomic, strong) NSDate *downloadDate;
@property (nonatomic, copy) NSString *tempName;
@property (nonatomic, copy) NSString *resumeRange;

- (instancetype)initWithResumeData:(NSData *)resumeData;

+ (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData urlSession:(NSURLSession *)urlSession;

/**
 清除 NSURLSessionResumeByteRange 字段
 修正iOS11.0 iOS11.1 多次暂停继续 文件大小不对的问题(iOS11.2官方已经修复)
 
 @param resumeData 原始resumeData
 @return 清除后resumeData
 */
+ (NSData *)cleanResumeData:(NSData *)resumeData;
@end


NS_ASSUME_NONNULL_END
