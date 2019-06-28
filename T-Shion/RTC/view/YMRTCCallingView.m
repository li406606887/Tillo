//
//  YMRTCCallingView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "YMRTCCallingView.h"
#import "FriendsModel.h"
#import "TSSoundManager.h"
#import "MZTimerLabel.h"

@interface YMRTCCallingView ()<MZTimerLabelDelegate>
@property (nonatomic, strong) UIVisualEffectView *blurView; //模糊背景曾
@property (nonatomic, strong) UIImageView *bgImageView;     //语音通话时如果有头像则显示拉伸图
@property (nonatomic, strong) UIView *manInfoView;          //包含个人信息视图的View
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *statusLabel;         //用于显示拨打状态的

@property (nonatomic, strong) MZTimerLabel *timeLabel;      //用于通话计时

@property (nonatomic, strong) YMRTCDataItem *dataItem;


@property (nonatomic, strong) UIView *operateBgView;       //包含操作视图的View
@property (nonatomic, strong) UIButton *hangupButton;      //挂断按钮
@property (nonatomic, strong) UILabel *hangupLabel;

@property (nonatomic, strong) UIButton *refuseButton;      //接收者显示的拒绝按钮
@property (nonatomic, strong) UILabel *refuseLabel;

@property (nonatomic, strong) UIButton *acceptButton;      //接收按钮
@property (nonatomic, strong) UILabel *acceptLabel;

@property (nonatomic, strong) UIButton *swapAudioBtn;      //拨打过程中的切换语音按钮
@property (nonatomic, strong) UILabel *swapAudioLabel;     

//通话中的操作按钮
@property (nonatomic, strong) UIButton *leftOperateBtn;
@property (nonatomic, strong) UILabel *leftOperateLabel;

@property (nonatomic, strong) UIButton *rightOperateBtn;
@property (nonatomic, strong) UILabel *rightOperateLabel;

@property (nonatomic, assign) BOOL hadSwapToAudio;

@end


@implementation YMRTCCallingView

