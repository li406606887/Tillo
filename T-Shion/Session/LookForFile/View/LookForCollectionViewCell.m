//
//  LookForCollectionViewCell.m
//  T-Shion
//
//  Created by together on 2019/4/15.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForCollectionViewCell.h"
#import "UIImageView+YMAnimatedImageView.h"

@interface LookForCollectionViewCell ()
@property (strong, nonatomic) UIView *tilteBackView;
@property (strong, nonatomic) UILabel *duration;
@end

@implementation LookForCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(192, 192, 192);
        [self addSubview:self.imageView];
        [self addSubview:self.tilteBackView];
        [self addSubview:self.duration];
    }
    return self;
}

- (void)layoutSubviews {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.tilteBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(self.width, 20));
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self);
    }];
    
    [self.duration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tilteBackView);
        make.right.equalTo(self.tilteBackView.mas_right).with.offset(-5);
        make.size.mas_offset(CGSizeMake(self.width-10, 20));
    }];
    [super layoutSubviews];
}

- (void)setMessage:(MessageModel *)message {
    _message = message;
    self.imageView.image = nil;
    
    if (message.msgType == MESSAGE_Video) {
        NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
        
        if ([FMDBManager seletedFileIsSaveWithFilePath:imagePath] && message.videoIMGName) {
            [self.imageView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath]];
        } else {
            NSDictionary *mesureInfo = [message.measureInfo mj_JSONObject];
            NSString *videoImageURL = [mesureInfo objectForKey:@"frameUrl"];
            message.videoIMGName = message.videoIMGName.length < 1 ? [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg",[NSUUID UUID].UUIDString] : message.videoIMGName;
            
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:videoImageURL] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
                NSData *data = UIImageJPEGRepresentation(image, 1);
                if (data.length < 1) return;
                
                //指定新建文件夹路径
                BOOL result = [data writeToFile:path atomically:YES];
                if (result) {
                    NSLog(@"保存视频第一帧成功");
                }
                [FMDBManager updateVideoThumbIMGNameWithMessageModel:message];
            }];
        }
        
    } else {
        if ([FMDBManager seletedFileIsSaveWithPath:message]) {
            //如果本地存在文件
            NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
            self.maskView.hidden = YES;
            
            [self.imageView ym_setImageWithURL:[NSURL fileURLWithPath:imagePath] placeholderImage:nil options:0 progress:nil completed:nil];
            
        } else {
            //本地文件不存在则加载
            self.imageView.image = nil;
            
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
    
//    if (message.smallImage) {
//        self.imageView.image = message.smallImage;
//    } else {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//            if ([FMDBManager seletedFileIsSaveWithPath:message]) {
//                NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
//                [self.imageView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                    message.smallImage = image;
//                }];
//            } else {
//                @weakify(self)
//                NSString *hostUrl = nil;
//                if ([message.fileName hasSuffix:@".gif"]) {
//                    hostUrl = [NSString stringWithFormat:@"%@/file/getFile?id=%@",UploadHostUrl,message.sourceId];
//                } else {
//                    hostUrl = [NSString stringWithFormat:@"%@/file/reduceImage?id=%@",UploadHostUrl,message.sourceId];
//                }
//                message.fileName = message.fileName.length < 1 ? [NSString stringWithFormat:@"image_small_%@.jpg",[NSUUID UUID].UUIDString]: message.fileName;
//                [self.imageView sd_setImageWithURL:[NSURL URLWithString:hostUrl] placeholderImage:nil options:SDWebImageLowPriority completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                    @strongify(self)
//                    NSLog(@"%@",@(image.size));
//                    if (error == nil) {
//                        self.maskView.hidden = YES;
//                        NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
//                        message.smallImage = image;
//                        NSData *data = UIImageJPEGRepresentation(image, 1);
//
//                        if (data.length < 1) return;
//
//                        //指定新建文件夹路径
//                        BOOL result = [data writeToFile:path atomically:YES];
//                        if (result) {
//                            BOOL save = [FMDBManager seletedFileIsSaveWithPath:message];
//                            if (save == YES) {
//                                NSLog(@"数据库路径名存储成功");
//                            }
//                        }
//                        [FMDBManager updateFileNameWithMessageModel:message];
//                    }
//                }];
//            }
//        });
//    }
    
    
    if (message.msgType == MESSAGE_Video) {
        self.tilteBackView.hidden = self.duration.hidden = NO;
        int duration = [message.duration intValue];
        int min = 0;
        int sec = 0;
        if ([message.duration floatValue]>0) {
            min = duration/60;
            sec = duration%60;
            if (sec==0) {
                sec = 1;
            }
        }
        
        NSString *seconds;
        if (sec<10) {
            seconds = [NSString stringWithFormat:@"0%d",sec];
        }else {
            seconds = [NSString stringWithFormat:@"%d",sec];
        }
        
        self.duration.text = [NSString stringWithFormat:@"%d:%@",min,seconds];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
//            if ([FMDBManager seletedFileIsSaveWithFilePath:imagePath] && message.videoIMGName) {
//                [self.imageView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath]];
//            } else {
//                NSDictionary *mesureInfo = [message.measureInfo mj_JSONObject];
//                NSString *videoImageURL = [mesureInfo objectForKey:@"frameUrl"];
//                message.videoIMGName = message.videoIMGName.length < 1 ? [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg",[NSUUID UUID].UUIDString] : message.videoIMGName;
//                [self.imageView sd_setImageWithURL:[NSURL URLWithString:videoImageURL] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                    NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
//                    NSData *data = UIImageJPEGRepresentation(image, 1);
//                    if (data.length < 1) return;
//
//                    //指定新建文件夹路径
//                    BOOL result = [data writeToFile:path atomically:YES];
//                    if (result) {
//                        NSLog(@"保存视频第一帧成功");
//                    }
//                    [FMDBManager updateVideoThumbIMGNameWithMessageModel:message];
//                }];
//            }
//        });
    } else {
        self.tilteBackView.hidden = self.duration.hidden = YES;
    }
    
}

- (SDAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SDAnimatedImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)duration {
    if (!_duration) {
        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
        _duration.textColor = [UIColor whiteColor];
        _duration.textAlignment = NSTextAlignmentRight;
    }
    return _duration;
}

- (UIView *)tilteBackView {
    if (!_tilteBackView) {
        _tilteBackView = [[UIView alloc] init];
        _tilteBackView.backgroundColor = [UIColor blackColor];
        _tilteBackView.alpha = 0.1;
    }
    return _tilteBackView;
}
@end
