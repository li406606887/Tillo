//
//  YMVideoDownloadManager.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/4.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "YMVideoDownloadManager.h"
#import "YMDownloadUtils.h"
#import "YMVideoDownloader.h"
#import "YMDownloadItem.h"
#import "YMVideoDownloadDB.h"
#import "YMDownLoadConfig.h"


#define YMVideoDownloadMgr [YMVideoDownloadManager manager]

@interface YMVideoDownloader (Mgr)
- (void)endBGCompletedHandler;
@end

@interface YMDownloadItem (Mgr)
@property (nonatomic, assign) BOOL isRemoved;
@property (nonatomic, assign) BOOL noNeedStartNext;
@end

@interface YMVideoDownloadManager ()
{
    NSString *_uniqueId;
}
@property (nonatomic, strong) NSMutableArray <YMDownloadItem *> *waitItems;
@property (nonatomic, strong) NSMutableArray <YMDownloadItem *> *runItems;
@property (nonatomic, strong) YMDownLoadConfig *config;
@end



@implementation YMVideoDownloadManager

static id _instance;

+ (void)mgrWithConfig:(YMDownLoadConfig *)config {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        YMVideoDownloadMgr.config = config;
        [YMVideoDownloadMgr initManager];
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
    NSAssert(_instance, @"please set config: [YMVideoDownloader mgrWithConfig:config];");
    return _instance;
}

