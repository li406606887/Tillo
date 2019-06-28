//
//  MessageImageView.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageImageView.h"
#import "YMEncryptionManager.h"
#import "UIImageView+YMAnimatedImageView.h"
#import "YMImageDownloadManager.h"

@interface MessageImageView()
@property(nonatomic) UIView *maskView;

@property (nonatomic, assign) BOOL isDownloadCryptoImage;
@end

@implementation MessageImageView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imageView];
        
        [self addSubview:self.maskView];
        
        self.uploadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.uploadIndicatorView];
        
        self.downloadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.downloadIndicatorView];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.lookBigImageBlock) {
                self.lookBigImageBlock(self.message, self.imageView);
            }
        }];
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownloadCryptoImageNoti:) name:kFinishDownloadCryptoImageNoti object:nil];
        
    }
    return self;
}

- (void)setMessage:(MessageModel*)message {
    [super setMessage:message];
    self.maskView.hidden = NO;
    self.imageView.image = nil;
    if (message.smallImage) {
        self.imageView.image = message.smallImage;
        self.maskView.hidden = YES;
    } else {
        if ([FMDBManager seletedFileIsSaveWithPath:message]) {
            //如果本地存在文件
            NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
            self.maskView.hidden = YES;
            
            [self.imageView ym_setImageWithURL:[NSURL fileURLWithPath:imagePath] placeholderImage:nil options:0 progress:nil completed:nil];
            
        } else {
            //本地文件不存在则加载
            self.imageView.image = nil;
            [self.downloadIndicatorView startAnimating];
            
            if (message.isCryptoMessage) {
                message.fileName = message.fileName.length < 1 ? [NSString stringWithFormat:@"image_small_%@.jpg",[NSUUID UUID].UUIDString] : message.fileName;
                [self downLoadCryptoImage:message];
            }
            else {
                @weakify(self)
                NSString *hostUrl = nil;
                if ([message.fileName hasSuffix:@".gif"]) {
                    hostUrl = [NSString ym_fileUrlStringWithSourceId:message.sourceId];
                } else {
                    hostUrl = [NSString ym_thumbImgUrlStringWithMessage:message];
                }
                
                message.fileName = message.fileName.length < 1 ? [NSString stringWithFormat:@"image_small_%@.jpg",[NSUUID UUID].UUIDString] : message.fileName;
                
                [self.imageView ym_setImageWithURL:[NSURL URLWithString:hostUrl] placeholderImage:nil options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    NSLog(@"%ld----%ld",(long)receivedSize,(long)expectedSize);
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    
                    @strongify(self)
                    [self.downloadIndicatorView stopAnimating];
                    
                    if (error == nil) {
                        self.maskView.hidden = YES;
                        message.smallImage = image;
                        NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
                        MessageModel *newMsgModel = [FMDBManager selectMessageWithRoomId:message.roomId msgId:message.messageId];
                        if (![newMsgModel.fileName isEqualToString:message.fileName]) {
                            //如果已经保存大图
                            return;
                        }
                        if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
                            //如果已经存在大图不应该继续写入
                            return;
                        }
                        if (data.length < 1) return;
                        
                        //指定新建文件夹路径
                        BOOL result = [data writeToFile:path atomically:YES];
                        if (result) {
                            BOOL save = [FMDBManager seletedFileIsSaveWithPath:message];
                            if (save == YES) {
                                NSLog(@"数据库路径名存储成功");
                            }
                        }
                        
                        [FMDBManager updateFileNameWithMessageModel:message];
                    }
                }];
            }
        }
    }
    [self setNeedsDisplay];
}



//- (void)downLoadThunbImage:(MessageModel *)model imageUrl:(NSString *)imageUrl {
//    @weakify(self)
//    [TSRequest downloadImageWithMessageModel:model imageURL:imageUrl progress:^(NSProgress *downloadProgress) {
//        NSLog(@"缩略图进度---------------%lld-/-%lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
//
//    } success:^(id responseData) {
//        NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self)
//            self.maskView.hidden = YES;
//            [self.downloadIndicatorView stopAnimating];
//            BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:data];
//            if (isGif) {
//                UIImage *gifImage = [UIImage sd_imageWithGIFData:data];
//                model.smallImage = gifImage;
//                self.imageView.image = gifImage;
//            }
//            else {
//                UIImage *image = [UIImage imageWithData:data];
//                model.smallImage = image;
//                self.imageView.image = image;
//            }
//            [FMDBManager updateFileNameWithMessageModel:model];
//        });
//    } failure:nil];
//}