- (void)dealloc {
    if (_dataItem) {
        [_dataItem removeObserver:self
                      forKeyPath:@"chatState"
                         context:NULL];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 初始化
- (instancetype)initWithDataItem:(YMRTCDataItem *)dataItem {
    if (self = [super init]) {
        _dataItem = dataItem;
        [self setupViews];
        [self addStatedObserver];
    }
    return self;
}

#pragma mark - 初始化视图
- (void)setupViews {
    if (_dataItem.chatType == YMRTCChatType_Audio) {
        [self addSubview:self.bgImageView];
    }
    
    [self addSubview:self.blurView];
    [self.blurView.contentView addSubview:self.manInfoView];
    [self.manInfoView addSubview:self.nameLabel];
    [self.manInfoView addSubview:self.statusLabel];
    [self.manInfoView addSubview:self.avatarView];
    
    [self addSubview:self.operateBgView];
    [self.operateBgView addSubview:self.hangupButton];
    [self.operateBgView addSubview:self.hangupLabel];
    
    [self.operateBgView addSubview:self.refuseButton];
    [self.operateBgView addSubview:self.refuseLabel];
    
    [self.operateBgView addSubview:self.acceptButton];
    [self.operateBgView addSubview:self.acceptLabel];
    
    [self.operateBgView addSubview:self.timeLabel];
    
    if (_dataItem.role == YMRTCRole_Caller) {
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
    
    if (_dataItem.chatType == YMRTCChatType_Video) {
        //如果是视频通话，显示切换到语音按钮
        [self.operateBgView addSubview:self.swapAudioBtn];
        [self.operateBgView addSubview:self.swapAudioLabel];
    }
    
    [self setUpConstraints];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(audioRouteChangeListenerCallback:)
     name:AVAudioSessionRouteChangeNotification
     object:[AVAudioSession sharedInstance]];
}

- (void)setUpConstraints {
    if (_dataItem.currentChatType == YMRTCChatType_Audio) {
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

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.hangupButton.mas_centerX);
        make.bottom.equalTo(self.hangupButton.mas_top).with.offset(-20);
    }];
    
    if (_dataItem.currentChatType == YMRTCChatType_Video) {
        if (_dataItem.role == YMRTCRole_Caller) {
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

#pragma mark - 操作页面按钮相关
- (void)initOperateViews {
    if (_dataItem.role == YMRTCRole_Callee) {
        [self.refuseButton removeFromSuperview];
        [self.refuseLabel removeFromSuperview];
        
        [self.acceptButton removeFromSuperview];
        [self.acceptLabel removeFromSuperview];
        self.hangupButton.hidden = NO;
        self.hangupLabel.hidden = NO;
    }
    
    if (self.hadSwapToAudio) return;
    
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
    
    if (_dataItem.currentChatType == YMRTCChatType_Audio) {
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
}

- (void)removeBlurView {
    if (_swapAudioBtn) {
        [_swapAudioBtn removeFromSuperview];
        [_swapAudioLabel removeFromSuperview];
    }
    
    [self.blurView removeFromSuperview];
}

- (void)setupViewAfterSwapToAudio {
    //切换到语音后操作页面
    
    [self addSubview:self.bgImageView];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    if (_dataItem.chatState == YMRTCState_Connected) {
        [self addSubview:self.blurView];
        self.blurView.effect = effect;
        [self.blurView.contentView addSubview:self.manInfoView];
        [self.manInfoView addSubview:self.nameLabel];
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
        
//        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.nameLabel.mas_bottom).with.offset(15);
//            make.centerX.equalTo(self.manInfoView.mas_centerX);
//        }];
        
        
        self.hadSwapToAudio = YES;
        
    } else {
        //如果还在拨打中，修改提示语
        self.blurView.effect = effect;
        if (_dataItem.role == YMRTCRole_Callee) {
            self.statusLabel.text = Localized(@"RTC_Calling_Audio_Callee");
        }
    }
    
    [self sendSubviewToBack:self.blurView];
    [self sendSubviewToBack:self.bgImageView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:_dataItem.otherInfoData.userId];
    
    [TShionSingleCase loadingAvatarWithImageView:_avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:_dataItem.otherInfoData.avatar] filePath:imagePath];
    
    [TShionSingleCase loadingAvatarWithImageView:_bgImageView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:_dataItem.otherInfoData.avatar] filePath:imagePath];
    
    
    if (_dataItem.chatState == YMRTCState_Connected) {
        //如果在通话中,修改左右两边的操作按钮样式
        _leftOperateLabel.text = Localized(@"RTC_Btn_Mute");//静音
        _rightOperateLabel.text = Localized(@"RTC_Btn_HF");//免提
        
        [_leftOperateBtn setImage:[UIImage imageNamed:@"rtc_mute"] forState:UIControlStateNormal];
        [_rightOperateBtn setImage:[UIImage imageNamed:@"rtc_hf"] forState:UIControlStateNormal];
        self.dataItem.isSpeakerEnabled = NO;
    }


    if (_swapAudioBtn) {
        [_swapAudioBtn removeFromSuperview];
        [_swapAudioLabel removeFromSuperview];
    }

    [self layoutIfNeeded];
}



#pragma mark - 监听状态修改
- (void)addStatedObserver {
    [self.dataItem addObserver:self forKeyPath:@"chatState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"chatState"]) {
        [self didChatStateChanged];
    }
}

//连接状态改变
- (void)didChatStateChanged {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.dataItem.role == YMRTCRole_Caller) {
            [self caller_itemStatusChanged:self.dataItem];
        } else {
            [self callee_itemStatusChanged:self.dataItem];
        }
    });
}

//作为发起者状态改变
- (void)caller_itemStatusChanged:(YMRTCDataItem *)item {
    switch (item.chatState) {
        case YMRTCState_Dialing:
            self.statusLabel.text = Localized(@"RTC_Dialing");
            break;
            
        case YMRTCState_Calling:
            self.statusLabel.text = Localized(@"RTC_Calling_Video_Caller");
            self.swapAudioBtn.enabled = YES;
            break;
            
        case YMRTCState_Connecting:
            [[TSSoundManager sharedManager] stop];
            self.statusLabel.text = Localized(@"RTC_Connecting");
            break;
            
        case YMRTCState_Connected:
            [[TSSoundManager sharedManager] stopWithShake];
            [self.statusLabel removeFromSuperview];
            _timeLabel.hidden = NO;
            [_timeLabel start];
            break;
            
        case YMRTCState_DialingError:
            self.statusLabel.text = Localized(@"RTC_Dialing_Error");
            break;
            
        case YMRTCState_Close:
            [self.timeLabel pause];
            break;
            
        default:
            break;
    }
    
}

