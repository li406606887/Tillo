//
//  YMImageBrowseCellData.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowseCellData.h"
#import "YMIBUtilities.h"
#import "YMIBWebImageManager.h"
#import "YMImageBrowseCellData+Internal.h"
#import "YMImageBrowseCell.h"
#import "YMIBPhotoAlbumManager.h"
#import "TSImageHandler.h"
#import "YMImageDownloadManager.h"
#import "YMDownSettingManager.h"

static YMImageBrowseFillType _globalVerticalfillType = YMImageBrowseFillTypeFullWidth;
static YMImageBrowseFillType _globalHorizontalfillType = YMImageBrowseFillTypeFullWidth;
static CGSize _globalMaxTextureSize = (CGSize){4096, 4096};
static CGFloat _globalZoomScaleSurplus = 1.5;
static BOOL _shouldDecodeAsynchronously = YES;

@interface YMImageBrowseCellData ()<YMDownloadItemDelegate> {
    __weak id _downloadToken;
}

@property (nonatomic, strong) YMImage *image;
@property (nonatomic, assign) BOOL    loading;

@end

@implementation YMImageBrowseCellData

#pragma mark - 生命周期
+ (void)initialize {
    _shouldDecodeAsynchronously = !YMIBLowMemory();
}

- (void)dealloc {
    if (_downloadToken) {
        [YMIBWebImageManager cancelTaskWithDownloadToken:_downloadToken];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initVars];
    }
    return self;
}

- (void)initVars {
    _maxZoomScale = 0;
    _verticalfillType = YMImageBrowseFillTypeUnknown;
    _horizontalfillType = YMImageBrowseFillTypeUnknown;
    _allowSaveToPhotoAlbum = YES;
    
    _cutting = NO;
    _loading = NO;
}

#pragma mark - <YMImageBrowserCellDataProtocol>
- (Class)ym_classOfBrowserCell {
    return YMImageBrowseCell.class;
}

- (id)ym_browserCellSourceObject {
    return self.sourceObject;
}

- (CGRect)ym_browserCurrentImageFrameWithImageSize:(CGSize)size {
    YMImageBrowseFillType fillType = [self getFillTypeWithLayoutDirection:[YMIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
    return [self.class getImageViewFrameWithContainerSize:[self.class getSizeOfCurrentLayoutDirection] imageSize:size fillType:fillType];
}

- (BOOL)ym_browserAllowSaveToPhotoAlbum {
    return self.allowSaveToPhotoAlbum;
}

- (void)ym_browserSaveToPhotoAlbum {
    [YMIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
        
        if ([self.image respondsToSelector:@selector(animatedImageData)] && self.image.animatedImageData) {
            [YMIBPhotoAlbumManager saveDataToAlbum:self.image.animatedImageData];
        } else if (self.image) {
            [YMIBPhotoAlbumManager saveImageToAlbum:self.image];
        } else if (self.url) {
            [YMIBWebImageManager queryCacheOperationForKey:self.url completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
                if (data) {
                    YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        self.image = [YMImage imageWithData:data];
                        YMIB_GET_QUEUE_MAIN_ASYNC(^{
                            [YMIBPhotoAlbumManager saveImageToAlbum:self.image];
                        });
                    });
                } else {
                    NSLog(@"保存失败");
                }
            }];
        } else {
            NSLog(@"保存失败");
        }
        
    } failed:nil];
}

- (void)ym_preload {
    [self loadData];
}

#pragma mark - internal
- (void)loadData {
    if (self.loading) {
        YMImageBrowseCellDataState tmpState = self.dataState;
        if (self.thumbImage) {
            self.dataState = YMImageBrowseCellDataStateThumbImageReady;
        }
        self.dataState = tmpState;
        return;
    } else {
        self.loading = YES;
    }
    
    if (self.image) {
        [self loadLocalImage];
    } else if (self.imageBlock) {
        [self loadThumbImage];
        [self decodeLocalImage];
    } else if (self.url) {
        [self loadThumbImage];
        [self queryImageCache];
    } else if (self.phAsset) {
        [self loadThumbImage];
        [self loadImageFromPHAsset];
    } else {
        if (self.extraData && [self.extraData isKindOfClass:[NSDictionary class]]) {
            //如果是群头像或者头像不执行操作
            if ([self.extraData[@"isGroup"] boolValue]) {
                 self.image = [YMImage imageNamed:@"Group_Deafult_Avatar"];
            } else {
                 self.image = [YMImage imageNamed:@"Avatar_Deafult"];
            }
        }  else {
            self.dataState = YMImageBrowseCellDataStateInvalid;
            self.loading = NO;
        }
    }
}

