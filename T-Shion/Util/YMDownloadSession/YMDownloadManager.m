//
//  YMDownloadManager.m
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/5/5.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMDownloadManager.h"
#import "YMDownloadUtils.h"
#import "YMDownloader.h"
#import "YMDownloadItem.h"
#import "YMDownloadDB.h"
#import "YMDownLoadConfig.h"


#define YMDownloadMgr [YMDownloadManager manager]

@interface YMDownloader (Mgr)
- (void)endBGCompletedHandler;
@end

@interface YMDownloadItem (Mgr)
@property (nonatomic, assign) BOOL isRemoved;
@property (nonatomic, assign) BOOL noNeedStartNext;
@end

@interface YMDownloadManager ()
{
    NSString *_uniqueId;
}
@property (nonatomic, strong) NSMutableArray <YMDownloadItem *> *waitItems;
@property (nonatomic, strong) NSMutableArray <YMDownloadItem *> *runItems;
@property (nonatomic, strong) YMDownLoadConfig *config;
@end


@implementation YMDownloadManager

static id _instance;

+ (void)mgrWithConfig:(YMDownLoadConfig *)config {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        YMDownloadMgr.config = config;
        [YMDownloadMgr initManager];
    });
}

- (instancetype)init {
    if (self = [super init]) {
        [self addNotification];
        _runItems  = [NSMutableArray array];
        _waitItems = [NSMutableArray array];
    }
    return self;
}


+ (instancetype)manager {
    NSAssert(_instance, @"please set config: [YMDownloadManager mgrWithConfig:config];");
    return _instance;
}

- (void)initManager{
    [self setUid:self.config.uid];
    [YMDownloader downloader].taskCachekMode = self.config.taskCachekMode;
    [self restoreItems];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskFinishNoti:) name:kDownloadTaskFinishedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)restoreItems {
    [[YMDownloadDB fetchAllDownloadItemWithUid:self.uid] enumerateObjectsUsingBlock:^(YMDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self downloadFinishedWithItem:obj];
        YMDownloadTask *task = [self taskWithItem:obj];
        if (obj.downloadStatus == YMDownloadStatusDownloading || ( task.isRunning && self.config.launchAutoResumeDownload)) {
            obj.downloadStatus = YMDownloadStatusDownloading;
            task.completionHandler = obj.completionHandler;
            task.progressHandler = obj.progressHandler;
            if (task.state != NSURLSessionTaskStateRunning) {
                obj.downloadStatus = YMDownloadStatusPaused;
            }
            [self.runItems addObject:obj];
        }
        
        if (self.config.launchAutoResumeDownload) {
            if(obj.downloadStatus == YMDownloadStatusWaiting){
                [self.waitItems addObject:obj];
            }
        } else {
            if (obj.downloadStatus == YMDownloadStatusWaiting || obj.downloadStatus == YMDownloadStatusDownloading) {
                [self pauseDownloadWithItem:obj];
            }
        }
    }];
    if (self.config.launchAutoResumeDownload && self.waitItems.count>0) {
        [self resumeDownloadWithItem:self.waitItems.firstObject];
    }
    [YMDownloadDB saveAllData];
}

#pragma mark - Handler
- (void)appWillTerminate {
    [self pauseAllDownloadTask];
}

- (void)saveDownloadItem:(YMDownloadItem *)item {
    [YMDownloadDB saveItem:item];
}

- (void)downloadTaskFinishNoti:(NSNotification *)noti {
    YMDownloadItem *item = noti.object;
    [self.runItems removeObject:item];
    [self startNextDownload];
    if (self.runItems.count==0 && self.waitItems.count==0) {
        NSLog(@"[startNextDownload] all download task finished");
        [[YMDownloader downloader] endBGCompletedHandler];
    }
}

- (void)startNextDownload {
    YMDownloadItem *item = self.waitItems.firstObject;
    if (!item) return;
    [self.waitItems removeObject:item];
    [self resumeDownloadWithItem:item];
}

+ (int64_t)videoCacheSize {
    int64_t size = 0;
    NSArray *downloadList = [self downloadList];
    NSArray *finishList = [self finishList];
    for (YMDownloadTask *task in downloadList) {
        size += task.downloadedSize;
    }
    
    for (YMDownloadTask *task in finishList) {
        size += task.fileSize;
    }
    return size;
}

- (BOOL)canResumeDownload {
    return self.runItems.count<self.config.maxTaskCount;
}


#pragma mark - public
+ (void)updateUid:(NSString *)uid {
    [YMDownloadMgr setUid:uid];
}

+ (void)startDownloadWithUrl:(NSString *)downloadURLString{
    [self startDownloadWithUrl:downloadURLString fileId:nil priority:NSURLSessionTaskPriorityDefault extraData:nil];
}

