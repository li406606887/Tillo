//
//  YMImageDownloader.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/4.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BGCompletedHandler)(void);

@protocol YMImageDownloader <NSObject>
/**
 单利downloader
 */
+ (nonnull instancetype)downloader;

@end


@interface YMImageDownloader : NSObject <YMImageDownloader>

/**
 是否允许蜂窝煤网络下载
 */
@property (nonatomic, assign) BOOL allowsCellularAccess;

/**
 下载完成后的数据处理行为
 */
@property (nonatomic, assign) YMDownloadTaskCacheMode taskCachekMode;

/**
 单利downloader
 */
+ (nonnull instancetype)downloader;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 通过url开始创建下载任务，手动调用resumeTask:开始下载
 
 @param url 下载url
 @param progress 下载进度
 @param completion 下载成功或者失败回调
 @return 下载任务的task
 */
- (nonnull YMDownloadTask *)downloadWithUrl:(nonnull NSString *)url progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion;

/**
 通过request对象创建下载任务，可以自定义header等请求信息，手动调用resumeTask:开始下载
 
 @param request request 对象
 @param progress 下载进度回调
 @param completion 下载成功失败回调
 @return 下载任务task
 */
- (nonnull YMDownloadTask *)downloadWithRequest:(nonnull NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion;

/**
 通过request对象进行创建下载任务，可以自定义header等请求信息，手动调用resumeTask:开始下载
 
 @param request request 对象
 @param progress 下载进度回调
 @param completion 下载成功失败回调
 @param priority 下载任务优先级，默认是 NSURLSessionTaskPriorityDefault, 取值范围0~1
 @return 下载任务task
 */
- (nonnull YMDownloadTask *)downloadWithRequest:(nonnull NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion priority:(float)priority;

/**
 恢复下载任务，继续下载任务，主要用于app异常退出状态恢复，继续下载任务的回调设置
 
 @param tid 下载任务的taskId
 @param progress 下载进度回调
 @param completion 下载成功失败回调
 @return 下载任务task
 */
- (nonnull YMDownloadTask *)resumeDownloadTaskWithTid:(NSString *)tid progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion;

/**
 继续下载任务
 
 @param task 需要继续的task
 @return 是否继续下载成功，失败后可冲洗下载
 */
- (BOOL)resumeTask:(nonnull YMDownloadTask *)task;

/**
 暂停下载任务
 
 @param task 需要暂停的task
 */
- (void)pauseTask:(nonnull YMDownloadTask *)task;

/**
 暂停下载任务
 
 @param task 需要删除的task
 */
- (void)cancelTask:(nonnull YMDownloadTask *)task;

/**
 后台某一下载任务完成时，第一次在AppDelegate中的 -(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
 回调方法中调用该方法。多个task，一个session，只调用一次AppDelegate的回调方法。
 completionHandler 回调执行后，app被系统唤醒的状态会变为休眠状态。
 
 @param handler 后台任务结束后的调用的处理方法
 @param identifier background session 的标识
 */
- (void)addCompletionHandler:(BGCompletedHandler)handler identifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
