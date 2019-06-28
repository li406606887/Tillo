//
//  YMVideoBrowseCellData.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/20.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMVideoBrowseCellData.h"
#import "YMVideoBrowseCellData+Internal.h"
#import "YMVideoBrowseCell.h"
#import "YMIBPhotoAlbumManager.h"
#import "YMIBUtilities.h"
#import "YMIBLayoutDirectionManager.h"

#import "YMEncryptionManager.h"
#import "YMDownloadSession.h"

#import "YMDownSettingManager.h"

#import "TSImageHandler.h"

@interface YMVideoBrowseCellData () <NSURLSessionDelegate,YMDownloadItemDelegate> {
    NSURLSessionDownloadTask *_downloadTask;
}
@property (nonatomic, assign) BOOL loading;
@end

@implementation YMVideoBrowseCellData

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initVars];
    }
    return self;
}

- (void)initVars {
    _autoPlayCount = 0;
    _allowSaveToPhotoAlbum = YES;
    _dataState = YMVideoBrowseCellDataStateInvalid;
    _dataDownloadState = YMVideoBrowseCellDataDownloadStateNone;
    _loading = NO;
}

#pragma mark - <YMImageBrowserCellDataProtocol>
- (Class)ym_classOfBrowserCell {
    return YMVideoBrowseCell.class;
}

- (id)ym_browserCellSourceObject {
    return self.sourceObject;
}

- (CGRect)ym_browserCurrentImageFrameWithImageSize:(CGSize)size {
    return [self.class getImageViewFrameWithImageSize:size];
}

- (BOOL)ym_browserAllowSaveToPhotoAlbum {
    return self.allowSaveToPhotoAlbum;
}

- (void)ym_browserSaveToPhotoAlbum {
    if (self.avAsset && [self.avAsset isKindOfClass:AVURLAsset.class]) {
        AVURLAsset *asset = (AVURLAsset *)self.avAsset;
        NSURL *url = asset.URL;
        if ([url.scheme isEqualToString:@"file"]) {
            [YMIBPhotoAlbumManager saveVideoToAlbumWithPath:url.path];
        } else if ([url.scheme containsString:@"http"]) {
            [self downloadWithUrl:url];
        } else {
            NSLog(@"---视频失效");
        }
    } else {
        NSLog(@"---视频保存失败");
    }
}

- (void)ym_preload {
    [self loadData];
}

#pragma mark - internal
- (void)downLoadData {
    if (self.dataDownloadState == YMVideoBrowseCellDataDownloadStateIsDownloading) {
        self.dataDownloadState = YMVideoBrowseCellDataDownloadStateIsDownloading;
        return;
    }
    
    if ([self isMessageData]) {
        MessageModel *msgModel = (MessageModel *)self.extraData;
        YMDownloadItem *item = nil;
        item = [YMVideoDownloadManager itemWithFileId:msgModel.messageId];
        
        if (!item) {
            item = [YMDownloadItem itemWithUrl:[NSString ym_fileUrlStringWithSourceId:msgModel.sourceId] fileId:msgModel.messageId];
            item.enableSpeed = NO;
            
            NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
            [msgDict setObject:msgModel.roomId forKey:@"roomId"];
            [msgDict setObject:msgModel.messageId forKey:@"messageId"];
            [msgDict setObject:msgModel.sourceId forKey:@"sourceId"];
            [msgDict setObject:msgModel.type forKey:@"type"];
            [msgDict setObject:msgModel.fileName forKey:@"fileName"];
            [msgDict setObject:@(msgModel.isCryptoMessage) forKey:@"isCryptoMessage"];
            [msgDict setObject:@(msgModel.cryptoType) forKey:@"cryptoType"];
            [msgDict setObject:msgModel.sender forKey:@"sender"];
            //加密群聊用到
            NSString *fileKey = msgModel.fileKey.length > 0 ? msgModel.fileKey : @"";
            [msgDict setObject:fileKey forKey:@"fileKey"];
            
            id msgData = [msgDict mj_JSONData];
            item.extraData = msgData;
            [YMVideoDownloadManager startDownloadWithItem:item];
        } else {
        
            if (item.downloadStatus == YMDownloadStatusFinished) {
                return;
            } else {
                [YMVideoDownloadManager resumeDownloadWithItem:item];
            }
        }
        
        item.delegate = self;
    }
    
    self.downloadingVideoProgress = 0;
    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateIsDownloading;
//    [self downloadWithUrl:self.url];
}

