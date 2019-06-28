//
//  ALAVAudioPlayer.h
//  T-Shion
//
//  Created by together on 2019/4/8.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALAVAudioPlayer : AVAudioPlayer

/**
 创建新的播放对象

 @param url 播放地址URL type 1.消息的音频文件 如有后续使用可以继续添加type
 */
- (instancetype)initWithContentsOfURL:(NSURL *)url type:(int)type;
/**
 播放代理的block回调
 block return : blockType yes 播放结束 no 播放失败
 */
@property (copy, nonatomic) void (^playResultBlock) (BOOL blockType);

- (void)startPlay;

- (void)stopPlay;
@end

NS_ASSUME_NONNULL_END
