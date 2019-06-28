//
//  RecordingAudioView.m
//  T-Shion
//
//  Created by together on 2018/5/14.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "RecordingAudioView.h"
#import <AVFoundation/AVFoundation.h>
#import "MessageModel.h"
#import "WebRTCHelper.h"
#import "AudioValueView.h"
#import "YMRTCHelper.h"

@interface RecordingAudioView()
@property (strong, nonatomic) UIImageView *logo;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *timeLabel;

@property (weak, nonatomic) AVAudioSession *session;

@property (copy, nonatomic) AVAudioRecorder *recorder;//录音器

@property (copy, nonatomic) NSString *documentPath; //文件地址

@property (copy, nonatomic) NSString *filePath;

@property (copy, nonatomic) NSDictionary *setParam;

@property (assign, nonatomic) int secondsCount;

@property (weak, nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSString *fileName;

@property (strong, nonatomic) AudioValueView *audioValueView;

@property (strong, nonatomic) NSMutableArray *valueArray;

@property (strong, nonatomic) UIView *shadowView;
@end

@implementation RecordingAudioView

- (instancetype)init {
    if (self = [super init]) {
        self.hidden = YES;
        [self addSubview:self.titleLabel];
        [self addSubview:self.shadowView];
        [self.shadowView addSubview:self.audioValueView];
    }
    return self;
}

- (void)layoutSubviews {
    [self.audioValueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(260, 50));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 30));
    }];
    [super layoutSubviews];
}

- (void)cancelSend {
//    self.titleLabel.textColor = [UIColor redColor];
    self.audioValueView.style = NO;
    self.titleLabel.text = Localized(@"Release_to_cancel");
}

- (void)show {
//    self.titleLabel.textColor = RGB(102, 102, 102);
    self.audioValueView.style = YES;
    self.titleLabel.text = Localized(@"Slide_up_to_cancel");
}

- (void)showPrompt {
//    self.titleLabel.textColor = RGB(102, 102, 102);
    self.titleLabel.text = Localized(@"Message_too_short");
    /*
     *@parameter 1,时间参照，从此刻开始计时
     *@parameter 2,延时多久，此处为秒级，还有纳秒等。10ull * NSEC_PER_MSEC
     */
    @weakify(self)
    int64_t delayInSeconds = 1.0;      // 延迟的时间
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // do something
        @strongify(self)
        self.titleLabel.text = Localized(@"Slide_up_to_cancel");
        self.titleLabel.textColor = [UIColor blackColor];
    });
}

- (void)start {
    [self endRecord];
    self.hidden = NO;
    _recorder = nil;
    NSError *sessionError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    
    if ([AVAudioSession sharedInstance] == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    } else {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    self.fileName = [NSString stringWithFormat:@"audio_%@.aac",[NSUUID UUID].UUIDString];
    self.filePath = [self.documentPath stringByAppendingPathComponent:self.fileName];
    //2.获取文件路径
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.filePath] settings:self.setParam error:nil];
    if (self.recorder) {
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
        [self.recorder record];
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
    [self show];
    [self addTimer];
}


- (void)stop {
//    [self removeObserver:self forKeyPath:AVAudioSessionRouteChangeNotification];
    if (self.filePath == nil) {
        return;
    }
    self.audioValueView.timerLabel.text = [NSString stringWithFormat:@"0:00"];
    [self endRecord];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.filePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float duration = CMTimeGetSeconds(audioDuration);
    if (duration<1) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
        [self showPrompt];
        return;
    }
    MessageModel *msgModel = [[MessageModel alloc] init];
    msgModel.fileName = self.fileName;
    msgModel.duration = [NSString stringWithFormat:@"%d",(int)duration];
    msgModel.type = @"audio";
    if (self.sendAudioBlock) {
        self.sendAudioBlock(msgModel);
    }
    self.filePath = nil;
    self.fileName = nil;
}

- (void)endRecord {
    self.hidden = YES;
    [self removeTimer];
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    
    self.audioValueView.timerLabel.text = [NSString stringWithFormat:@"0:00"];
    
    //wsp 添加,修复rtc退到后台没声音问题 2019.4.3
    if ([YMRTCHelper sharedInstance].currentRtcItem) return;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    //end
}