- (void)loadLocalImage {
    if (!self.image) return;
    
    if ([self needCompress]) {
        if (self.compressImage) {
            self.dataState = YMImageBrowseCellDataStateCompressImageReady;
            self.loading = NO;
        } else {
            [self compressingImage];
        }
    } else {
        self.dataState = YMImageBrowseCellDataStateImageReady;
        self.loading = NO;
        
        if ([self isMessageData]) {
            MessageModel *msgModel = (MessageModel *)self.extraData;
            if (msgModel.isCryptoMessage) {//如果是加密图片则存到数据库
                if ([YMDownSettingManager defaultManager].autoSavePhoto)
                    [self saveCryptImageToAillo:msgModel];
            }
        }
    }
}

- (void)decodeLocalImage {
    if (!self.imageBlock) return;
    
    self.dataState = YMImageBrowseCellDataStateIsDecoding;
    YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.image = self.imageBlock();
        YMIB_GET_QUEUE_MAIN_ASYNC(^{
            self.dataState = YMImageBrowseCellDataStateDecodeComplete;
            if (self.image) {
                [self loadLocalImage];
            }
        });
    });
}

- (void)loadThumbImage {
    if (self.thumbImage) {
        self.dataState = YMImageBrowseCellDataStateThumbImageReady;
    } else if (self.sourceObject && [self.sourceObject isKindOfClass:UIImageView.class] && ((UIImageView *)self.sourceObject).image) {
        self.thumbImage = ((UIImageView *)self.sourceObject).image;
        self.dataState = YMImageBrowseCellDataStateThumbImageReady;
    } else if (self.thumbUrl) {
        [YMIBWebImageManager queryCacheOperationForKey:self.thumbUrl completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
            if (image) {
                self.thumbImage = image;
            } else if (data) {
                self.thumbImage = [UIImage imageWithData:data];
            }
            
            // If the target image is ready, ignore the thumb image.
            if (self.dataState != YMImageBrowseCellDataStateCompressImageReady && self.dataState != YMImageBrowseCellDataStateImageReady) {
                self.dataState = YMImageBrowseCellDataStateThumbImageReady;
            }
        }];
    }
}

- (void)loadImageFromPHAsset {
    if (!self.phAsset) return;
    
    self.dataState = YMImageBrowseCellDataStateIsLoadingPHAsset;
    
    static dispatch_queue_t assetQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetQueue = dispatch_queue_create("com.yumeng.ymimagebrowser.asset", DISPATCH_QUEUE_CONCURRENT);
    });
    
    dispatch_block_t block = ^{
        [YMIBPhotoAlbumManager getImageDataWithPHAsset:self.phAsset success:^(NSData *imgData) {
            self.image = [YMImage imageWithData:imgData];
            YMIB_GET_QUEUE_MAIN_ASYNC(^{
                self.dataState = YMImageBrowseCellDataStateLoadPHAssetSuccess;
                if (self.image) {
                    [self loadLocalImage];
                }
            });
        } failed:^{
            YMIB_GET_QUEUE_MAIN_ASYNC(^{
                self.dataState = YMImageBrowseCellDataStateLoadPHAssetFailed;
                self.loading = NO;
            });
        }];
    };

    YMIB_GET_QUEUE_ASYNC(assetQueue, ^{
        block();
    });
}


