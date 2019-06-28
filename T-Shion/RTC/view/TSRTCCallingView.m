//
//  TSRTCCallingView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSRTCCallingView.h"
#import "FriendsModel.h"
#import "TSSoundManager.h"
#import "WebRTCHelper.h"
#import "MZTimerLabel.h"

@interface TSRTCCallingView ()<MZTimerLabelDelegate>

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIView *manInfoView;//包含个人信息视图的View
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) MZTimerLabel *timeLabel;
@property (nonatomic, strong) UIImageView *avatarView;


@property (nonatomic, strong) UIView *operateBgView;//包含操作视图的View
@property (nonatomic, strong) UIButton *hangupButton;
@property (nonatomic, strong) UILabel *hangupLabel;

@property (nonatomic, strong) UIButton *refuseButton;
@property (nonatomic, strong) UILabel *refuseLabel;

@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UILabel *acceptLabel;

//通话中的操作按钮
@property (nonatomic, strong) UIButton *leftOperateBtn;
@property (nonatomic, strong) UILabel *leftOperateLabel;

@property (nonatomic, strong) UIButton *rightOperateBtn;
@property (nonatomic, strong) UILabel *rightOperateLabel;

@property (nonatomic, strong) UIButton *swapAudioBtn;
@property (nonatomic, strong) UILabel *swapAudioLabel;

@property (nonatomic, strong) MZTimerLabel *videoTimeLabel;

@property (nonatomic, assign) RTCRole role;//角色
@property (nonatomic, assign) RTCChatType chatType;//呼叫类型：视频或语音

@property (nonatomic, assign) BOOL hadSwapToAudio;

@end


@implementation TSRTCCallingView

- (instancetype)initWithRole:(RTCRole)role chatType:(RTCChatType)chatType {
    if (self = [super init]) {
        _role = role;
        _chatType = chatType;
        [self setUpViews];
        [self setUpConstraints];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"----calling释放了");
}

#pragma mark - init
- (void)setUpViews {
    if (_chatType == RTCChatType_Audio) {
        [self addSubview:self.bgImageView];
    }
    
    [self addSubview:self.blurView];
    [self.blurView.contentView addSubview:self.manInfoView];
    [self.manInfoView addSubview:self.nameLabel];
    [self.manInfoView addSubview:self.statusLabel];
    [self.manInfoView addSubview:self.timeLabel];
    [self.manInfoView addSubview:self.avatarView];
    
    [self addSubview:self.operateBgView];
    
    [self.operateBgView addSubview:self.hangupButton];
    [self.operateBgView addSubview:self.hangupLabel];
    
    [self.operateBgView addSubview:self.refuseButton];
    [self.operateBgView addSubview:self.refuseLabel];
    
    [self.operateBgView addSubview:self.acceptButton];
    [self.operateBgView addSubview:self.acceptLabel];
    
    if (_role == TSRTCRole_Caller) {
        self.acceptButton.hidden = YES;
        self.refuseButton.hidden = YES;
        self.hangupButton.hidden = NO;
        
        self.acceptLabel.hidden = YES;
        self.refuseLabel.hidden = YES;
        self.hangupLabel.hidden = NO;
    
    } else {
        self.acceptButton.hidden = NO;
        self.refuseButton.hidden = NO;
        self.hangupButton.hidden = YES;
        
        self.acceptLabel.hidden = NO;
        self.refuseLabel.hidden = NO;
        self.hangupLabel.hidden = YES;
    }
    
    if (_chatType == RTCChatType_Video) {
        [self.operateBgView addSubview:self.swapAudioBtn];
        [self.operateBgView addSubview:self.swapAudioLabel];
    }
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"roomRequestFeedback" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.role == TSRTCRole_Callee) {
                [[TSSoundManager sharedManager] playCloseSound];
                if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingViewDidReceiveMpushHang:)]) {
                    [self.delegate rtcCallingViewDidReceiveMpushHang:self];
                }
            } else {
                [self refuseButtonClick];
            }
        });
    }];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(audioRouteChangeListenerCallback:)
     name:AVAudioSessionRouteChangeNotification
     object:[AVAudioSession sharedInstance]];
}