- (void)cancelRecord {
    self.hidden = YES;
    [self endRecord];
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    
    //wsp 添加,修复rtc退到后台没声音问题 2019.4.3
    if ([YMRTCHelper sharedInstance].currentRtcItem) return;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    //end
}

- (void)addTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
/**
 *  移除定时器
 */
- (void)removeTimer {
    [_timer invalidate];
    self.secondsCount = 0;
    _timer = nil;
}

-(void)refreshLabelText {
    [self recordTimerChange];
    self.secondsCount +=  1;
    int seconds = self.secondsCount/10;
    if (seconds>9) {
        self.audioValueView.timerLabel.text = [NSString stringWithFormat:@"0:%d",seconds];
    }else {
        self.audioValueView.timerLabel.text = [NSString stringWithFormat:@"0:0%d",seconds];
    }
    if (seconds >= 59) {
        [self removeTimer];
        [self stop];
       self.audioValueView.timerLabel.text = [NSString stringWithFormat:@"0:00"];
    }
}

- (void)recordTimerChange {
    [self.recorder updateMeters];
    
    float level; // The linear 0.0 .. 1.0 value we need.
    
    float minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    
    float decibels = [self.recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels){
        level = 0.0f;
    } else if (decibels >= 0.0f) {
        level = 1.0f;
    } else {
        float root = 2.0f;
        
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        
        float amp = powf(10.0f, 0.05f * decibels);
        
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    double ben = level * 12;
    double value = 1.2 * ben -1;
    if (value>15) {
        value = 15;
    }
    [self.valueArray insertObject:@(value) atIndex:0];
    [self.valueArray removeLastObject];
    [self.audioValueView setValueArray:self.valueArray];
}


//- (void)audioSessionWasInterrupted:(NSNotification *)notification {
//    NSLog(@"the notification is %@",notification);
//    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
//        NSLog(@"begin");
//    }else if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue]) {
//        NSLog(@"begin - end");
//    }
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (UIImageView *)logo {
    if (!_logo) {
        _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_microphone_logo"]];
    }
    return _logo;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = Localized(@"Slide_up_to_cancel");
        _titleLabel.textColor = RGB(102, 102, 102);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.shadowOpacity = 0.2;
        _titleLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _titleLabel.layer.shadowOffset = CGSizeMake(0, -3);
        _titleLabel.layer.shadowRadius = 2;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:17];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"0:00";
    }
    return _timeLabel;
}

- (AudioValueView *)audioValueView {
    if (!_audioValueView) {
        _audioValueView = [[AudioValueView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-260)*0.5, SCREEN_HEIGHT - 200, 260, 50) array:self.valueArray];
        _audioValueView.layer.masksToBounds = YES;
        _audioValueView.layer.cornerRadius = 25;
    }
    return _audioValueView;
}

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-260)*0.5, SCREEN_HEIGHT - 200, 260, 50)];
        _shadowView.layer.cornerRadius = 25;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 2);
        _shadowView.layer.shadowColor = [UIColor grayColor].CGColor;
        _shadowView.layer.shadowRadius = 6;
        _shadowView.layer.shadowOpacity = 0.3;
    }
    return _shadowView;
}

- (NSString *)documentPath {
    if (!_documentPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *audioPath = [self.folderPath stringByAppendingPathComponent:@"Audio"];
        BOOL isAudioDir = FALSE;
        BOOL isAudioDirExist = [fileManager fileExistsAtPath:audioPath isDirectory:&isAudioDir];
        if(!(isAudioDirExist && isAudioDir)) {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"创建文件夹失败！");
            }
        }
        _documentPath = audioPath;
    }
    //2.获取文件路径
    return _documentPath;
}

- (NSDictionary *)setParam {
    if (!_setParam) {
        _setParam = [[NSDictionary alloc] initWithObjectsAndKeys:
                     //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                     [NSNumber numberWithFloat: 8000],AVSampleRateKey,
                     // 音频格式
                     [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                     //采样位数  8、16、24、32 默认为16
                     [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                     // 音频通道数 1 或 2
                     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                     //录音质量
                     [NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,
                     nil];
    }
    return _setParam;
}

- (NSMutableArray *)valueArray {
    if (!_valueArray) {
        _valueArray = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
    }
    return _valueArray;
}

- (void)dealloc {
    NSLog(@"showvoiceview--释放了");
}
@end