//查询缓存图片
- (void)queryImageCache {
    if (!self.url) return;
    
    self.dataState = YMImageBrowseCellDataStateIsQueryingCache;
    [YMIBWebImageManager queryCacheOperationForKey:self.url completed:^(id _Nullable image, NSData * _Nullable imagedata) {
        
        YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (imagedata) {
                self.image = [YMImage imageWithData:imagedata];
            }
            
            YMIB_GET_QUEUE_MAIN_ASYNC(^{
                self.dataState = YMImageBrowseCellDataStateQueryCacheComplete;
                
                if (self.image) {
                    [self loadLocalImage];
                    if ([YMDownSettingManager defaultManager].autoSavePhoto)
                        [self saveImageToAillo:imagedata];
                } else {
                    [self downloadImage];
                }
            });
        });
    }];
}

//下载图片
- (void)downloadImage {
    if (!self.url) return;
    
    if ([self isMessageData]) {
        //如果是加密图片
        MessageModel *msgModel = (MessageModel *)self.extraData;
        if (msgModel.isCryptoMessage) {
            [self downloadCryptImage:msgModel];
            return;
        }
    }
    
    self.dataState = YMImageBrowseCellDataStateIsDownloading;
    _downloadToken = [YMIBWebImageManager downloadImageWithURL:self.url progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        CGFloat value = receivedSize * 1.0 / expectedSize ?: 0;
        self->_downloadProgress = value;
        
        YMIB_GET_QUEUE_MAIN_ASYNC(^{
            self.dataState = YMImageBrowseCellDataStateDownloadProcess;
        })
    } success:^(UIImage * _Nullable image, NSData * _Nullable nsData, BOOL finished) {
        if (!finished) return;
        
        YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.image = [YMImage imageWithData:nsData];
            
            YMIB_GET_QUEUE_MAIN_ASYNC((^{
                
                [YMIBWebImageManager storeImage:self.image imageData:nsData forKey:self.url toDisk:YES];
                
                self.dataState = YMImageBrowseCellDataStateDownloadSuccess;
                if (self.image) {
                    [self loadLocalImage];
                }
                [self saveAvatar:nsData];
                if ([YMDownSettingManager defaultManager].autoSavePhoto)
                    [self saveImageToAillo:nsData];
            }));
        });
        
    } failed:^(NSError * _Nullable error, BOOL finished) {
        if (!finished) return;
        self.dataState = YMImageBrowseCellDataStateDownloadFailed;
        self.loading = NO;
    }];
}

- (void)compressingImage {
    if (!self.image) return;
    self.dataState = YMImageBrowseCellDataStateIsCompressingImage;
    CGSize size = [self getSizeOfCompressing];
    
    YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContext(size);
        [self.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        self.compressImage = UIGraphicsGetImageFromCurrentImageContext();
        if (!self.compressImage) self.compressImage = self.image;
        UIGraphicsEndImageContext();
        YMIB_GET_QUEUE_MAIN_ASYNC(^{
            self.dataState = YMImageBrowseCellDataStateCompressImageComplete;
            [self loadLocalImage];
        })
    })
}

- (BOOL)needCompress {
    if (!self.image) return NO;
    return YMImageBrowseCellData.globalMaxTextureSize.width * YMImageBrowseCellData.globalMaxTextureSize.height < self.image.size.width * self.image.scale * self.image.size.height * self.image.scale;
}

- (void)cuttingImageToRect:(CGRect)rect complete:(void (^)(UIImage *))complete {
    if (!self.image) return;
    if (_cutting) return;
    _cutting = YES;
    
    CGFloat zoomScale = self.zoomScale;
    BOOL (^isCancelled)(void) = ^BOOL{
        return zoomScale != self.zoomScale;
    };

    YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), (^{
        
        CGImageRef cgImage = CGImageCreateWithImageInRect(self.image.CGImage, rect);
        CGSize size = [self getSizeOfCuttingWithOriginSize:CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage))];
        
        UIImage *tmpImage = [UIImage imageWithCGImage:cgImage];
        UIGraphicsBeginImageContext(size);
        [tmpImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        CGImageRelease(cgImage);
        
        YMIB_GET_QUEUE_MAIN_ASYNC(^{
            self->_cutting = NO;
            if (complete && !isCancelled() && resultImage) {
                complete(resultImage);
            }
        })
    }))
}

