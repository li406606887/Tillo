//
//  YMDownloadItem.m
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/5/5.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMDownloadItem.h"
#import "YMDownloadUtils.h"
#import "YMDownloadDB.h"
#import "YMEncryptionManager.h"

NSString * const kDownloadTaskFinishedNoti = @"kDownloadTaskFinishedNoti";
NSString * const kFinishDownloadCryptoImageNoti = @"kFinishDownloadCryptoImageNoti";


@interface YMDownloadTask(YMDownloader)
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@end


@interface YMDownloadItem ()
@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, assign) BOOL isRemoved;
@property (nonatomic, assign) BOOL noNeedStartNext;
@property (nonatomic, copy) NSString *fileExtension;
@property (nonatomic, assign, readonly) NSUInteger createTime;
@property (nonatomic, assign) uint64_t preDSize;
@property (nonatomic, strong) NSTimer *speedTimer;


@end

@implementation YMDownloadItem

- (instancetype)initWithPrivate{
    if (self = [super init]) {
        _createTime = [YMDownloadUtils sec_timestamp];
        _version = [YMDownloadTask downloaderVerison];
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)url fileId:(NSString *)fileId {
    if (self = [self initWithPrivate]) {
        _downloadURL = url;
        _fileId = fileId;
    }
    return self;
}

+ (instancetype)itemWithDict:(NSDictionary *)dict {
    YMDownloadItem *item = [[YMDownloadItem alloc] initWithPrivate];
    [item setValuesForKeysWithDictionary:dict];
    return item;
}

+ (instancetype)itemWithUrl:(NSString *)url fileId:(NSString *)fileId {
    return [[YMDownloadItem alloc] initWithUrl:url fileId:fileId];
}

#pragma mark - Handler
- (void)downloadProgress:(YMDownloadTask *)task downloadedSize:(int64_t)downloadedSize fileSize:(int64_t)fileSize {
    if (_fileSize == 0) _fileSize = fileSize;
    if (!self.fileExtension) [self setFileExtensionWithTask:task];
    _downloadedSize = downloadedSize;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadItem:downloadedSize:totalSize:)]) {
        [self.delegate downloadItem:self downloadedSize:downloadedSize totalSize:fileSize];
    }
}

- (void)downloadStatusChanged:(YMDownloadStatus)status downloadTask:(YMDownloadTask *)task {
    _downloadStatus = status;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadItemStatusChanged:)]) {
        [self.delegate downloadItemStatusChanged:self];
    }
    
    if (self.downloadStatusHandler) {
        self.downloadStatusHandler(@(self.downloadStatus));
    }
    
    //通知优先级最后，不与上面的finished重合
    if (status == YMDownloadStatusFinished || status == YMDownloadStatusFailed) {
        [YMDownloadDB saveItem:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadTaskFinishedNoti object:self];
    }
    
    [self calculaterSpeedWithStatus:status];
}

- (void)speedTimerRun {
    uint64_t size = self.downloadedSize> self.preDSize ? self.downloadedSize - self.preDSize : 0;
    if (size == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadItem:speed:speedDesc:)]) {
            [self.delegate downloadItem:self speed:0 speedDesc:@"0KB/s"];
        }
        
    }else{
        NSString *ss = [NSString stringWithFormat:@"%@/s",[YMDownloadUtils ym_fileSizeStringFromBytes:size]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadItem:speed:speedDesc:)]) {
            [self.delegate downloadItem:self speed:size speedDesc:ss];
        }
//        [self.delegate downloadItem:self speed:size speedDesc:ss];
    }
    self.preDSize = self.downloadedSize;
    //NSLog(@"[speedTimerRun] %@ dsize: %llu pdsize: %llu", ss, self.downloadedSize, self.preDownloadedSize);
}

- (void)invalidateSpeedTimer {
    [self.speedTimer invalidate];
    self.speedTimer = nil;
}