- (void)setUpConstraints {
    if (_chatType == RTCChatType_Audio) {
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.manInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.blurView.contentView);
    }];
    
    [self.operateBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.manInfoView.mas_top).with.offset(150);
        make.centerX.equalTo(self.manInfoView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];

    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.manInfoView.mas_centerX);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.manInfoView.mas_centerX);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.statusLabel);
    }];
    
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.operateBgView.mas_bottom).with.offset(-60);
        make.centerX.equalTo(self.operateBgView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.hangupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.hangupButton.mas_centerX);
        make.top.equalTo(self.hangupButton.mas_bottom).with.offset(10);
    }];
    
    [self.refuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.operateBgView.mas_bottom).with.offset(-60);
        make.centerX.equalTo(self.operateBgView.mas_centerX).with.offset(-(SCREEN_WIDTH/4));
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.refuseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.refuseButton.mas_centerX);
        make.top.equalTo(self.refuseButton.mas_bottom).with.offset(10);
    }];
    
    [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.operateBgView.mas_bottom).with.offset(-60);
        make.centerX.equalTo(self.operateBgView.mas_centerX).with.offset(SCREEN_WIDTH/4);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.acceptButton.mas_centerX);
        make.top.equalTo(self.acceptButton.mas_bottom).with.offset(10);
    }];
    
    if (_chatType == RTCChatType_Video) {
        if (_role == TSRTCRole_Caller) {
            [self.swapAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-60);
                make.centerX.equalTo(self.hangupButton.mas_centerX);
                make.size.mas_equalTo(CGSizeMake(33, 24));
            }];
        } else {
            [self.swapAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.acceptButton.mas_top).with.offset(-60);
                make.centerX.equalTo(self.acceptButton.mas_centerX);
                make.size.mas_equalTo(CGSizeMake(33, 24));
            }];
        }
        
        [self.swapAudioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.swapAudioBtn.mas_centerX);
            make.top.equalTo(self.swapAudioBtn.mas_bottom).with.offset(5);
        }];
    }
}

#pragma mark - 耳机相关
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
            NSLog(@"耳机插入");
            //插入耳机时关闭扬声器播放
            [WebRTCHelper sharedInstance].isSpeakerEnabled = NO;
            if (_chatType == RTCChatType_Audio) {
                if (self.contenctType == RTCConnectType_Connected) {
                    self.rightOperateBtn.enabled = NO;
                }
            }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"耳机拔出");
            //拔出耳机时的处理为开启扬声器播放
            if (_chatType == RTCChatType_Video) {
                if (self.contenctType == RTCConnectType_Connected) {
                    [WebRTCHelper sharedInstance].isSpeakerEnabled = YES;
                }
            } else {
                self.rightOperateBtn.enabled = NO;
                self.rightOperateBtn.selected = NO;
            }
            
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}


#pragma mark - events
- (void)backButtonClick {

}

- (void)hangupButtonClick {
    [[TSSoundManager sharedManager] playCloseSound];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingViewDidHangupClick:)]) {
        [self.delegate rtcCallingViewDidHangupClick:self];
    }
}

- (void)refuseButtonClick {
    [[TSSoundManager sharedManager] playCloseSound];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingViewDidRefuseClick:)]) {
        [self.delegate rtcCallingViewDidRefuseClick:self];
    }
}

- (void)acceptButtonClick {
    [[TSSoundManager sharedManager] stop];
    self.acceptButton.enabled = NO;
    if (self.chatType == RTCChatType_Video) {
        self.swapAudioBtn.enabled = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingViewDidAcceptClick:)]) {
        [self.delegate rtcCallingViewDidAcceptClick:self];
    }
}

- (void)leftOperateBtnClick {
    if (_chatType == RTCChatType_Audio) {
        self.leftOperateBtn.selected = !self.leftOperateBtn.isSelected;
    }
    
    if (_chatType == RTCChatType_Audio) {
        //是否静音
        BOOL state = [WebRTCHelper sharedInstance].isMicrophone;
        [WebRTCHelper sharedInstance].isMicrophone = !state;
        
    } else {
        //切换到语音
        [self swapAudioBtnClick];
    }
}