+ (void)startDownloadWithUrl:(NSString *)downloadURLString fileId:(NSString *)fileId  priority:(float)priority extraData:(NSData *)extraData {
    [YMDownloadMgr startDownloadWithUrl:downloadURLString fileId:fileId priority:priority extraData:extraData];
}

+ (void)startDownloadWithItem:(YMDownloadItem *)item {
    [YMDownloadMgr startDownloadWithItem:item priority:NSURLSessionTaskPriorityDefault];
}

+ (void)startDownloadWithItem:(YMDownloadItem *)item priority:(float)priority {
    [YMDownloadMgr startDownloadWithItem:item priority:priority];
}

+ (void)pauseDownloadWithItem:(YMDownloadItem *)item {
    [YMDownloadMgr pauseDownloadWithItem:item];
}

+ (void)resumeDownloadWithItem:(YMDownloadItem *)item {
    [YMDownloadMgr resumeDownloadWithItem:item];
}

+ (void)stopDownloadWithItem:(YMDownloadItem *)item {
    [YMDownloadMgr stopDownloadWithItem:item];
}

+ (void)pauseAllDownloadTask {
    [YMDownloadMgr pauseAllDownloadTask];
}

+ (void)resumeAllDownloadTask {
    [YMDownloadMgr resumeAllDownloadTask];
}

+ (void)removeAllCache {
    [YMDownloadMgr removeAllCache];
}

+ (YMDownloadItem *)itemWithFileId:(NSString *)fid {
    return [YMDownloadMgr itemWithFileId:fid];
}

+ (NSArray *)itemsWithDownloadUrl:(NSString *)downloadUrl {
    return [YMDownloadMgr itemsWithDownloadUrl:downloadUrl];
}

+ (NSArray *)downloadList {
    return [YMDownloadDB fetchAllDownloadingItemWithUid:YMDownloadMgr.uid];
}

+ (NSArray *)finishList {
    return [YMDownloadDB fetchAllDownloadedItemWithUid:YMDownloadMgr.uid];
}



#pragma mark - 私有方法
- (void)startDownloadWithItem:(YMDownloadItem *)item priority:(float)priority {
    if(!item) return;
    YMDownloadItem *oldItem = [YMDownloadDB itemWithTaskId:item.taskId];
    if (oldItem && [self downloadFinishedWithItem:oldItem]) {
        NSLog(@"[startDownloadWithItem] detect item finished!");
        [self startNextDownload];
        return;
    }
    item.downloadStatus = YMDownloadStatusWaiting;
    item.uid = self.uid;
    item.saveRootPath = self.config.saveRootPath;
    item.fileType = item.fileType ? : @"video";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.downloadURL]];
    YMDownloadTask *task = [[YMDownloader downloader] downloadWithRequest:request progress:item.progressHandler completion:item.completionHandler priority:priority];
    item.taskId = task.taskId;
    [YMDownloadDB saveItem:item];
    [self resumeDownloadWithItem:item];
}

- (void)startDownloadWithUrl:(NSString *)downloadURLString fileId:(NSString *)fileId  priority:(float)priority extraData:(NSData *)extraData {
    YMDownloadItem *item = [YMDownloadItem itemWithUrl:downloadURLString fileId:fileId];
    item.extraData = extraData;
    [self startDownloadWithItem:item priority:priority];
}


- (BOOL)downloadFinishedWithItem:(YMDownloadItem *)item {
    int64_t localFileSize = [YMDownloadUtils ym_fileSizeWithPath:item.savePath];
    BOOL fileFinished = localFileSize>0 && localFileSize == item.fileSize;
    if (fileFinished) {
        [item setValue:@(localFileSize) forKey:@"_downloadedSize"];
        item.downloadStatus = YMDownloadStatusFinished;
        return true;
    }
    if (item.downloadStatus == YMDownloadStatusFinished){
        NSLog(@"[downloadFinishedWithItem] status finished to failed, reason: savePath error! %@", item.savePath);
        item.downloadStatus = YMDownloadStatusFailed;
    }
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:item.savePath]) {
//        //注意：加密图片已存在不能删除
//        if (item.extraData.length > 0 && item.extraData) {
//            NSDictionary *msgDict = [item.extraData mj_JSONObject];
//            MessageModel *msgModel = [MessageModel mj_objectWithKeyValues:msgDict];
//            if (msgModel.messageId.length > 0) {
//                return true;
//            }
////            if (msgModel.isCryptoMessage && msgModel.msgType == MESSAGE_IMAGE) {
////                return true;
////            }
//        }
//        [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
//    }
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:item.savePath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
//    }
    return false;
}

- (YMDownloadTask *)taskWithItem:(YMDownloadItem *)item {
    NSAssert(item.taskId, @"item taskid not nil");
    YMDownloadTask *task = nil;
    task = [YMDownloadDB taskWithTid:item.taskId];
    return task;
}