- (YMImageBrowseFillType)getFillTypeWithLayoutDirection:(YMImageBrowserLayoutDirection)layoutDirection {
    YMImageBrowseFillType fillType;
    if (layoutDirection == YMImageBrowserLayoutDirectionHorizontal) {
        fillType = self.horizontalfillType == YMImageBrowseFillTypeUnknown ? YMImageBrowseCellData.globalHorizontalfillType : self.horizontalfillType;
    } else {
        fillType = self.verticalfillType == YMImageBrowseFillTypeUnknown ? YMImageBrowseCellData.globalVerticalfillType : self.verticalfillType;
    }
    return fillType == YMImageBrowseFillTypeUnknown ? YMImageBrowseFillTypeFullWidth : fillType;
}

+ (CGFloat)getMaximumZoomScaleWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(YMImageBrowseFillType)fillType {
    if (containerSize.width <= 0 || containerSize.height <= 0) return 0;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale <= 0) return 0;
    CGFloat widthScale = imageSize.width / scale / containerSize.width,
    heightScale = imageSize.height / scale / containerSize.height,
    maxScale = 1;
    switch (fillType) {
        case YMImageBrowseFillTypeFullWidth:
            maxScale = widthScale;
            break;
        case YMImageBrowseFillTypeCompletely:
            maxScale = MAX(widthScale, heightScale);
            break;
        case YMImageBrowseFillTypeUnknown: break;
    }
    return MAX(maxScale, 1) * YMImageBrowseCellData.globalZoomScaleSurplus;
}

+ (CGRect)getImageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(YMImageBrowseFillType)fillType {
    if (containerSize.width <= 0 || containerSize.height <= 0 || imageSize.width <= 0 || imageSize.height <= 0) return CGRectZero;
    CGFloat x = 0, y = 0, width = 0, height = 0;
    switch (fillType) {
        case YMImageBrowseFillTypeFullWidth: {
            x = 0;
            width = containerSize.width;
            height = containerSize.width * (imageSize.height / imageSize.width);
            if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height)
                y = (containerSize.height - height) / 2.0;
            else
                y = 0;
        }
            break;
        case YMImageBrowseFillTypeCompletely: {
            if (imageSize.width / imageSize.height >= containerSize.width / containerSize.height) {
                width = containerSize.width;
                height = containerSize.width * (imageSize.height / imageSize.width);
                x = 0;
                y = (containerSize.height - height) / 2.0;
            } else {
                height = containerSize.height;
                width = containerSize.height * (imageSize.width / imageSize.height);
                x = (containerSize.width - width) / 2.0;
                y = 0;
            }
        }
            break;
        case YMImageBrowseFillTypeUnknown: break;
    }
    return CGRectMake(x, y, width, height);
}

+ (CGSize)getContentSizeWithContainerSize:(CGSize)containerSize imageViewFrame:(CGRect)imageViewFrame {
    return CGSizeMake(MAX(containerSize.width, imageViewFrame.size.width), MAX(containerSize.height, imageViewFrame.size.height));
}

#pragma mark - 下载加密图片
- (BOOL)isMessageData {
    if (self.extraData && [self.extraData isKindOfClass:[MessageModel class]]) {
        return YES;
    }
    return NO;
}

//下载加密图片
- (void)downloadCryptImage:(MessageModel *)msgModel {
    
    NSString *path = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
    if (msgModel.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }

    YMDownloadItem *item = nil;
    item = [YMImageDownloadManager itemWithFileId:msgModel.messageId];
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
    
    if (!item) {
        self.dataState = YMImageBrowseCellDataStateIsDownloading;
        item = [YMDownloadItem itemWithUrl:[NSString ym_fileUrlStringWithSourceId:msgModel.sourceId] fileId:msgModel.messageId];
        
        item.extraData = msgData;
        [YMImageDownloadManager startDownloadWithItem:item];
    } else {
        item.extraData = msgData;
        if (item.downloadStatus == YMDownloadStatusFinished) {
            return;
        } else {
            [YMImageDownloadManager resumeDownloadWithItem:item];
        }
    }
    
    item.delegate = self;
}