- (void)rightOperateBtnClick {
    self.rightOperateBtn.selected = !self.rightOperateBtn.isSelected;
    if (_chatType == RTCChatType_Audio) {
        //是否免提
        if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingView:didHFClick:)]) {
            BOOL state = [WebRTCHelper sharedInstance].isSpeakerEnabled;
            [WebRTCHelper sharedInstance].isSpeakerEnabled = !state;
        }
    } else {
        //切换摄像头
        if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingView:switchCamera:)]) {
            BOOL state = [WebRTCHelper sharedInstance].isCameraFront;
            [WebRTCHelper sharedInstance].isCameraFront = !state;
            
            [self.delegate rtcCallingView:self switchCamera:[WebRTCHelper sharedInstance].isCameraFront];
        }
    }
}

- (void)swapAudioBtnClick {
    [self swapToAudio];
    self.swapAudioBtn.enabled = NO;
    if (self.role == TSRTCRole_Callee) {
        self.acceptButton.enabled = NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(rtcCallingViewSwitchToAudio:)]) {
        [self.delegate rtcCallingViewSwitchToAudio:self];
    }
}

- (void)swapToAudio {
    _chatType = RTCChatType_Audio;
    if (_contenctType == RTCConnectType_Connected) {
        self.hadSwapToAudio = YES;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self changeViewAfterSwapToAudio];
    });
}

- (void)changeViewAfterSwapToAudio {
    [self.videoTimeLabel pause];
    self.timeLabel.timeFormat = self.videoTimeLabel.timeFormat;

    [self addSubview:self.bgImageView];
    
    if (_contenctType == RTCConnectType_Connected) {
        [self addSubview:self.blurView];
        [self.blurView.contentView addSubview:self.manInfoView];
        [self.manInfoView addSubview:self.nameLabel];
        [self.manInfoView addSubview:self.statusLabel];
        [self.manInfoView addSubview:self.timeLabel];
        [self.manInfoView addSubview:self.avatarView];
        
        [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        [self.manInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.blurView.contentView);
        }];
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.manInfoView.mas_top).with.offset(150);
            make.centerX.equalTo(self.manInfoView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(120, 120));
        }];
        
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_bottom).with.offset(15);
            make.centerX.equalTo(self.manInfoView.mas_centerX);
        }];
        
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).with.offset(15);
            make.centerX.equalTo(self.manInfoView.mas_centerX);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.statusLabel);
        }];

    } else {
        if (_role == TSRTCRole_Callee) {
            self.statusLabel.text = Localized(@"RTC_Calling_Audio_Callee");
        }
    }
    
    [self sendSubviewToBack:self.blurView];
    [self sendSubviewToBack:self.bgImageView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_receiveModel.avatar] placeholderImage:nil];
    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:_receiveModel.avatar] placeholderImage:[UIImage imageWithColor:RGB(30, 30, 30) size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)]];
    
    if (_contenctType == RTCConnectType_Connected) {
        _leftOperateLabel.text = @"静音";
        _rightOperateLabel.text = @"免提";
        
        [_leftOperateBtn setImage:[UIImage imageNamed:@"rtc_mute"] forState:UIControlStateNormal];
        [_rightOperateBtn setImage:[UIImage imageNamed:@"rtc_hf"] forState:UIControlStateNormal];
        
        [WebRTCHelper sharedInstance].isSpeakerEnabled = NO;
        
        _timeLabel.hidden = NO;
        [_timeLabel start];
        [_timeLabel addTimeCountedByTime:[self.videoTimeLabel getTimeCounted]];
    }
    
    if (_swapAudioBtn) {
        [_swapAudioBtn removeFromSuperview];
        [_swapAudioLabel removeFromSuperview];
    }
    
    if (_videoTimeLabel) {
        [_videoTimeLabel removeFromSuperview];
    }

    
    [self layoutIfNeeded];
}

