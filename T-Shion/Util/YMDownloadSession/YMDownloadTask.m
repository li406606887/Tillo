//
//  YMDownloadTask.m
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/4/30.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMDownloadTask.h"
#import "YMDownloadUtils.h"

@interface YMDownloadTask()
@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, assign) NSInteger stid;
@property (nonatomic, copy) NSString *tmpName;
@property (nonatomic, assign) BOOL needToRestart;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign, readonly) BOOL isFinished;
@property (nonatomic, assign, readonly) BOOL isSupportRange;
@property (nonatomic, assign, readonly) NSUInteger createTime;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign) BOOL isDeleted;
@end


@implementation YMDownloadTask

@synthesize progress = _progress;

- (instancetype)init {
    if (self = [super init]) {
        _createTime = [YMDownloadUtils sec_timestamp];
        _version = [YMDownloadTask downloaderVerison];
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion priority:(float)priority {
    if (self = [super init]) {
        NSString *url = request.URL.absoluteString;
        _request = request;
        _downloadURL = url;
        _taskId = [YMDownloadTask taskIdForUrl:url fileId:[NSUUID UUID].UUIDString];
        _priority = priority ? priority : NSURLSessionTaskPriorityDefault;
        _progressHandler = progress;
        _completionHandler = completion;
        _createTime = [YMDownloadUtils sec_timestamp];
        _version = [YMDownloadTask downloaderVerison];
    }
    return self;
}

+ (instancetype)taskWithDict:(NSMutableDictionary *)dict {
    YMDownloadTask *task = [[self alloc] init];
    [task setValuesForKeysWithDictionary:dict];
    return task;
}

+ (instancetype)taskWithRequest:(NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion {
    return [[self alloc] initWithRequest:request progress:progress completion:completion priority:0];
}

+ (instancetype)taskWithRequest:(NSURLRequest *)request progress:(YMProgressHandler)progress completion:(YMCompletionHandler)completion priority:(float)priority {
    return [[self alloc] initWithRequest:request progress:progress completion:completion priority:priority];
}

#pragma mark - public
- (void)updateTask {
    _fileSize = [_downloadTask.response expectedContentLength];
}

#pragma mark - setter
- (void)setDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    NSAssert(downloadTask == nil || [downloadTask isKindOfClass:[NSURLSessionDownloadTask class]], @"downloadTask class", downloadTask.class);
    
    _downloadTask = downloadTask;
    downloadTask.priority = self.priority;
    
}

#pragma mark - getter
- (NSURLSessionTaskState)state {
    return self.downloadTask ? self.downloadTask.state : -1;
}

- (NSProgress *)progress {
    if (!_progress) {
        _progress = [NSProgress progressWithTotalUnitCount:NSURLSessionTransferSizeUnknown];
    }
    return _progress;
}

- (BOOL)isSupportRange {
    if ([self.downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.downloadTask.response;
        NSString *rangeHeader = [response.allHeaderFields valueForKey:@"Accept-Ranges"];
        NSString *etag = [response.allHeaderFields valueForKey:@"ETag"];
        return rangeHeader.length>0 && etag.length>0;
    }
    return YES;
}

- (BOOL)isRunning {
    return self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning;
}

- (NSInteger)stid {
    return self.downloadTask ? self.downloadTask.taskIdentifier : _stid;
}

- (BOOL)isFinished {
    return self.fileSize != 0 && self.fileSize == self.downloadedSize;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<YMDownloadTask: %p>{ taskId: %@, url: %@, stid: %ld}", self, self.taskId, self.downloadURL, (long)self.stid];
}

+ (NSString *)taskIdForUrl:(NSString *)url fileId:(NSString *)fileId {
    NSString *name = [YMDownloadUtils ym_md5ForString:fileId.length>0 ? [NSString stringWithFormat:@"%@-%@",url, fileId] : url];
    return name;
}

+ (NSString *)downloaderVerison {
    return @"1.0.0";
}

@end

#pragma mark -- YMResumeData implementation

static NSString * const kNSURLSessionDownloadURL = @"NSURLSessionDownloadURL";
static NSString * const kNSURLSessionResumeInfoTempFileName = @"NSURLSessionResumeInfoTempFileName";
static NSString * const kNSURLSessionResumeBytesReceived = @"NSURLSessionResumeBytesReceived";
static NSString * const kNSURLSessionResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
static NSString * const kNSURLSessionResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
static NSString * const kNSURLSessionResumeEntityTag = @"NSURLSessionResumeEntityTag";
static NSString * const kNSURLSessionResumeByteRange = @"NSURLSessionResumeByteRange";
static NSString * const kNSURLSessionResumeInfoVersion = @"NSURLSessionResumeInfoVersion";
static NSString * const kNSURLSessionResumeServerDownloadDate = @"NSURLSessionResumeServerDownloadDate";

@interface YMResumeData()

@end

@implementation YMResumeData

- (instancetype)initWithResumeData:(NSData *)resumeData {
    if (self = [super init]) {
        [self decodeResumeData:resumeData];
    }
    return self;
}

- (void)decodeResumeData:(NSData *)resumeData {
    
    //将 list 对象转为 NSData
    id resumeDataObj = [NSPropertyListSerialization propertyListWithData:resumeData options:0 format:0 error:nil];
    if ([resumeDataObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *resumeDict = resumeDataObj;
        NSString *downloadUrl = [resumeDict valueForKey:kNSURLSessionDownloadURL];
        NSString *tempName = [resumeDict valueForKey:kNSURLSessionResumeInfoTempFileName];
        NSNumber *downloadSize = [resumeDict valueForKey:kNSURLSessionResumeBytesReceived];
        NSData *currentReqData = [resumeDict valueForKey:kNSURLSessionResumeCurrentRequest];
        NSData *originalReqData = [resumeDict valueForKey:kNSURLSessionResumeOriginalRequest];
        NSString *resumeTag = [resumeDict valueForKey:kNSURLSessionResumeEntityTag];
        NSString *resumeRange = [resumeDict valueForKey:kNSURLSessionResumeByteRange];
        NSNumber *resumeInfoVersion = [resumeDict valueForKey:kNSURLSessionResumeInfoVersion];
        NSString *downloadDate = [resumeDict valueForKey:kNSURLSessionResumeServerDownloadDate];
        
        
        _downloadUrl = downloadUrl;
        _tempName = tempName;
        _downloadSize = downloadSize.integerValue;
        _resumeTag = resumeTag;
        _resumeRange = resumeRange;
        _resumeInfoVersion = resumeInfoVersion.integerValue;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        _downloadDate = [formatter dateFromString:downloadDate];
        
        [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
        [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData];
    }
}

+ (NSData *)correctRequestData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",(long)k]] != nil) {
        k += 1;
    }
    NSInteger i = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",(long)(i+k)]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
        i++;
    }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",(long)(i+k)]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

+ (NSMutableDictionary *)getResumeDictionary:(NSData *)data
{
    NSMutableDictionary *iresumeDictionary = nil;
    if (YM_DEVICE_VERSION >= 10) {
        id root = nil;
        id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            if (@available(iOS 9.0, *)) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
            } else {
                root = [keyedUnarchiver decodeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
            }
            if (root == nil) {
                if (@available(iOS 9.0, *)) {
                    root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
                } else {
                    root = [keyedUnarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
                }
            }
        } @catch(NSException *exception) {
            
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = [root mutableCopy];
    }
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    return iresumeDictionary;
}

+ (NSData *)correctResumeData:(NSData *)data
{
    if (YM_DEVICE_VERSION >= 11.2) {
        return data;
    }
    NSString *kResumeCurrentRequest = kNSURLSessionResumeCurrentRequest;
    NSString *kResumeOriginalRequest = kNSURLSessionResumeOriginalRequest;
    if (data == nil) {
        return  nil;
    }
    NSMutableDictionary *resumeDictionary = [YMResumeData getResumeDictionary:data];
    if (resumeDictionary == nil) {
        return nil;
    }
    resumeDictionary[kResumeCurrentRequest] =  [YMResumeData correctRequestData: resumeDictionary[kResumeCurrentRequest]];
    resumeDictionary[kResumeOriginalRequest] = [YMResumeData correctRequestData:resumeDictionary[kResumeOriginalRequest]];
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}


+ (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData urlSession:(NSURLSession *)urlSession {
    NSString *kResumeCurrentRequest = kNSURLSessionResumeCurrentRequest;
    NSString *kResumeOriginalRequest = kNSURLSessionResumeOriginalRequest;
    
    NSData *cData = [YMResumeData correctResumeData:resumeData];
    cData = cData ? cData:resumeData;
    NSURLSessionDownloadTask *task = [urlSession downloadTaskWithResumeData:cData];
    NSMutableDictionary *resumeDic = [YMResumeData getResumeDictionary:cData];
    if (resumeDic) {
        if (task.originalRequest == nil) {
            NSData *originalReqData = resumeDic[kResumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData ];
            if (originalRequest) {
                [task setValue:originalRequest forKey:@"originalRequest"];
            }
        }
        if (task.currentRequest == nil) {
            NSData *currentReqData = resumeDic[kResumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest) {
                [task setValue:currentRequest forKey:@"currentRequest"];
            }
        }
    }
    return task;
}

+ (NSData *)cleanResumeData:(NSData *)resumeData {
    NSString *dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
    if ([dataString containsString:@"<key>NSURLSessionResumeByteRange</key>"]) {
        NSRange rangeKey = [dataString rangeOfString:@"<key>NSURLSessionResumeByteRange</key>"];
        NSString *headStr = [dataString substringToIndex:rangeKey.location];
        NSString *backStr = [dataString substringFromIndex:rangeKey.location];
        
        NSRange rangeValue = [backStr rangeOfString:@"</string>\n\t"];
        NSString *tailStr = [backStr substringFromIndex:rangeValue.location + rangeValue.length];
        dataString = [headStr stringByAppendingString:tailStr];
    }
    return [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