//作为接收者状态改变
- (void)callee_itemStatusChanged:(YMRTCDataItem *)item {
    switch (item.chatState) {
        case YMRTCState_Dialing: {
            self.statusLabel.text = Localized(@"RTC_Joining");
        }
            break;
            
        case YMRTCState_Calling: {
            //加入房间之后这些按钮才可以操作
            self.swapAudioBtn.enabled = YES;
            self.acceptButton.enabled = YES;
            if (item.currentChatType == YMRTCChatType_Video) {
                self.statusLabel.text = Localized(@"RTC_Calling_Video_Callee");
            } else {
                self.statusLabel.text = Localized(@"RTC_Calling_Audio_Callee");
            }
        }
            break;
            
        case YMRTCState_Connecting:
            [[TSSoundManager sharedManager] stop];
            self.statusLabel.text = Localized(@"RTC_Connecting");
            break;
            
        case YMRTCState_Connected:
            [[TSSoundManager sharedManager] stopWithShake];
            [self.statusLabel removeFromSuperview];
            _timeLabel.hidden = NO;
            [_timeLabel start];
            break;
            
        case YMRTCState_DialingError:
            self.statusLabel.text = Localized(@"RTC_Connect_Error");
            break;
            
        case YMRTCState_ConnectingError:
            self.statusLabel.text = Localized(@"RTC_Connect_Error");
            break;
            
        case YMRTCState_Close:
            [self.timeLabel pause];
            break;
            
            
        default:
            break;
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
            self.dataItem.isSpeakerEnabled = NO;
            if (self.dataItem.chatType == YMRTCChatType_Audio) {
                if (self.dataItem.chatState >= YMRTCState_Connected) {
                    self.rightOperateBtn.enabled = NO;
                }
            }
            break;
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"耳机拔出");
            //拔出耳机时的处理为开启扬声器播放
            if (self.dataItem.chatType == YMRTCChatType_Video) {
                if (self.dataItem.chatState >= YMRTCState_Connected) {
                    self.dataItem.isSpeakerEnabled = YES;
                }
            } else {
                self.rightOperateBtn.enabled = NO;
                self.rightOperateBtn.selected = NO;
            }
            
            break;
            case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            NSLog(@"当前的播放生%@",[AVAudioSession sharedInstance].category);
            break;
    }
}



#pragma mark - 响应事件
- (void)hangupButtonClick:(UIButton *)sender {
    if (self.dataItem.chatState < YMRTCState_Connected) {
        self.dataItem.chatState = YMRTCState_Close_Caller_Cancel;
    } else {
        [self.timeLabel pause];
        self.dataItem.chatState = YMRTCState_Close;
    }
    
    [self.dataItem closeRtcCall:YES];
    
    //点击挂断
    if (self.delegate && [self.delegate respondsToSelector:@selector(callingViewDidHangupBtnClick:)]) {
        [self.delegate callingViewDidHangupBtnClick:self];
    }
}

- (void)swapAudioBtnClick:(UIButton *)sender {
    //点击切换语音按钮
    sender.enabled = NO;
    self.dataItem.currentChatType = YMRTCChatType_Audio;
    if (self.dataItem.role == YMRTCRole_Callee && sender) {
        //如果是接收者点击切换语音的时候会接收按钮不能点击
        //如果是发起者切换的不调用
        self.acceptButton.enabled = NO;
        if (self.dataItem.chatState == YMRTCState_Calling) {
            [self.dataItem swapToAudio];
            [self.dataItem createOffers];
        }
    }
    
    if (_dataItem.chatState == YMRTCState_Connected) {
        //如果是在通话中且是自己点击切换的，那么要发送socket
        if (sender) {
            [self.dataItem swapToAudio];
        }
    } else {
        //如果还没在通话中
        if (_dataItem.role == YMRTCRole_Caller) {
            //如果是发起者,那么需要发送socket, 如果是接收者则不需要调用
            [self.dataItem swapToAudio];
        }
    }
    
    [self setupViewAfterSwapToAudio];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(callingViewDidSwapAudioBtnClick:)]) {
        [self.delegate callingViewDidSwapAudioBtnClick:self];
    }
}