#pragma mark - private
- (void)initOperateViews {
    if (_role == TSRTCRole_Callee) {
        [self.refuseButton removeFromSuperview];
        [self.refuseLabel removeFromSuperview];
        
        [self.acceptButton removeFromSuperview];
        [self.acceptLabel removeFromSuperview];
        self.hangupButton.hidden = NO;
        self.hangupLabel.hidden = NO;
    }
    
    if (self.hadSwapToAudio) {
        return;
    }
    
    [self addSubview:self.operateBgView];
    [self.operateBgView addSubview:self.leftOperateBtn];
    [self.operateBgView addSubview:self.leftOperateLabel];
    
    [self.operateBgView addSubview:self.rightOperateBtn];
    [self.operateBgView addSubview:self.rightOperateLabel];
    
    [self.leftOperateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.operateBgView.mas_bottom).with.offset(-60);
        make.centerX.equalTo(self.operateBgView.mas_centerX).with.offset(-(SCREEN_WIDTH/3));
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.leftOperateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.leftOperateBtn.mas_centerX);
        make.top.equalTo(self.leftOperateBtn.mas_bottom).with.offset(10);
    }];
    
    [self.rightOperateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.operateBgView.mas_bottom).with.offset(-60);
        make.centerX.equalTo(self.operateBgView.mas_centerX).with.offset(SCREEN_WIDTH/3);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.rightOperateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.rightOperateBtn.mas_centerX);
        make.top.equalTo(self.rightOperateBtn.mas_bottom).with.offset(10);
    }];
    
    if (_chatType == RTCChatType_Audio) {
        _leftOperateLabel.text = Localized(@"RTC_Btn_Mute");
        _rightOperateLabel.text = Localized(@"RTC_Btn_HF");
        
        [_leftOperateBtn setImage:[UIImage imageNamed:@"rtc_mute"] forState:UIControlStateNormal];
        [_rightOperateBtn setImage:[UIImage imageNamed:@"rtc_hf"] forState:UIControlStateNormal];
        
    } else {
        _leftOperateLabel.text = Localized(@"RTC_Btn_SwapAudio");
        _rightOperateLabel.text = Localized(@"RTC_Btn_SwitchCamera");
        
        [_leftOperateBtn setImage:[UIImage imageNamed:@"rtc_switchToVoice_black"] forState:UIControlStateNormal];
        [_rightOperateBtn setImage:[UIImage imageNamed:@"rtc_switchCamera"] forState:UIControlStateNormal];
    }
    
    if (_chatType == RTCChatType_Video) {
        [self addSubview:self.videoTimeLabel];
        
        [self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.hangupButton.mas_centerX);
            make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-20);
        }];

        [self.videoTimeLabel start];
    }
}

- (void)removeBlurView {
    if (_swapAudioBtn) {
        [_swapAudioBtn removeFromSuperview];
        [_swapAudioLabel removeFromSuperview];
    }

    [self.blurView removeFromSuperview];
}

#pragma mark - setter
- (void)setContenctType:(RTCConnectType)contenctType {
    
    NSString *statusStr = @"";
    
    switch (contenctType) {
        case RTCConnectType_Dialing:
            statusStr = Localized(@"RTC_Dialing");
            break;
            
        case RTCConnectType_Calling: {
            if (self.chatType == RTCChatType_Audio) {
                statusStr = self.role == TSRTCRole_Caller ? Localized(@"RTC_Calling_Audio_Caller") : Localized(@"RTC_Calling_Audio_Callee");
            } else {
                statusStr = self.role == TSRTCRole_Caller ? Localized(@"RTC_Calling_Video_Caller") : Localized(@"RTC_Calling_Video_Callee");
            }
            
            if (self.role == TSRTCRole_Caller) {
                [[TSSoundManager sharedManager] playCallerSound];
            } else {
                [[TSSoundManager sharedManager] playCalleeSound];
            }
        }
            break;
            
        case RTCConnectType_Connecting:
            statusStr = Localized(@"RTC_Connecting");
            [[TSSoundManager sharedManager] stop];
            break;
            
        case RTCConnectType_Connected: {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [[TSSoundManager sharedManager] stopWithShake];
                if (_chatType == RTCChatType_Audio) {
                    _timeLabel.hidden = NO;
                    [_timeLabel start];
                    ShowWinMessage(Localized(@"RTC_Connected"));
                }
            });
        }

            break;
            
        case RTCConnectType_DisConnect: 
            [[TSSoundManager sharedManager] playCloseSound];
            
            break;
            
        case RTCConnectType_BusyReceiver:
            [[TSSoundManager sharedManager] playCloseSound];
            break;
            
        case RTCConnectType_DialingError:
            [[TSSoundManager sharedManager] playCloseSound];
            break;
            
        case RTCConnectType_ConnectingError:
            [[TSSoundManager sharedManager] playCloseSound];
            break;
            
        case RTCConnectType_Close:
            [[TSSoundManager sharedManager] playCloseSound];
            
            break;
            
        default:
            break;
    }
    _contenctType = contenctType;
    if (contenctType < RTCConnectType_DisConnect) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = statusStr;
        });
    }
}