- (void)loadData {
    if (self.loading) {
        self.dataState = self.dataState;
        return;
    } else {
        self.loading = YES;
    }
    
    if (self.avAsset) {
        [self loadFirstFrameOfVideo];
        NSString *aaa = self.url.scheme;
        if ([aaa isEqualToString:@"file"]) {//本地视频
            NSLog(@"加载本地视频");
        } else {
            if ([self isMessageData] && self.isShowIndex) {
                if (self.dataDownloadState == YMVideoBrowseCellDataDownloadStateIsDownloading) {
                    NSLog(@"不需要再下载");
                    return;
                }
                if ([self.url.scheme containsString:@"http"]) {
                    [self downLoadData];
//                    [self downloadWithUrl:self.url];
                    NSLog(@"去下载");
                }
            }
        }

    } else if (self.phAsset) {
        [self loadLocalFirstFrameOfVideo];
        [self loadAVAssetFromPHAsset];
    } else {
        self.dataState = YMVideoBrowseCellDataStateInvalid;
        self.loading = NO;
    }
}

- (void)loadAVAssetFromPHAsset {
    if (!self.phAsset) return;
    
    self.dataState = YMVideoBrowseCellDataStateIsLoadingPHAsset;
    [YMIBPhotoAlbumManager getAVAssetWithPHAsset:self.phAsset success:^(AVAsset *asset) {
        self.avAsset = asset;
        
        self.dataState = YMVideoBrowseCellDataStateLoadPHAssetSuccess;
        [self loadFirstFrameOfVideo];
    } failed:^{
        self.dataState = YMVideoBrowseCellDataStateLoadPHAssetFailed;
        self.loading = NO;
    }];
}

- (BOOL)loadLocalFirstFrameOfVideo {
    if (self.firstFrame) {
        self.dataState = YMVideoBrowseCellDataStateFirstFrameReady;
        self.loading = NO;
    } else if (self.sourceObject && [self.sourceObject isKindOfClass:UIImageView.class] && ((UIImageView *)self.sourceObject).image) {
        self.firstFrame = ((UIImageView *)self.sourceObject).image;
        self.dataState = YMVideoBrowseCellDataStateFirstFrameReady;
        self.loading = NO;
    } else {
        return NO;
    }
    return YES;
}

- (void)loadFirstFrameOfVideo {
    if (!self.avAsset) return;
    if ([self loadLocalFirstFrameOfVideo]) return;
    
    self.dataState = YMVideoBrowseCellDataStateIsLoadingFirstFrame;
    CGSize size = [self.class getPixelSizeOfCurrentLayoutDirection];
    YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.avAsset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = size;
        NSError *error = nil;
        CGImageRef cgImage = [generator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:NULL error:&error];
        UIImage *result = cgImage ? [UIImage imageWithCGImage:cgImage] : nil;
        YMIB_GET_QUEUE_MAIN_ASYNC(^{
            if (error || !result) {
                self.dataState = YMVideoBrowseCellDataStateLoadFirstFrameFailed;
                self.loading = NO;
            } else {
                self.firstFrame = result;
                self.dataState = YMVideoBrowseCellDataStateLoadFirstFrameSuccess;
                self.dataState = YMVideoBrowseCellDataStateFirstFrameReady;
                self.loading = NO;
            }
        })
    })
}

+ (CGRect)getImageViewFrameWithImageSize:(CGSize)size {
    CGSize cSize = [self.class getSizeOfCurrentLayoutDirection];
    if (cSize.width <= 0 || cSize.height <= 0 || size.width <= 0 || size.height <= 0) return CGRectZero;
    CGFloat x = 0, y = 0, width = 0, height = 0;
    if (size.width / size.height >= cSize.width / cSize.height) {
        width = cSize.width;
        height = cSize.width * (size.height / size.width);
        x = 0;
        y = (cSize.height - height) / 2.0;
    } else {
        height = cSize.height;
        width = cSize.height * (size.width / size.height);
        x = (cSize.width - width) / 2.0;
        y = 0;
    }
    return CGRectMake(x, y, width, height);
}

#pragma mark - private

+ (CGSize)getPixelSizeOfCurrentLayoutDirection {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = [self getSizeOfCurrentLayoutDirection];
    return CGSizeMake(size.width * scale, size.height * scale);
}