- (void)downloadItemStatusChanged:(YMDownloadItem *)item {
    if (![self isMessageData]) return;
    MessageModel *msgModel = (MessageModel *)self.extraData;
    if (!msgModel.isCryptoMessage) return;
    if (![msgModel.messageId isEqualToString:item.fileId]) return;

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
                    [self didFinishDownloadCryptoImage];
                }
            }
            NSLog(@"下载成功");
            
            break;
            case YMDownloadStatusFailed: {
                self.dataState = YMImageBrowseCellDataStateDownloadFailed;
                self.loading = NO;
            }
            NSLog(@"下载失败");
            break;
            
        default:
            break;
    }
}

- (void)downloadItem:(YMDownloadItem *)item downloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize {
    if (![self isMessageData]) return;
    MessageModel *msgModel = (MessageModel *)self.extraData;
    if (!msgModel.isCryptoMessage) return;
    if (![msgModel.messageId isEqualToString:item.fileId]) return;
    CGFloat progress = downloadedSize / (double)totalSize;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    self.downloadProgress = progress;
    self.dataState = YMImageBrowseCellDataStateDownloadProcess;
    if (progress == 1) {
        [self didFinishDownloadCryptoImage];
    }
    //    [self changeSizeLblDownloadedSize:downloadedSize totalSize:totalSize];
}

- (void)didFinishDownloadCryptoImage {
    if (![self isMessageData]) return;
    MessageModel *msgModel = (MessageModel *)self.extraData;
    if (!msgModel.isCryptoMessage) return;
    
    NSString *path = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (!data) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishDownloadCryptoImageNoti object:msgModel];
    
//    if (msgModel.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        self.image = [YMImage imageWithData:data];
//        self.dataState = YMImageBrowseCellDataStateDownloadSuccess;
//        [self saveImageToAillo:data];
//        return;
//    }

    @weakify(self);
    YMIB_GET_QUEUE_ASYNC(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        self.image = [YMImage imageWithData:data];

        YMIB_GET_QUEUE_MAIN_ASYNC((^{
            @strongify(self);
            self.dataState = YMImageBrowseCellDataStateDownloadSuccess;
            if (self.image) {
                [self loadLocalImage];
            }
//            [self saveCryptImageToAillo:msgModel];
//            [self saveImageToAillo:data];
        }));
    });
}


#pragma mark - private
+ (CGSize)getSizeOfCurrentLayoutDirection {
    return [YMIBLayoutDirectionManager getLayoutDirectionByStatusBar] == YMImageBrowserLayoutDirectionHorizontal ? CGSizeMake(YMIMAGEBROWSER_HEIGHT, YMIMAGEBROWSER_WIDTH) : CGSizeMake(YMIMAGEBROWSER_WIDTH, YMIMAGEBROWSER_HEIGHT);
}