- (YMDownloadItem *)itemWithTaskId:(NSString *)taskId {
    return [YMDownloadDB itemWithTaskId:taskId];
}

- (void)removeItemWithTaskId:(NSString *)taskId {
    [YMDownloadDB removeItemWithTaskId:taskId];
}

- (void)resumeDownloadWithItem:(YMDownloadItem *)item{
    if ([self downloadFinishedWithItem:item]) {
        NSLog(@"[resumeDownloadWithItem] detect item finished : %@", item);
        [self startNextDownload];
        return;
    }
    if (![self canResumeDownload]) {
        item.downloadStatus = YMDownloadStatusWaiting;
        [self.waitItems addObject:item];
        return;
    }
    item.downloadStatus = YMDownloadStatusDownloading;
    YMDownloadTask *task = [self taskWithItem:item];
    task.completionHandler = item.completionHandler;
    task.progressHandler = item.progressHandler;
    if([[YMDownloader downloader] resumeTask:task]) {
        [self.runItems addObject:item];
        return;
    }
    //[self startDownloadWithItem:item priority:task.priority];
}

- (void)pauseDownloadWithItem:(YMDownloadItem *)item {
    item.downloadStatus = YMDownloadStatusPaused;
    YMDownloadTask *task = [self taskWithItem:item];
    [[YMDownloader downloader] pauseTask:task];
    [self saveDownloadItem:item];
    [self.runItems removeObject:item];
    [self.waitItems removeObject:item];
    if(!item.noNeedStartNext) [self startNextDownload];
}

- (void)stopDownloadWithItem:(YMDownloadItem *)item {
    if (item == nil)  return;
    item.isRemoved = true;
    YMDownloadTask *task  = [self taskWithItem:item];
    [[YMDownloader downloader] cancelTask:task];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:item.savePath];
    NSLog(@"[remove item] isExist : %d path: %@", isExist, item.savePath);
//    [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
    //注意：加密图片已存在不能删除
//    if (isExist) {
//        if (item.extraData.length > 0 && item.extraData) {
//            NSDictionary *msgDict = [item.extraData mj_JSONObject];
//            MessageModel *msgModel = [MessageModel mj_objectWithKeyValues:msgDict];
//            if (msgModel.messageId.length == 0) {
//                [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
//            }
//        } else {
//            [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
//        }
//    } else {
//        [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
//    }

    [self removeItemWithTaskId:item.taskId];
    [YMDownloadDB removeTask:task];
    [self.runItems removeObject:item];
    [self.waitItems removeObject:item];
    if(!item.noNeedStartNext) [self startNextDownload];
}

- (void)pauseAllDownloadTask {
    [[YMDownloadDB fetchAllDownloadingItemWithUid:self.uid] enumerateObjectsUsingBlock:^(YMDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadStatus == YMDownloadStatusWaiting || obj.downloadStatus == YMDownloadStatusDownloading) {
            obj.noNeedStartNext = true;
            [self pauseDownloadWithItem:obj];
        }
    }];
}

- (void)removeAllCache {
    [[YMDownloadDB fetchAllDownloadItemWithUid:self.uid] enumerateObjectsUsingBlock:^(YMDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.noNeedStartNext = true;
        [self stopDownloadWithItem:obj];
    }];
}

- (void)resumeAllDownloadTask{
    NSArray <YMDownloadItem *> *downloading = [YMDownloadDB fetchAllDownloadingItemWithUid:self.uid];
    [downloading enumerateObjectsUsingBlock:^(YMDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.downloadStatus == YMDownloadStatusPaused || item.downloadStatus == YMDownloadStatusFailed) {
            [self resumeDownloadWithItem:item];
        }
    }];
    [YMDownloadDB saveAllData];
}

- (void)allowsCellularAccess:(BOOL)isAllow {
    [YMDownloader downloader].allowsCellularAccess = isAllow;
}

- (BOOL)isAllowsCellularAccess {
    return [YMDownloader downloader].allowsCellularAccess;
}

- (YMDownloadItem *)itemWithFileId:(NSString *)fid {
    return [YMDownloadDB itemWithFid:fid uid:self.uid];
}

- (NSArray *)itemsWithDownloadUrl:(NSString *)downloadUrl {
    return [YMDownloadDB itemsWithUrl:downloadUrl uid:self.uid];
}



#pragma mark - setter or getter
+ (BOOL)isAllowsCellularAccess {
    return [YMDownloadMgr isAllowsCellularAccess];
}

+ (void)allowsCellularAccess:(BOOL)isAllow {
    [YMDownloadMgr allowsCellularAccess:isAllow];
}

- (void)setUid:(NSString *)uid {
    if ([_uniqueId isEqualToString:uid]) return;
    [self pauseAllDownloadTask];
    _uniqueId = uid;
}

- (NSString *)uid {
    return _uniqueId ? : @"YMDownloadUID";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