- (void)layoutSubviews {
    CGRect imageFrame = self.bounds;
    [self.imageView setFrame:imageFrame];
    self.maskView.frame = imageFrame;
    
    [self.downloadIndicatorView setFrame:imageFrame];
    [self.uploadIndicatorView setFrame:imageFrame];
    [super layoutSubviews];
}

#pragma mark - 加载加密图片相关
- (void)downLoadCryptoImage:(MessageModel *)msgModel {
    NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])return;
    
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
        item = [YMDownloadItem itemWithUrl:[NSString ym_fileUrlStringWithSourceId:msgModel.sourceId] fileId:msgModel.messageId];
        item.enableSpeed = NO;
        
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
    
//    item.delegate = self;
    @weakify(self);
    
    item.downloadStatusHandler = ^(NSNumber * _Nonnull downloadStatus) {
        @strongify(self);
        switch ([downloadStatus intValue]) {
                case YMDownloadStatusWaiting:
                NSLog(@"正在等待");
                break;
                case YMDownloadStatusDownloading:
                NSLog(@"正在下载");
                break;
                case YMDownloadStatusPaused:
                NSLog(@"暂停下载");
                break;
                case YMDownloadStatusFinished:
                [self didFinishDownloadCryptoImage];
                NSLog(@"下载成功");
                
                break;
                case YMDownloadStatusFailed:
                NSLog(@"下载失败");
                break;
                
            default:
                break;
        }
    };
}

#pragma mark - YMDownloadItemDelegate
//- (void)downloadItemStatusChanged:(YMDownloadItem *)item {
//
//    switch (item.downloadStatus) {
//            case YMDownloadStatusWaiting:
//            NSLog(@"正在等待");
//            break;
//            case YMDownloadStatusDownloading:
//            NSLog(@"正在下载");
//            break;
//            case YMDownloadStatusPaused:
//            NSLog(@"暂停下载");
//            break;
//            case YMDownloadStatusFinished:
//            [self didFinishDownloadCryptoImage];
//            NSLog(@"下载成功");
//
//            break;
//            case YMDownloadStatusFailed:
//            NSLog(@"下载失败");
//            break;
//
//        default:
//            break;
//    }
//}

//完成加密图片加载
- (void)didFinishDownloadCryptoImage {
    NSString *path = [[FMDBManager getMessagePathWithMessage:self.message] stringByAppendingPathComponent:self.message.fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        self.maskView.hidden = YES;
        [self.downloadIndicatorView stopAnimating];
        BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:data];
        if (isGif) {
            UIImage *gifImage = [UIImage sd_imageWithGIFData:data];
            self.message.smallImage = gifImage;
            self.imageView.image = gifImage;
        }
        else {
            UIImage *image = [UIImage imageWithData:data];
            self.message.smallImage = image;
            self.imageView.image = image;
        }
        [FMDBManager updateFileNameWithMessageModel:self.message];
    });
}

- (void)finishDownloadCryptoImageNoti:(NSNotification *)noti {
    MessageModel *msgModel = (MessageModel *)noti.object;
    if (![msgModel.messageId isEqualToString:self.message.messageId]) {
        return;
    }
    [self didFinishDownloadCryptoImage];
}

//- (void)downloadItem:(YMDownloadItem *)item downloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize {
//    CGFloat progress = downloadedSize / (double)totalSize;
//    if (progress < 0) progress = 0;
//    if (progress > 1) progress = 1;
//
//    NSLog(@"加密图片加载进度---------------%lld-/-%lld",downloadedSize,totalSize);
//}
//
//- (void)downloadItem:(YMDownloadItem *)item speed:(NSUInteger)speed speedDesc:(NSString *)speedDesc {
//
//}

#pragma mark - getter
- (CGSize)bubbleSize {
    return self.message.imageSize;
}

- (SDAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] init];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 6;
        _imageView.layer.borderColor = RGB(221,221,221).CGColor;
        _imageView.layer.borderWidth = 0.5f;

    }
    return _imageView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.5;
        _maskView.hidden = YES;
        _maskView.layer.masksToBounds = YES;
        _maskView.layer.cornerRadius = 6;
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _maskView;
}

- (CGSize)getImageCellSizeWithImage:(UIImage *)image {
    if (image) {
        CGSize imageSize = image.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        if (width>height) {
            CGFloat zoom = 140/width;
            width = 140;
            height = zoom*height;
        }else {
            CGFloat zoom = 140/height;
            height = 140;
            width = zoom*width;
        }
        CGSize size = CGSizeMake(width, height);
        CGRect rect = self.bounds;
        rect.size = size;
        self.bounds = rect;
        self.message.contentHeight = size.height;
        if (self.updateHeightBlock) {
            self.updateHeightBlock();
        }
        return size;
    }else {
        return CGSizeMake(140, 140);
    }
}
@end
