//
//  TSSoundManager.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/11/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSSoundManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface TSSoundManager () {
    SystemSoundID sound;//系统声音的id 取值范围为：1000-2000
    SystemSoundID callSound;//系统声音的id 取值范围为：1000-2000
}

//振动计时器
@property (nonatomic, strong) NSTimer *vibrationTimer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


@end

@implementation TSSoundManager

+ (instancetype)sharedManager {
    static TSSoundManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)playCallerSound {
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"call" ofType:@"caf"];
//
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &callSound);
//    AudioServicesAddSystemSoundCompletion(callSound, NULL, NULL, callSoundCompleteCallBack, NULL);
//    AudioServicesPlaySystemSound(callSound);
}

- (void)playCalleeSound {
//    [self playCallerSound];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playkSystemSound) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_vibrationTimer forMode:NSRunLoopCommonModes];
}

- (void)playCloseSound {
    [self stop];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"rtc_close" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
    AudioServicesPlaySystemSound(sound);
}

- (void)stop {
    if (_audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    
    [_vibrationTimer invalidate];
    _vibrationTimer = nil;
    
    AudioServicesRemoveSystemSoundCompletion(sound);
    AudioServicesDisposeSystemSoundID(sound);
    
    AudioServicesRemoveSystemSoundCompletion(callSound);
    AudioServicesDisposeSystemSoundID(callSound);
}

- (void)stopWithShake {
    if (_audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    
    [_vibrationTimer invalidate];
    _vibrationTimer = nil;
    
    AudioServicesRemoveSystemSoundCompletion(sound);
    AudioServicesDisposeSystemSoundID(sound);
    
    AudioServicesRemoveSystemSoundCompletion(callSound);
    AudioServicesDisposeSystemSoundID(callSound);
    
    [self playkSystemSound];
}

//振动
- (void)playkSystemSound{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//响铃回调方法
void soundCompleteCallBack(SystemSoundID sound,void * clientData) {
    AudioServicesPlaySystemSound(sound);
}

void callSoundCompleteCallBack(SystemSoundID callSound,void * clientData) {
    AudioServicesPlaySystemSound(callSound);
}

#pragma mark - getter
- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"call" ofType:@"caf"];
        NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
        //初始化播放器对象
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
        //设置声音的大小
        _audioPlayer.volume = 1;//范围为（0到1）；
        //设置循环次数，如果为负数，就是无限循环
        _audioPlayer.numberOfLoops =-1;
        //设置播放进度
//        _audioPlayer.currentTime = 0;
    }
    return _audioPlayer;
}

@end
