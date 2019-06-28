//
//  MessageVideoView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/22.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageVideoView.h"

static CGFloat kMaxVideoWidth = 150;
static CGFloat kMinVideoWidth = 100;

@interface MessageVideoView ()

@property (nonatomic, strong) UIImageView *playFlag;

@end


@implementation MessageVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        [self addSubview:self.previewView];
        [self.previewView addSubview:self.playFlag];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.lookVideoDetailBlock) {
                self.lookVideoDetailBlock(self.message, self.previewView);
            }
        }];
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (CGSize)videoSize {
    NSDictionary *ratioData = [self.message.measureInfo mj_JSONObject];
    CGFloat width = [[ratioData objectForKey:@"width"] doubleValue];
    CGFloat height = [[ratioData objectForKey:@"height"] doubleValue];
    
    if (width == 0 || height == 0) {
        return CGSizeMake(100, 100);
    }
    
    return CGSizeMake(width, height);
}

- (CGSize)bubbleSize {
    return self.message.videoSize;
}

- (void)layoutSubviews {
    NSLog(@"w:%f h:%f", self.bounds.size.width, self.bounds.size.height);
    
    CGRect imageFrame = self.bounds;
    [self.previewView setFrame:imageFrame];
    self.playFlag.center = self.previewView.center;
    [super layoutSubviews];
}

#pragma mark - getter
- (UIImageView *)previewView {
    if (!_previewView) {
        _previewView = [[UIImageView alloc] init];
    }
    return _previewView;
}

- (UIImageView *)playFlag {
    if (!_playFlag) {
        _playFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_play_flag"]];
    }
    return _playFlag;
}

#pragma mark - setter
- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
    self.previewView.image = nil;
    NSString *imagePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
    
    if ([FMDBManager seletedFileIsSaveWithFilePath:imagePath] && message.videoIMGName) {
        [self.previewView sd_setImageWithURL:[NSURL fileURLWithPath:imagePath]];
    } else {
        NSDictionary *mesureInfo = [message.measureInfo mj_JSONObject];
        NSString *videoImageURL = [mesureInfo objectForKey:@"frameUrl"];
        message.videoIMGName = message.videoIMGName.length < 1 ? [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg",[NSUUID UUID].UUIDString] : message.videoIMGName;
        if (message.isCryptoMessage) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error;
                BOOL result = [TSRequest downloadVideoThumbIMGWithMessageModel:message imageURL:videoImageURL error:&error];
                if (error==nil&&result==YES) {
                    NSLog(@"视频第一帧图片下载成功");
                }
                NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.maskView.hidden = YES;
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    self.previewView.image = image;
                    [FMDBManager updateVideoThumbIMGNameWithMessageModel:message];
                });
            });
            return;
        }
        
        [self.previewView sd_setImageWithURL:[NSURL URLWithString:videoImageURL] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
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
}

@end