- (void)initManager{
    [self setUid:self.config.uid];
    [YMVideoDownloader downloader].taskCachekMode = self.config.taskCachekMode;
    [self restoreItems];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskFinishNoti:) name:kDownloadTaskFinishedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)restoreItems {
    [[YMVideoDownloadDB fetchAllDownloadItemWithUid:self.uid] enumerateObjectsUsingBlock:^(YMDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [YMVideoDownloadDB saveAllData];
}

#pragma mark - Handler
- (void)appWillTerminate {
    [self pauseAllDownloadTask];
}

- (void)saveDownloadItem:(YMDownloadItem *)item {
    [YMVideoDownloadDB saveItem:item];
}

- (void)downloadTaskFinishNoti:(NSNotification *)noti {
    YMDownloadItem *item = noti.object;
    [self.runItems removeObject:item];
    [self startNextDownload];
    if (self.runItems.count==0 && self.waitItems.count==0) {
        NSLog(@"[startNextDownload] all download task finished");
        [[YMVideoDownloader downloader] endBGCompletedHandler];
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
    [YMVideoDownloadMgr setUid:uid];
}

+ (void)startDownloadWithUrl:(NSString *)downloadURLString{
    [self startDownloadWithUrl:downloadURLString fileId:nil priority:NSURLSessionTaskPriorityDefault extraData:nil];
}

+ (void)startDownloadWithUrl:(NSString *)downloadURLString fileId:(NSString *)fileId  priority:(float)priority extraData:(NSData *)extraData {
    [YMVideoDownloadMgr startDownloadWithUrl:downloadURLString fileId:fileId priority:priority extraData:extraData];
}

+ (void)startDownloadWithItem:(YMDownloadItem *)item {
    [YMVideoDownloadMgr startDownloadWithItem:item priority:NSURLSessionTaskPriorityDefault];
}

+ (void)startDownloadWithItem:(YMDownloadItem *)item priority:(float)priority {
    [YMVideoDownloadMgr startDownloadWithItem:item priority:priority];
}

+ (void)pauseDownloadWithItem:(YMDownloadItem *)item {
    [YMVideoDownloadMgr pauseDownloadWithItem:item];
}

+ (void)resumeDownloadWithItem:(YMDownloadItem *)item {
    [YMVideoDownloadMgr resumeDownloadWithItem:item];
}

+ (void)stopDownloadWithItem:(YMDownloadItem *)item {
    [YMVideoDownloadMgr stopDownloadWithItem:item];
}

+ (void)pauseAllDownloadTask {
    [YMVideoDownloadMgr pauseAllDownloadTask];
}

+ (void)resumeAllDownloadTask {
    [YMVideoDownloadMgr resumeAllDownloadTask];
}

+ (void)removeAllCache {
    [YMVideoDownloadMgr removeAllCache];
}

+ (YMDownloadItem *)itemWithFileId:(NSString *)fid {
    return [YMVideoDownloadMgr itemWithFileId:fid];
}

+ (NSArray *)itemsWithDownloadUrl:(NSString *)downloadUrl {
    return [YMVideoDownloadMgr itemsWithDownloadUrl:downloadUrl];
}

+ (NSArray *)downloadList {
    return [YMVideoDownloadDB fetchAllDownloadingItemWithUid:YMVideoDownloadMgr.uid];
}

+ (NSArray *)finishList {
    return [YMVideoDownloadDB fetchAllDownloadedItemWithUid:YMVideoDownloadMgr.uid];
}



#pragma mark - 私有方法
- (void)startDownloadWithItem:(YMDownloadItem *)item priority:(float)priority {
    if(!item) return;
    YMDownloadItem *oldItem = [YMVideoDownloadDB itemWithTaskId:item.taskId];
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
    YMDownloadTask *task = [[YMVideoDownloader downloader] downloadWithRequest:request progress:item.progressHandler completion:item.completionHandler priority:priority];
    item.taskId = task.taskId;
    [YMVideoDownloadDB saveItem:item];
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
//        //注意:视频已存在不能删除
//        if (item.extraData.length > 0 && item.extraData) {
//            NSDictionary *msgDict = [item.extraData mj_JSONObject];
//            MessageModel *msgModel = [MessageModel mj_objectWithKeyValues:msgDict];
//            if (msgModel.messageId.length > 0) {
//                return true;
//            }
//
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
    task = [YMVideoDownloadDB taskWithTid:item.taskId];
    return task;
}

- (YMDownloadItem *)itemWithTaskId:(NSString *)taskId {
    return [YMVideoDownloadDB itemWithTaskId:taskId];
}

- (void)removeItemWithTaskId:(NSString *)taskId {
    [YMVideoDownloadDB removeItemWithTaskId:taskId];
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
    
    if([[YMVideoDownloader downloader] resumeTask:task]) {
        [self.runItems addObject:item];
        return;
    }
    
    [self startDownloadWithItem:item priority:task.priority];
}

- (void)pauseDownloadWithItem:(YMDownloadItem *)item {
    item.downloadStatus = YMDownloadStatusPaused;
    YMDownloadTask *task = [self taskWithItem:item];
    [[YMVideoDownloader downloader] pauseTask:task];
    [self saveDownloadItem:item];
    [self.runItems removeObject:item];
    [self.waitItems removeObject:item];
    if(!item.noNeedStartNext) [self startNextDownload];
}

- (void)stopDownloadWithItem:(YMDownloadItem *)item {
    if (item == nil)  return;
    item.isRemoved = true;
    YMDownloadTask *task  = [self taskWithItem:item];
    [[YMVideoDownloader downloader] cancelTask:task];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:item.savePath];
    NSLog(@"[remove item] isExist : %d path: %@", isExist, item.savePath);
    
    //注意：加密图片已存在不能删除
    if (isExist) {
        if (item.extraData.length > 0 && item.extraData) {
            NSDictionary *msgDict = [item.extraData mj_JSONObject];
            MessageModel *msgModel = [MessageModel mj_objectWithKeyValues:msgDict];
            
            if (msgModel.messageId.length == 0) {
                [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
            }
            
//            if (msgModel.msgType == MESSAGE_Video) {
//                
//            } else {
//                [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
//            }
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
        }
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
    }
    
//    [[NSFileManager defaultManager] removeItemAtPath:item.savePath error:nil];
    [self removeItemWithTaskId:item.taskId];
    [YMVideoDownloadDB removeTask:task];
    [self.runItems removeObject:item];
    [self.waitItems removeObject:item];
    if(!item.noNeedStartNext) [self startNextDownload];
}

- (void)pauseAllDownloadTask {
    [[YMVideoDownloadDB fetchAllDownloadingItemWithUid:self.uid] enumerateObjectsUsingBlock:^(YMDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.downloadStatus == YMDownloadStatusWaiting || obj.downloadStatus == YMDownloadStatusDownloading) {
            obj.noNeedStartNext = true;
            [self pauseDownloadWithItem:obj];
        }
    }];
}

- (void)removeAllCache {
    [[YMVideoDownloadDB fetchAllDownloadItemWithUid:self.uid] enumerateObjectsUsingBlock:^(YMDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.noNeedStartNext = true;
        [self stopDownloadWithItem:obj];
    }];
}

- (void)resumeAllDownloadTask{
    NSArray <YMDownloadItem *> *downloading = [YMVideoDownloadDB fetchAllDownloadingItemWithUid:self.uid];
    [downloading enumerateObjectsUsingBlock:^(YMDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.downloadStatus == YMDownloadStatusPaused || item.downloadStatus == YMDownloadStatusFailed) {
            [self resumeDownloadWithItem:item];
        }
    }];
    [YMVideoDownloadDB saveAllData];
}

- (void)allowsCellularAccess:(BOOL)isAllow {
    [YMVideoDownloader downloader].allowsCellularAccess = isAllow;
}

- (BOOL)isAllowsCellularAccess {
    return [YMVideoDownloader downloader].allowsCellularAccess;
}

- (YMDownloadItem *)itemWithFileId:(NSString *)fid {
    return [YMVideoDownloadDB itemWithFid:fid uid:self.uid];
}

- (NSArray *)itemsWithDownloadUrl:(NSString *)downloadUrl {
    return [YMVideoDownloadDB itemsWithUrl:downloadUrl uid:self.uid];
}



#pragma mark - setter or getter
+ (BOOL)isAllowsCellularAccess {
    return [YMVideoDownloadMgr isAllowsCellularAccess];
}

+ (void)allowsCellularAccess:(BOOL)isAllow {
    [YMVideoDownloadMgr allowsCellularAccess:isAllow];
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