- (void)calculaterSpeedWithStatus:(YMDownloadStatus)status {
    //计算下载速度
    if (!self.enableSpeed) return;
    if (status != YMDownloadStatusDownloading) {
        [self invalidateSpeedTimer];
        [self.delegate downloadItem:self speed:0 speedDesc:@"0KB/s"];
    }else{
        [self.speedTimer fire];
    }
}


#pragma mark - getter & setter
- (void)setDownloadStatus:(YMDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if ([self.delegate respondsToSelector:@selector(downloadItemStatusChanged:)]) {
        [self.delegate downloadItemStatusChanged:self];
    }
    [self calculaterSpeedWithStatus:downloadStatus];
}

- (void)setSaveRootPath:(NSString *)saveRootPath {
    NSString *path = [saveRootPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""];
    _rootPath = path;
}

- (NSString *)saveRootPath {
    NSString *rootPath = self.rootPath;
    if(!rootPath){
        rootPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject;
        rootPath = [rootPath stringByAppendingPathComponent:@"YMDownload"];
    }else{
        rootPath = [NSHomeDirectory() stringByAppendingPathComponent:rootPath];
    }
    return rootPath;
}


- (void)setFileExtensionWithTask:(YMDownloadTask *)task {
    NSURLResponse *oriResponse =task.downloadTask.response;
    if ([oriResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)oriResponse;
        NSString *extension = [[response.allHeaderFields valueForKey:@"Content-Type"] componentsSeparatedByString:@"/"].lastObject;
        if ([extension containsString:@";"]) {
            extension = [extension componentsSeparatedByString:@";"].firstObject;
        }
        if(extension.length==0) extension = response.suggestedFilename.pathExtension;
        _fileExtension = extension;
    }else{
        NSLog(@"[warning] downloadTask response class type error: %@", oriResponse);
    }
}

- (YMProgressHandler)progressHandler {
    __weak typeof(self) weakSelf = self;
    return ^(NSProgress *progress, YMDownloadTask *task){
        if(weakSelf.downloadStatus == YMDownloadStatusWaiting){
            [weakSelf downloadStatusChanged:YMDownloadStatusDownloading downloadTask:nil];
        }
        [weakSelf downloadProgress:task downloadedSize:progress.completedUnitCount fileSize:(progress.totalUnitCount>0 ? progress.totalUnitCount : 0)];
    };
}

