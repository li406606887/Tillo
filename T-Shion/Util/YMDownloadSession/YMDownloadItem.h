//
//  YMDownloadItem.h
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/5/5.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN

@class YMDownloadItem;

extern NSString * const kDownloadTaskFinishedNoti;
extern NSString * const kFinishDownloadCryptoImageNoti;

typedef NS_ENUM(NSUInteger, YMDownloadStatus) {
    YMDownloadStatusUnknow,      //未知
    YMDownloadStatusWaiting,     //等待中
    YMDownloadStatusDownloading, //下载中
    YMDownloadStatusPaused,      //暂停
    YMDownloadStatusFailed,      //失败
    YMDownloadStatusFinished     //结束
};

@protocol YMDownloadItemDelegate <NSObject>

@optional
- (void)downloadItemStatusChanged:(nonnull YMDownloadItem *)item;
- (void)downloadItem:(nonnull YMDownloadItem *)item downloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize;
- (void)downloadItem:(nonnull YMDownloadItem *)item speed:(NSUInteger)speed speedDesc:(NSString *)speedDesc;
@end


@interface YMDownloadItem : NSObject

- (nonnull instancetype)initWithUrl:(nonnull NSString *)url fileId:(nullable NSString *)fileId;
+ (nonnull instancetype)itemWithUrl:(nonnull NSString *)url fileId:(nullable NSString *)fileId;

@property (nonatomic, copy, nonnull) NSString *taskId;
@property (nonatomic, copy, readonly, nullable) NSString *fileId;
@property (nonatomic, copy, readonly, nonnull) NSString *downloadURL;
@property (nonatomic, copy, readonly, nonnull) NSString *version;

@property (nonatomic, assign, readonly) int64_t fileSize;
@property (nonatomic, assign, readonly) int64_t downloadedSize;

@property (nonatomic, weak, nullable) id <YMDownloadItemDelegate> delegate;

@property (nonatomic, assign) BOOL enableSpeed;//是否显示加载速度
@property (nonatomic, strong, nullable) NSData *extraData;
@property (nonatomic, assign, readwrite) YMDownloadStatus downloadStatus;

@property (nonatomic, copy, readonly, nullable) YMProgressHandler progressHandler;
@property (nonatomic, copy, readonly, nullable) YMCompletionHandler completionHandler;
/**
 下载的文件在沙盒保存的类型，默认为video.可指定为pdf，image，等自定义类型
 */
@property (nonatomic, copy, nullable) NSString *fileType;
@property (nonatomic, copy, nullable) NSString *uid;
@property (nonatomic, copy, nonnull) NSString *saveRootPath;
/**文件沙盒保存路径*/
@property (nonatomic, copy, readonly, nonnull) NSString *savePath;

@property (nonatomic, copy) YMDownloadStatusHandler downloadStatusHandler;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