- (CGSize)getSizeOfCompressing {
    YMImageBrowseFillType fillType = [self getFillTypeWithLayoutDirection:[YMIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
    CGSize imageViewsize = [self.class getImageViewFrameWithContainerSize:[self.class getSizeOfCurrentLayoutDirection] imageSize:self.image.size fillType:fillType].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(floor(imageViewsize.width * scale), floor(imageViewsize.height * scale));
    return size;
}

- (CGSize)getSizeOfCuttingWithOriginSize:(CGSize)originSize {
    CGFloat oWidth = originSize.width, oHeight = originSize.height;
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width, maxHeight = [UIScreen mainScreen].bounds.size.height;
    if (oWidth < maxWidth && oHeight < maxHeight) {
        return originSize;
    }
    
    CGFloat rWidth = 0, rHeight = 0;
    if (oWidth / maxWidth < oHeight / maxHeight) {
        rHeight = maxHeight;
        rWidth = oWidth / oHeight * rHeight;
    } else {
        rWidth = maxWidth;
        rHeight = oHeight / oWidth * rWidth;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(rWidth * scale, rHeight * scale);
}

#pragma mark - 保存头像原图
- (void)saveAvatar:(NSData *)nsData {
    if (self.extraData && [self.extraData isKindOfClass:[NSDictionary class]]) {
        NSString *originalAvatarPath = [self.extraData objectForKey:@"originalAvatarPath"];
        if (originalAvatarPath && originalAvatarPath.length > 0) {
            [nsData writeToFile:originalAvatarPath atomically:YES];
        }
    }
}

#pragma mark - 保存到相册
- (void)saveCryptImageToAillo:(MessageModel *)msgModel {
    if (!msgModel.isCryptoMessage) return;
    if (msgModel.sendType == SelfSender) return;
    
    NSString *path = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
    
    if (msgModel.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        [self saveImageToAillo:path bigImageName:msgModel.fileName asssetPath:msgModel.bigImage message:msgModel];
    }
}

- (void)saveImageToAillo:(NSData *)nsData {
    if ([self isMessageData]) {
        //如果下载完成存到本地文件夹
        MessageModel *message = (MessageModel *)self.extraData;
        if (message.sendType == SelfSender) return;//自己发送的不保存
        if (message.bigImage.length > 5) return;
        NSString *folder = [FMDBManager getMessagePathWithMessage:message];
        NSString *bigImage = nil;
        BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:nsData];
        
        if (isGif) {
            bigImage = [NSString stringWithFormat:@"image_big_%@.gif", [NSUUID UUID].UUIDString];
        }
        else {
            bigImage = [NSString stringWithFormat:@"image_big_%@.jpg",[NSUUID UUID].UUIDString];
        }
        
        NSString *path = [folder stringByAppendingPathComponent:bigImage];
        [nsData writeToFile:path atomically:YES];
        [self saveImageToAillo:path bigImageName:bigImage asssetPath:message.bigImage message:message];

    }
}

- (void)saveImageToAillo:(id)imageData bigImageName:(NSString *)bigImageName asssetPath:(NSString *)assetPath message:(MessageModel *)message{
    if (assetPath && assetPath.length > 0)  //图片已经保存过了的处理
    {
        if ([TSImageHandler phAssetsIsExist:assetPath]) return;//图片还在相册，不重复保存
    }
    
    NSString *assetName = [TSImageHandler saveImageToAlbum:imageData];
    [FMDBManager updateMessagBigImagePathWithRoomId:message.roomId messageId:message.messageId assetName:assetName fileName:bigImageName];
    message.bigImage = assetName;
}

#pragma mark - setter
- (void)setUrl:(NSURL *)url {
    _url = [url isKindOfClass:NSString.class] ? [NSURL URLWithString:(NSString *)url] : url;
}

+ (void)setGlobalVerticalfillType:(YMImageBrowseFillType)globalVerticalfillType {
    _globalVerticalfillType = globalVerticalfillType;
}

+ (void)setGlobalHorizontalfillType:(YMImageBrowseFillType)globalHorizontalfillType {
    _globalHorizontalfillType = globalHorizontalfillType;
}

+ (void)setGlobalMaxTextureSize:(CGSize)globalMaxTextureSize {
    _globalMaxTextureSize = globalMaxTextureSize;
}

+ (void)setGlobalZoomScaleSurplus:(CGFloat)globalZoomScaleSurplus {
    _globalZoomScaleSurplus = globalZoomScaleSurplus;
}

+ (void)setShouldDecodeAsynchronously:(BOOL)shouldDecodeAsynchronously {
    _shouldDecodeAsynchronously = shouldDecodeAsynchronously;
}

#pragma mark - getter
+ (YMImageBrowseFillType)globalVerticalfillType {
    return _globalVerticalfillType;
}

+ (YMImageBrowseFillType)globalHorizontalfillType {
    return _globalHorizontalfillType;
}

+ (CGSize)globalMaxTextureSize {
    return _globalMaxTextureSize;
}

+ (CGFloat)globalZoomScaleSurplus {
    return _globalZoomScaleSurplus;
}

+ (BOOL)shouldDecodeAsynchronously {
    return _shouldDecodeAsynchronously;
}


@end