+ (CGSize)getSizeOfCurrentLayoutDirection {
    CGSize size = [YMIBLayoutDirectionManager getLayoutDirectionByStatusBar] == YMImageBrowserLayoutDirectionHorizontal ? CGSizeMake(YMIMAGEBROWSER_HEIGHT, YMIMAGEBROWSER_WIDTH) : CGSizeMake(YMIMAGEBROWSER_WIDTH, YMIMAGEBROWSER_HEIGHT);
    return size;
}

- (void)downloadWithUrl:(NSURL *)url {
    if (self.dataDownloadState == YMVideoBrowseCellDataDownloadStateIsDownloading) {
        self.dataDownloadState = YMVideoBrowseCellDataDownloadStateIsDownloading;
        return;
    }
    self.downloadingVideoProgress = 0;
    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateIsDownloading;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    _downloadTask = [session downloadTaskWithURL:url];
    [_downloadTask resume];
}

- (BOOL)isMessageData {
    if (self.extraData && [self.extraData isKindOfClass:[MessageModel class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)hadLocalVideoFile {
    AVURLAsset *asset = (AVURLAsset *)self.avAsset;
    NSURL *url = asset.URL;
    if ([url.scheme isEqualToString:@"file"] && [self isMessageData]) {
        return YES;
    }
    return NO;
}

#pragma mark - YMDownloadItemDelegate
- (void)downloadItemStatusChanged:(YMDownloadItem *)item {
    
    switch (item.downloadStatus) {
            case YMDownloadStatusWaiting:
            NSLog(@"正在等待");
            break;
            case YMDownloadStatusDownloading:
            NSLog(@"正在下载");
            break;
            case YMDownloadStatusPaused:
            NSLog(@"暂停下载");
            break;
            case YMDownloadStatusFinished: {
                if ([self isMessageData]) {
                    MessageModel *msgModel = (MessageModel *)self.extraData;
                    NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
                    //add by chw for 自动保存视频到相册
                    if ([YMDownSettingManager defaultManager].autoSaveVideo)
                        [TSImageHandler saveVideoToSystemAlbum:filePath showTip:NO];
                    _url = [NSURL fileURLWithPath:filePath];
                    self.avAsset = [AVURLAsset URLAssetWithURL:_url options:nil];
                    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateComplete;
                }
            }
            NSLog(@"下载成功");

            break;
            case YMDownloadStatusFailed:
            self.dataDownloadState = YMVideoBrowseCellDataDownloadStateFailed;
            NSLog(@"下载失败");
            break;
            
        default:
            break;
    }
}

- (void)downloadItem:(YMDownloadItem *)item downloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize {
    CGFloat progress = downloadedSize / (double)totalSize;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    self.downloadingVideoProgress = progress;
    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateIsDownloading;
//    [self changeSizeLblDownloadedSize:downloadedSize totalSize:totalSize];
}


#pragma mark - <NSURLSessionDelegate>

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    self.downloadingVideoProgress = progress;
    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateIsDownloading;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateFailed;
    if (error) {
        NSLog(@"下载失败");
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    if ([self isMessageData]) {
        MessageModel *msgModel = (MessageModel *)self.extraData;
        NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
        
        if (msgModel.isCryptoMessage) {
            NSData *olddDta = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            NSData *newData = nil;
            if (msgModel.fileKey) {
                newData = [[YMEncryptionManager shareManager] decryptAttachment:olddDta withKey:msgModel.fileKey];
            }
            else {
                newData = [[YMEncryptionManager shareManager] decryptData:olddDta cryptoType:msgModel.cryptoType withUserID:msgModel.sender needBase64:NO];
            }
            [newData writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
        }
        
        _url = [NSURL fileURLWithPath:filePath];
        self.avAsset = [AVURLAsset URLAssetWithURL:_url options:nil];
        self.dataDownloadState = YMVideoBrowseCellDataDownloadStateComplete;
    } else {
        NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *file = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)) {
            UISaveVideoAtPathToSavedPhotosAlbum(file, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } else {
            self.dataDownloadState = YMVideoBrowseCellDataDownloadStateComplete;
            NSLog(@"保存相册失败");
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    self.dataDownloadState = YMVideoBrowseCellDataDownloadStateComplete;
    if (error) {
        NSLog(@"保存相册失败");
    } else {
        NSLog(@"保存相册成功");
    }
}

#pragma mark - setter

- (void)setUrl:(NSURL *)url {
    _url = [url isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)url] : url;
    self.avAsset = [AVURLAsset URLAssetWithURL:_url options:nil];
}


@end