- (void)refuseButtonClick:(UIButton *)sender {
    //接受者点击拒绝按钮
    sender.enabled = NO;
    self.acceptButton.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(callingViewDidRefuseBtnClick:)]) {
        [self.delegate callingViewDidRefuseBtnClick:self];
    }
}

- (void)acceptButtonClick:(UIButton *)sender {
    //接受者点击接听按钮
    [[TSSoundManager sharedManager] stop];
    self.dataItem.chatState = YMRTCState_Connecting;
    sender.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(callingViewDidAcceptBtnClick:)]) {
        [self.delegate callingViewDidAcceptBtnClick:self];
    }
}

- (void)leftOperateBtnClick:(UIButton *)sender {
    if (_dataItem.currentChatType == YMRTCChatType_Audio) {
        //如果是语音通话
        sender.selected = !sender.isSelected;
        self.dataItem.isMicrophone = sender.isSelected;
    } else {
        //如果是视频通话，切换到语音
        [self swapAudioBtnClick:nil];
    }
}

- (void)rightOperateBtnClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (_dataItem.currentChatType == YMRTCChatType_Audio) {
        //如果是语音通话，切换免提
        self.dataItem.isSpeakerEnabled = sender.isSelected;
    } else {
        //如果是视频切换摄像头
        self.dataItem.isCameraFront = sender.isSelected;
    }
}

#pragma mark - MZTimerLabelDelegate
- (void)timerLabel:(MZTimerLabel *)timerlabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType {
    self.dataItem.callDuration = time;
    //计时时间到一小时切换文字效果
    if ((NSInteger)time == 3600) {
        timerlabel.timeFormat = @"HH mm:ss";
    }
}

#pragma mark - getter
- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        if (_dataItem.role == YMRTCRole_Caller && _dataItem.currentChatType == YMRTCChatType_Video) {
            //如果视频通话是发起者，初始化的时候不需要毛玻璃效果
            _blurView = [[UIVisualEffectView alloc] initWithEffect:nil];
        } else {
            _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        }
    }
    return _blurView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:_dataItem.otherInfoData.userId];
        [TShionSingleCase loadingAvatarWithImageView:_bgImageView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:_dataItem.otherInfoData.avatar] filePath:imagePath];
    }
    return _bgImageView;
}

- (UIView *)manInfoView {
    if (!_manInfoView) {
        _manInfoView = [[UIView alloc] init];
    }
    return _manInfoView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:nil
                                        font:[UIFont systemFontOfSize:28]
                                   textColor:[UIColor whiteColor]];
        _nameLabel.text = _dataItem.otherInfoData.showName;
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

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 60;
        _avatarView.backgroundColor = [UIColor whiteColor];
        
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:_dataItem.otherInfoData.userId];
        [TShionSingleCase loadingAvatarWithImageView:_avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:_dataItem.otherInfoData.avatar] filePath:imagePath];
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
        [_hangupButton addTarget:self action:@selector(hangupButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
        [_refuseButton addTarget:self action:@selector(refuseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
        [_acceptButton addTarget:self action:@selector(acceptButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _acceptButton.enabled = NO;
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
        
        [_leftOperateBtn addTarget:self action:@selector(leftOperateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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
        
        [_rightOperateBtn addTarget:self action:@selector(rightOperateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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

- (UIButton *)swapAudioBtn {
    if (!_swapAudioBtn) {
        _swapAudioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swapAudioBtn setImage:[UIImage imageNamed:@"rtc_switchToVoice_white"] forState:UIControlStateNormal];
        
        [_swapAudioBtn addTarget:self action:@selector(swapAudioBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _swapAudioBtn.enabled = NO;
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


@end