#pragma mark - MZTimerLabelDelegate
- (void)timerLabel:(MZTimerLabel *)timerlabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType{
    
    if ((NSInteger)time == 3600) {
        timerlabel.timeFormat = @"HH mm:ss";
    }
}


#pragma mark - getter
- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _blurView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
    }
    return _bgImageView;
}

- (UIView *)manInfoView {
    if (!_manInfoView) {
        _manInfoView = [[UIView alloc] init];
    }
    return _manInfoView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:nil
                                        font:[UIFont systemFontOfSize:28]
                                   textColor:[UIColor whiteColor]];
    }
    return _nameLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel constructLabel:CGRectZero
                                          text:nil
                                          font:[UIFont systemFontOfSize:15]
                                     textColor:[UIColor whiteColor]];
    }
    return _statusLabel;
}

- (MZTimerLabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[MZTimerLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.hidden = YES;
        _timeLabel.delegate = self;
        _timeLabel.timeFormat = @"mm:ss";
    }
    return _timeLabel;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 60;
        _avatarView.backgroundColor = [UIColor whiteColor];
    }
    return _avatarView;
}

- (UIView *)operateBgView {
    if (!_operateBgView) {
        _operateBgView = [[UIView alloc] init];
    }
    return _operateBgView;
}

- (UIButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangupButton setBackgroundImage:[UIImage imageWithColor:[UIColor ALRedColor]] forState:UIControlStateNormal];
        [_hangupButton setImage:[UIImage imageNamed:@"rtc_hangup"] forState:UIControlStateNormal];
        _hangupButton.layer.masksToBounds = YES;
        _hangupButton.layer.cornerRadius = 30;
        _hangupButton.backgroundColor = RGB(10, 10, 10);
        [_hangupButton addTarget:self action:@selector(hangupButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupButton;
}

- (UILabel *)hangupLabel {
    if (!_hangupLabel) {
        _hangupLabel = [UILabel constructLabel:CGRectZero
                                          text:Localized(@"RTC_Btn_Hangup")
                                          font:[UIFont systemFontOfSize:13]
                                     textColor:[UIColor whiteColor]];
    }
    return _hangupLabel;
}

- (UIButton *)refuseButton {
    if (!_refuseButton) {
        _refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refuseButton.layer.masksToBounds = YES;
        _refuseButton.layer.cornerRadius = 30;
        [_refuseButton setBackgroundImage:[UIImage imageWithColor:[UIColor ALRedColor]] forState:UIControlStateNormal];
        [_refuseButton setImage:[UIImage imageNamed:@"rtc_hangup"] forState:UIControlStateNormal];
        [_refuseButton addTarget:self action:@selector(refuseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refuseButton;
}

- (UILabel *)refuseLabel {
    if (!_refuseLabel) {
        _refuseLabel = [UILabel constructLabel:CGRectZero
                                          text:Localized(@"RTC_Btn_Refuse")
                                          font:[UIFont systemFontOfSize:13]
                                     textColor:[UIColor whiteColor]];
    }
    return _refuseLabel;
}

- (UIButton *)acceptButton {
    if (!_acceptButton) {
        _acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _acceptButton.layer.masksToBounds = YES;
        _acceptButton.layer.cornerRadius = 30;
        [_acceptButton setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_acceptButton setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_acceptButton setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        [_acceptButton setImage:[UIImage imageNamed:@"rtc_accept"] forState:UIControlStateNormal];
        [_acceptButton addTarget:self action:@selector(acceptButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _acceptButton;
}

- (UILabel *)acceptLabel {
    if (!_acceptLabel) {
        _acceptLabel = [UILabel constructLabel:CGRectZero
                                          text:Localized(@"RTC_Btn_Accept")
                                          font:[UIFont ALFontSize13]
                                     textColor:[UIColor whiteColor]];
    }
    return _acceptLabel;
}

- (UIButton *)leftOperateBtn {
    if (!_leftOperateBtn) {
        _leftOperateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_leftOperateBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnGrayColor]] forState:UIControlStateNormal];
        
        [_leftOperateBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        
        _leftOperateBtn.layer.masksToBounds = YES;
        _leftOperateBtn.layer.cornerRadius = 30;

        [_leftOperateBtn addTarget:self action:@selector(leftOperateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftOperateBtn;
}

- (UILabel *)leftOperateLabel {
    if (!_leftOperateLabel) {
        _leftOperateLabel = [UILabel constructLabel:CGRectZero
                                               text:nil
                                               font:[UIFont ALFontSize13]
                                          textColor:[UIColor whiteColor]];
    }
    return _leftOperateLabel;
}

- (UIButton *)rightOperateBtn {
    if (!_rightOperateBtn) {
        _rightOperateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightOperateBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnGrayColor]] forState:UIControlStateNormal];
        [_rightOperateBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        
        _rightOperateBtn.layer.masksToBounds = YES;
        _rightOperateBtn.layer.cornerRadius = 30;
      
        [_rightOperateBtn addTarget:self action:@selector(rightOperateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightOperateBtn;
}

- (UILabel *)rightOperateLabel {
    if (!_rightOperateLabel) {
        _rightOperateLabel = [UILabel constructLabel:CGRectZero
                                               text:nil
                                               font:[UIFont ALFontSize13]
                                          textColor:[UIColor whiteColor]];
    }
    
    return _rightOperateLabel;
}

- (MZTimerLabel *)videoTimeLabel {
    if (!_videoTimeLabel) {
        _videoTimeLabel = [[MZTimerLabel alloc] initWithFrame:CGRectZero];
        _videoTimeLabel.timeLabel.textColor = [UIColor whiteColor];
        _videoTimeLabel.timeLabel.font = [UIFont ALFontSize13];
        _videoTimeLabel.delegate = self;
        _videoTimeLabel.timeFormat = @"mm:ss";
    }
    return _videoTimeLabel;
}

- (UIButton *)swapAudioBtn {
    if (!_swapAudioBtn) {
        _swapAudioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swapAudioBtn setImage:[UIImage imageNamed:@"rtc_switchToVoice_white"] forState:UIControlStateNormal];
        
        [_swapAudioBtn addTarget:self action:@selector(swapAudioBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    }
    return _swapAudioBtn;
}

- (UILabel *)swapAudioLabel {
    if (!_swapAudioLabel) {
        _swapAudioLabel = [UILabel constructLabel:CGRectZero
                                             text:Localized(@"RTC_Btn_SwapAudio")
                                             font:[UIFont systemFontOfSize:15]
                                        textColor:[UIColor whiteColor]];
    }
    return _swapAudioLabel;
}

#pragma mark - setter
- (void)setReceiveModel:(FriendsModel *)receiveModel {
    _receiveModel = receiveModel;
    _nameLabel.text = receiveModel.showName;
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:receiveModel.avatar] placeholderImage:[UIImage imageNamed:@"Avatar_Deafult"]];
    if (_chatType == RTCChatType_Audio) {
        [_bgImageView sd_setImageWithURL:[NSURL URLWithString:receiveModel.avatar] placeholderImage:[UIImage imageWithColor:RGB(30, 30, 30) size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)]];
    }
}

- (NSTimeInterval)getCallDuration {
    if (_chatType == RTCChatType_Video) {
        return [self.videoTimeLabel getTimeCounted];
    } else {
        return [self.timeLabel getTimeCounted];
    }
}

@end
