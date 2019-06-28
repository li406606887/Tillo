//
//  ALAVAudioPlayer.m
//  T-Shion
//
//  Created by together on 2019/4/8.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALAVAudioPlayer.h"


@interface ALAVAudioPlayer()<AVAudioPlayerDelegate>
@end

@implementation ALAVAudioPlayer
- (instancetype)initWithContentsOfURL:(NSURL *)url type:(int)type{
    self = [super initWithContentsOfURL:url error:nil];
    if (self) {
        [self readyPlay];
        self.delegate = self;
    }
    return self;
}

- (void)startPlay {
    [self play];
}

- (void)stopPlay {
    [self stop];
    if (self.playResultBlock) {
        self.playResultBlock(NO);
    }
}

- (void)readyPlay {
    [self setProximityMonitoringEnabledType:YES];
    //开启红外感应 yes 开启 no 关闭 在播放之前设置yes，播放结束设置NO。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProximity:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (![TShionSingleCase isHeadphone]) {//判断是否是耳机
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];//打开外放
    }else {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChangeListenerCallback:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
}

/**
 *  监听是否靠近听筒
 */
-(void)updateProximity:(NSNotification *)notification {
    NSLog(@"9876543210asdjhalsjhlzhjljhjhdlkahsdkjhlashdkljh1h2iueyiuo1y27y78zncbasyt109jfhgyrevyohuihu8172yz78yf87aas");
    //假设此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出。并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [self playAudioWithType:YES];
    }else {
        NSLog(@"Device is not close to user");
       [self playAudioWithType:NO];
    }

}
/**
 *  监听耳机插入拔出状态的改变
 *  @param notification 通知
 */
- (void)audioRouteChangeListenerCallback:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason   = [[interuptionDict
                                      valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            //插入耳机时关闭扬声器播放
//            [self.agoraKit setEnableSpeakerphone:NO];
            [self setProximityMonitoringEnabledType:YES];
            [self playAudioWithType:YES];
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            //拔出耳机时的处理为开启扬声器播放
            [self setProximityMonitoringEnabledType:NO];
            [self playAudioWithType:NO];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            if ([AVAudioSession sharedInstance].category == AVAudioSessionCategoryRecord) {
                [self endPlayWithType:NO];
            }
            break;
    }
}

/**
 *  监听耳机插入拔出状态的改变
 *  @param type yes 耳机或听筒 no 外放
 */
- (void)playAudioWithType:(BOOL)type {
    if (type) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}
/**
 *  结束语音播放
 *  @param type yes 播放结束 no 播放失败或终止
 */
- (void)endPlayWithType:(BOOL)type {
    if (self.playResultBlock) {
        self.playResultBlock(type);
    }
}
/**
 *  设置靠近屏幕黑屏的属性
 *  @param type 通知
 */
- (void)setProximityMonitoringEnabledType:(BOOL)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:type];
    });
}
/**
 *  移出监听
 */
- (void)removeobserver {
    [self setProximityMonitoringEnabledType:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}
/*
 * 音频播放完成时，调用该方法。
 * 参数flag：如果音频播放无法解码时，该参数为NO。
 * 当音频被终端时，该方法不被调用。而会调用audioPlayerBeginInterruption方法
 * 和audioPlayerEndInterruption方法
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self endPlayWithType:flag];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"player decode error");
    [self endPlayWithType:NO];
}

- (void)dealloc {
    [self removeobserver];
}

@end