- (YMCompletionHandler)completionHandler {
    __weak typeof(self) weakSelf = self;
    return ^(NSString *localPath, NSError *error){
        YMDownloadTask *task = [YMDownloadDB taskWithTid:self.taskId];
        if (error) {
            NSLog(@"[Item completionHandler] error : %@", error);
            [weakSelf downloadStatusChanged:YMDownloadStatusFailed downloadTask:nil];
            if(!weakSelf.isRemoved) [YMDownloadDB saveItem:weakSelf];
            return ;
        }
        
        // bg completion ,maybe had no extension
        if (!self.fileExtension) [self setFileExtensionWithTask:task];
        NSError *saveError = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:self.savePath]){
            if (self.extraData.length > 0 && self.extraData) {
                return;
            }
            NSLog(@"[Item completionHandler] Warning file Exist at path: %@ and replaced it!", weakSelf.savePath);
            [[NSFileManager defaultManager] removeItemAtPath:self.savePath error:nil];
        }
        
        //如果是aillo的消息
        if (self.extraData.length > 0 && self.extraData) {
            NSDictionary *msgDict = [self.extraData mj_JSONObject];
            MessageModel *msgModel = [MessageModel mj_objectWithKeyValues:msgDict];
            if (msgModel.messageId.length == 0) return;
            if (![msgModel.messageId isEqualToString:self.fileId]) return;
            
            if([[NSFileManager defaultManager] moveItemAtPath:localPath toPath:self.savePath error:&saveError]){
                
                if (![msgModel.messageId isEqualToString:self.fileId]) return;
                NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
                if (msgModel.isCryptoMessage) {
                    NSData *olddDta = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                    NSData *newData = nil;
                    if (msgModel.fileKey.length > 0) {
                        newData = [[YMEncryptionManager shareManager] decryptAttachment:olddDta withKey:msgModel.fileKey];
                    } else {
                        newData = [[YMEncryptionManager shareManager] decryptData:olddDta cryptoType:msgModel.cryptoType withUserID:msgModel.sender needBase64:NO];
                    }
                    
                    if (newData.length > 0) {
                        if ([newData isKindOfClass:[NSString class]]) {
                            NSLog(@"---------解密失败");
                        }
                        [newData writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
                    } else {
                        NSLog(@"---------解密失败");
                    }
                    
                    [FMDBManager updateFileNameWithMessageModel:msgModel];
                }
                    
                if (!self.fileExtension) {
                    self.fileExtension = @"png";
                }
                NSAssert(self.fileExtension, @"file extension can not nil!");
                int64_t fileSize = [YMDownloadUtils ym_fileSizeWithPath:weakSelf.savePath];
                self->_downloadedSize = fileSize;
                self->_fileSize = fileSize;
                [weakSelf downloadStatusChanged:YMDownloadStatusFinished downloadTask:nil];
            } else {
                [weakSelf downloadStatusChanged:YMDownloadStatusFailed downloadTask:nil];
                NSLog(@"[Item completionHandler] move file failed error: %@ \nlocalPath: %@ \nsavePath:%@", saveError,localPath,self.savePath);
            }
        } else {
            if([[NSFileManager defaultManager] moveItemAtPath:localPath toPath:self.savePath error:&saveError]){
                NSAssert(self.fileExtension, @"file extension can not nil!");
                int64_t fileSize = [YMDownloadUtils ym_fileSizeWithPath:weakSelf.savePath];
                self->_downloadedSize = fileSize;
                self->_fileSize = fileSize;
                [weakSelf downloadStatusChanged:YMDownloadStatusFinished downloadTask:nil];
            }else{
                [weakSelf downloadStatusChanged:YMDownloadStatusFailed downloadTask:nil];
                NSLog(@"[Item completionHandler] move file failed error: %@ \nlocalPath: %@ \nsavePath:%@", saveError,localPath,self.savePath);
            }
        }
    };
}

- (NSTimer *)speedTimer {
    if (!_speedTimer) {
        _speedTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speedTimerRun) userInfo:nil repeats:true];
    }
    return _speedTimer;
}

#pragma mark - public

- (NSString *)compatibleKey {
    return [YMDownloadTask downloaderVerison];
}

- (NSString *)saveUidDirectory {
    return [[self saveRootPath] stringByAppendingPathComponent:self.uid];
}

- (NSString *)saveDirectory {
    NSString *path = [self saveUidDirectory];
    path = [path stringByAppendingPathComponent:(self.fileType ? self.fileType : @"data")];
    [YMDownloadUtils ym_createPathIfNotExist:path];
    return path;
}

- (NSString *)saveName {
    NSString *saveName = self.fileId ? self.fileId : self.taskId;
    return [saveName stringByAppendingPathExtension: self.fileExtension.length>0 ? self.fileExtension : @"data"];
}

- (NSString *)savePath {
    if (self.extraData.length > 0 && self.extraData) {
        NSDictionary *msgDict = [self.extraData mj_JSONObject];
        MessageModel *msgModel = [MessageModel mj_objectWithKeyValues:msgDict];
        
        if (msgModel.messageId.length > 0) {
            NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
            return filePath;
        }
    }
    
    return [[self saveDirectory] stringByAppendingPathComponent:[self saveName]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<YMDownloadTask: %p>{taskId: %@, url: %@ fileId: %@}", self, self.taskId, self.downloadURL, self.fileId];
}

-(void)dealloc {
    [self invalidateSpeedTimer];
}

@end
