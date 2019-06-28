//
//  ALMoviePlayerView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/26.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface ALMoviePlayerView : UIView

@property (nonatomic, copy) NSURL *movieURL;//视频的URL

@property (nonatomic, strong) UIView *coverView;//封面

@property (nonatomic, copy) NSString *filePath;//视频的存放路径


- (void)showWithMessageId:(NSString *)messageId isSoundOff:(BOOL)isSoundOff;//展示视频

//加密的视频的解密方法
@property (nonatomic, copy) NSData*(^decryptData)(NSData *data);

@end


@interface ALPlayerView : UIView

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic) BOOL soundOff;//是否静音默认NO

@property (nonatomic, copy) void(^playerPlayTimeChanged)(NSTimeInterval currentTime, NSTimeInterval duration);

@property (nonatomic, copy) void(^playerDidPlayToEndTime)(void);


- (void)play;
- (void)pause;
- (void)stop;

//重新播放
- (void)playerItemDidPlayToEnd;

- (CMTime)currentCMTime;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)totalTime;

@end

//===================================================================================
//下载管理 只支持单个视频下载
@interface ALMovieDownLoadManager : NSObject

+ (instancetype)shareManager;


- (NSURLSessionDownloadTask *)downloadMovieWithURL:(NSURL *)URL
                                          filePath:(NSString *)filePath
                                     progressBlock:(void(^)(CGFloat progress))progressBlock
                                           success:(void(^)(NSURL *URL))success
                                              fail:(void(^)(NSString *message))fail;
@end

//===================================================================================



#pragma mark - 加载进度条
@interface ALMovieProgressView : UIView

@property (nonatomic) CGFloat radius;//外圆半径 默认20

@property (nonatomic) CGFloat progress;//进度

@end
