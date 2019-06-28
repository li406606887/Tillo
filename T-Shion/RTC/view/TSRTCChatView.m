//
//  TSRTCChatView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSRTCChatView.h"
#import "WebRTCHelper.h"
#import "FriendsModel.h"
#import "MessageModel.h"
#import "NetworkModel.h"

#import "YMEncryptionManager.h"
#define kIs_iPhoneX (SCREEN_WIDTH >= 375.0f && SCREEN_HEIGHT >= 812.0f)

@interface TSRTCChatView ()<TSRTCCallingViewDelegate,WebRTCHelperDelegate,RTCEAGLVideoViewDelegate> {
    dispatch_source_t  _callingTimer;
    dispatch_source_t  _joinTimer;
}

@property (nonatomic, assign) RTCRole role;//角色
@property (nonatomic, assign) RTCChatType chatType;//呼叫类型：视频或语音

@property (nonatomic, strong) TSRTCCallingView *callingView;

@property (nonatomic, strong) RTCEAGLVideoView *localVideoView;
@property (nonatomic, strong) RTCEAGLVideoView *remoteVideoView;

@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSArray *receiveIDArray;
@property (nonatomic, copy) NSString *receiveHostURL;

@property (nonatomic, assign) BOOL hangupYourSelf;
@property (nonatomic, assign) BOOL unusualClose;//异常关闭

@property (nonatomic, strong) MessageModel *recordModel;
@property (nonatomic, assign) NSInteger callingTime;
@property (nonatomic, assign) NSInteger joinTime;


@property (nonatomic, assign) CGFloat localWidth;
@property (nonatomic, assign) CGFloat localHeight;

@property (nonatomic, assign) CGFloat remoteWidth;
@property (nonatomic, assign) CGFloat remoteHeight;

@property (nonatomic, assign) BOOL hadJoinRoom;
@property (nonatomic, assign) BOOL hadJoinNewPeer;
@property (nonatomic, assign) BOOL isWaitingForJoin;
@property (nonatomic, assign) BOOL isSwapAudio;


@end


@implementation TSRTCChatView

- (instancetype)initWithRole:(RTCRole)role
                    chatType:(RTCChatType)chatType
                      roomID:(NSString *)roomID
              receiveIDArray:(NSArray *)receiveIDArray
              receiveHostURL:(NSString *)receiveHostURL {
    if (self = [super init]) {
        _role = role;
        _chatType = chatType;
        _roomID = roomID;
        _receiveIDArray = receiveIDArray;
        _receiveHostURL = receiveHostURL;
        self.contenctType = role == TSRTCRole_Caller ? RTCConnectType_Dialing : RTCConnectType_Calling;
        [self setUpViews];
        [self setUpConstraints];
        [WebRTCHelper sharedInstance].delegate = self;
        [self socketConnectAction];
        
        //记录相关
        self.recordModel.type = chatType == RTCChatType_Audio ? @"rtc_audio" : @"rtc_video";
        self.recordModel.content = chatType == RTCChatType_Audio ? @"RTC_Msg_Audio" : @"RTC_Msg_Video";
        self.recordModel.roomId = [NSString stringWithFormat:@"%@",roomID];
        if (!_messageId) {
            self.recordModel.messageId = [NSUUID UUID].UUIDString;
        }
        
        if (role == TSRTCRole_Caller) {
            self.recordModel.sender = [SocketViewModel shared].userModel.ID;
            self.recordModel.sendType = SelfSender;
            self.recordModel.sendStatus = @"1";
        } else {
            self.recordModel.sender = receiveIDArray[0];
            self.recordModel.sendType = OtherSender;
        }
        
        [self bindViewModel];
    }
    return self;
}

- (void)setUpViews {    
    self.backgroundColor = RGB(50, 50, 50);
    if (_chatType == RTCChatType_Video) [self addSubview:self.localVideoView];
    if (_role == TSRTCRole_Caller)      [self callingCountDown];
    
    [self addSubview:self.callingView];
    
    //如果对方忙线
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"rtcRoom_other_isBusy" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.unusualClose = YES;
            [self dissMissConnectAction:RTCConnectType_BusyReceiver];
        });
    }];
}

- (void)setUpConstraints {
    [self.callingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)bindViewModel {
    @weakify(self);
    [[[SocketViewModel shared].rtcSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!x) {
            self.hangupYourSelf = YES;
            [self dissMissConnectAction:RTCConnectType_DialingError];
        }
    }];
}

#pragma mark - private
- (void)socketConnectAction {
    NSLog(@"-----------roomID:%@",_roomID);
    
#ifdef AilloTest
    [[WebRTCHelper sharedInstance] connectServer:RTCHostUrl
                                            port:@"8005"
                                            room:_roomID
                                        chatType:@"single"
                                            type:_chatType == RTCChatType_Video ? @"video" : @"audio"
                                     receiverIds:_receiveIDArray
                                      isReceiver:_role == TSRTCRole_Callee];
#endif
    
#ifdef AilloRelease
//    NSString *serverURL = _role == TSRTCRole_Caller ? @"websocket121.aillo.cc" : _receiveHostURL;
    
    NSString *serverURL = _role == TSRTCRole_Caller ? @"websocket.aillo.cc" : _receiveHostURL;
    [[WebRTCHelper sharedInstance] connectServer:serverURL
                                            port:@"8005"
                                            room:_roomID
                                        chatType:@"single"
                                            type:_chatType == RTCChatType_Video ? @"video" : @"audio"
                                     receiverIds:_receiveIDArray
                                      isReceiver:_role == TSRTCRole_Callee];
#endif
    
    
}

- (void)dissMissConnectAction:(RTCConnectType)ConnectType {
    
    if (self.contenctType >= RTCConnectType_DisConnect) {
        return;
    }
    
    if (ConnectType < RTCConnectType_DisConnect) {
        return;
    }
    
    [self destoryCallingTimer];
    [self destoryJoinTimer];
    
    //如果还没加入房间挂断调用
    if (_role == TSRTCRole_Caller) {
        if (self.hadJoinRoom && !self.hadJoinNewPeer && ConnectType != RTCConnectType_BusyReceiver ) {
            [self hangupRequest];
        }
    } else {
        if (!self.hadJoinRoom && ConnectType != RTCConnectType_BusyReceiver ) {
            [self hangupRequest];
        }
    }
    
    
    BOOL isCancel = self.contenctType == RTCConnectType_Calling && _role == TSRTCRole_Caller;
    [[WebRTCHelper sharedInstance] exitRoom:isCancel];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (ConnectType == RTCConnectType_BusyReceiver) {
            self.recordModel.rtcStatus = RTCMessageStatus_BusyReceiver;
            ShowWinMessage(Localized(@"RTC_Tip_BusyReceiver"));
        } else if (ConnectType == RTCConnectType_DisConnect) {
            self.recordModel.rtcStatus = RTCMessageStatus_Default;
            ShowWinMessage(Localized(@"RTC_Tip_Disconnect"));
        } else if (ConnectType == RTCConnectType_DialingError) {
            if (self.role == TSRTCRole_Caller) {
                self.recordModel.rtcStatus = RTCMessageStatus_YourCancel;
            } else {
                self.recordModel.rtcStatus = RTCMessageStatus_OthersCancel;
            }

            ShowWinMessage(Localized(@"RTC_Tip_DialError"));
        } else if (ConnectType == RTCConnectType_ConnectingError) {
            
            if (self.role == TSRTCRole_Caller) {
                self.recordModel.rtcStatus = RTCMessageStatus_YourCancel;
            } else {
                self.recordModel.rtcStatus = RTCMessageStatus_OthersCancel;
            }
            
            ShowWinMessage(Localized(@"RTC_Tip_ConnectingError"));
            
        } else {
            if (self.hangupYourSelf) {
                if (self.contenctType == RTCConnectType_Calling) {
                    if (self.role == TSRTCRole_Caller) {
                        ShowWinMessage(Localized(@"RTC_Tip_Cannel"));
                        self.recordModel.rtcStatus = RTCMessageStatus_YourCancel;
                    } else {
                        ShowWinMessage(Localized(@"RTC_Tip_Close"));
                        self.recordModel.rtcStatus = RTCMessageStatus_YourRefuse;
                    }
                } else {
                    ShowWinMessage(Localized(@"RTC_Tip_Close"));
                    self.recordModel.rtcStatus = RTCMessageStatus_Default;
                }
            } else {
                if (self.contenctType == RTCConnectType_Calling) {
                    if (self.role == TSRTCRole_Caller) {
                        ShowWinMessage(Localized(@"RTC_Tip_OthersRefuse"));
                        self.recordModel.rtcStatus = RTCMessageStatus_OthersRefuse;
                    } else {
                        ShowWinMessage(Localized(@"RTC_Tip_OthersCancel"));
                        self.recordModel.rtcStatus = RTCMessageStatus_OthersCancel;
                    }
                    
                } else {
                    ShowWinMessage(Localized(@"RTC_Tip_OthersCancel"));
                    self.recordModel.rtcStatus = RTCMessageStatus_Default;
                }
            }
        }
        
        self.recordModel.timestamp = [NSDate getNowTimestamp];
        if (self.recordModel.rtcStatus == RTCMessageStatus_Default) {
            NSInteger duration = (NSInteger)[self.callingView getCallDuration];
            if (duration == 0) duration = 1;
            self.recordModel.duration = [NSString stringWithFormat:@"%ld",duration];
        }
        
        if (self.role == TSRTCRole_Callee) {
            self.recordModel.readStatus = self.recordModel.rtcStatus == RTCMessageStatus_OthersCancel ? @"0" : @"1";
            self.recordModel.senderInfo = self.receiveModel;
        }
        
        self.recordModel.sendStatus = @"1";
        
        if (![FMDBManager isAlreadyHadMsg:self.recordModel]) {
            [FMDBManager insertSessionOnlineWithType:@"singleChat" message:self.recordModel withCount:self.recordModel.rtcStatus == RTCMessageStatus_OthersCancel?1:0];
        }
        [FMDBManager insertMessageWithContentModel:self.recordModel];
        
        NSString *roomIdStr = [NSString stringWithFormat:@"%@",self.roomID];
        if ([roomIdStr isEqualToString:[SocketViewModel shared].room]) {
            [[SocketViewModel shared].sendMessageSubject sendNext:self.recordModel];
        }
        
        [[SocketViewModel shared].getUnreadSessionSubject sendNext:nil];
        self.contenctType = ConnectType;
    });

    [self removeAllRenderer];
    
    __weak typeof(self)weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(rtcChatViewShouldDissmiss)]) {
            [weakSelf.delegate rtcChatViewShouldDissmiss];
        }
    });
}

- (void)switchToAudio {
    if (_chatType == RTCChatType_Audio) {
        return;
    }
    
    _chatType = RTCChatType_Audio;
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self removeAllRenderer];
        [self removeAllVideoView];
    });
}

- (void)callingCountDown {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _callingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_callingTimer, DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC, 0);
    
    @weakify(self);
    dispatch_source_set_event_handler(_callingTimer, ^{
        @strongify(self);
        self.callingTime += 15;
        if (self.callingTime == 30) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ShowWinMessage(Localized(@"RTC_Tip_PhoneNoAround"));
            });
        }
        
        if (self.callingTime == 45) {
            [self destoryCallingTimer];
            self.hangupYourSelf = YES;
            [self dissMissConnectAction:RTCConnectType_Close];
        }
    });
    
    dispatch_resume(_callingTimer);
}

- (void)joinCountDown {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _joinTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_joinTimer, DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC, 0);
    
    @weakify(self);
    dispatch_source_set_event_handler(_joinTimer, ^{
        @strongify(self);
        self.joinTime += 5;
        
        if (self.joinTime == 15) {
            [self destoryJoinTimer];
            self.hangupYourSelf = YES;
            [self dissMissConnectAction:RTCConnectType_ConnectingError];
        }
    });
    
    dispatch_resume(_joinTimer);
}

- (void)exchangeLocalAndRemote:(UITapGestureRecognizer *)tap{
    if (tap.view == self.localVideoView) {
        [self sendSubviewToBack:self.localVideoView];
        
        [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.mas_equalTo(self.localHeight);
            make.width.mas_equalTo(self.localWidth);
        }];

        [self.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top).with.offset(kIs_iPhoneX ? 44 : 20);
            make.height.mas_equalTo(self.remoteHeight/4);
            make.width.mas_equalTo(self.remoteWidth/4);
        }];
        
        [self bringSubviewToFront:self.remoteVideoView];
        
    } else {
        [self sendSubviewToBack:self.remoteVideoView];
        
        [self.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.mas_equalTo(self.remoteHeight);
            make.width.mas_equalTo(self.remoteWidth);
        }];
        
        [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top).with.offset(kIs_iPhoneX ? 44 : 20);
            make.height.mas_equalTo(self.localHeight/4);
            make.width.mas_equalTo(self.localWidth/4);
        }];
        
        
        [self bringSubviewToFront:self.localVideoView];
    }
    
    [self layoutIfNeeded];
}

- (void)destoryCallingTimer {
    if (_callingTimer) {
        dispatch_source_cancel(_callingTimer);
        _callingTimer = nil;
    }
}

- (void)destoryJoinTimer {
    if (_joinTimer) {
        dispatch_source_cancel(_joinTimer);
        _joinTimer = nil;
    }
}

- (void)hangupRequest {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];

    [param setObject:@[self.receiveModel.userId] forKey:@"receivers"];
    [param setObject:self.receiveModel.roomId forKey:@"roomId"];
    switch (_chatType) {
        case RTCChatType_Audio: {
            [param setObject:@"audio" forKey:@"type"];//类型音频 视频
        }
            break;
        case RTCChatType_Video: {
            [param setObject:@"video" forKey:@"type"];//类型音频 视频
        }
            break;
            
        default:
            break;
    }
    
    NSString *jsonString = [NSString dictionaryToJson:param];
    NSDictionary *paramAes = @{@"EncryptAESkey":[NSString ym_encryptAES:jsonString]};
    [[SocketViewModel shared].postCancelRTCCommand execute:paramAes];

}

- (void)removeAllRenderer {
    if (_localVideoTrack) [_localVideoTrack removeRenderer:_localVideoView];
    if (_remoteVideoTrack) [_remoteVideoTrack removeRenderer:_remoteVideoView];
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
}

- (void)removeAllVideoView {
    if (_localVideoView) [_localVideoView removeFromSuperview];
    if (_remoteVideoView) [_remoteVideoView removeFromSuperview];
    _localVideoView = nil;
    _remoteVideoView = nil;
}

//是否插入耳机
- (BOOL)hasHeadset {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];
    
    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        if ([[output portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - WebRTCHelperDelegate
//加入房间成功之后
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper didJoinRoom:(NSString *)userID busyReceivers:(NSArray *)busyReceivers rtcServer:(NSString *)rtcServer{
    self.hadJoinRoom = YES;
    
    if (_role == TSRTCRole_Caller) {
        
        if (busyReceivers.count > 0) {
            if ([busyReceivers containsObject:self.receiveModel.userId]) {
                self.unusualClose = YES;
                [self dissMissConnectAction:RTCConnectType_BusyReceiver];
                return;
            }
        }
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:@"call" forKey:@"cmd"];
        [param setObject:@"single" forKey:@"chatType"];
        [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
        [param setObject:@[self.receiveModel.userId] forKey:@"receivers"];
        [param setObject:self.roomID forKey:@"roomId"];//加密房间要修改
//        [param setObject:rtcServer forKey:@"rtcServer"];
        switch (_chatType) {
            case RTCChatType_Audio: {
                [param setObject:@"audio" forKey:@"type"];//类型音频 视频
            }
                break;
            case RTCChatType_Video: {
                [param setObject:@"video" forKey:@"type"];//类型音频 视频
            }
                break;
                
            default:
                break;
        }
        NSString *remoteIdentity = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:self.receiveModel.userId];
        if (remoteIdentity)
            [param setObject:remoteIdentity forKey:@"remoteIdentityKey"];
        NSString *jsonString = [NSString dictionaryToJson:param];
        NSDictionary *paramAes = @{@"EncryptAESkey":[NSString ym_encryptAES:jsonString]};
        [[SocketViewModel shared].postRTCCommand execute:paramAes];
        
        [webRTChelper createOffers];
    } else {

        if (self.isWaitingForJoin) {
            [self destoryJoinTimer];
            if (self.isSwapAudio) {
                [[WebRTCHelper sharedInstance] swapToAuido];
            }
            [webRTChelper createOffers];
        }
    }
}

- (void)webRTCHelper:(WebRTCHelper *)webRTChelper didJoinNewPeer:(NSString *)userID {
    self.hadJoinNewPeer = YES;
}

- (void)webRTCHelper:(WebRTCHelper *)webRTChelper setLocalAudioTrack:(RTCAudioTrack *)audioTrack {
    if (_role == TSRTCRole_Caller) {
        self.contenctType = RTCConnectType_Calling;
    }
}

//拿到本地视频流
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper setLocalVideoTrack:(RTCVideoTrack *)videoTrack {
    if (_role == TSRTCRole_Caller) {
        self.contenctType = RTCConnectType_Calling;
    }
    
    self.localVideoTrack = videoTrack;
    [self.localVideoTrack addRenderer:self.localVideoView];
}

//拿到远程流
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper addRemoteStream:(RTCMediaStream *)stream userId:(NSString *)userId {
    self.contenctType = RTCConnectType_Connected;
    
    [self destoryCallingTimer];
    [self destoryJoinTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.callingView initOperateViews];
        
        if (self.chatType == RTCChatType_Video) {
            [self.callingView removeBlurView];
            
            self.remoteVideoTrack = [stream.videoTracks lastObject];
            [self.remoteVideoTrack addRenderer:self.remoteVideoView];
            
            [self addSubview:self.remoteVideoView];
            [self sendSubviewToBack:self.remoteVideoView];
            [self bringSubviewToFront:self.localVideoView];
            
            [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_right);
                make.top.equalTo(self.mas_top).with.offset(kIs_iPhoneX ? 44 : 20);
                make.height.mas_equalTo(self.localHeight/4);
                make.width.mas_equalTo(self.localWidth/4);
            }];
        }
        
        //注意，一定要在流媒体来之后设置扬声器才有效
        if (self.chatType == RTCChatType_Audio) {
            [WebRTCHelper sharedInstance].isSpeakerEnabled = NO;
        } else {
            [WebRTCHelper sharedInstance].isSpeakerEnabled = [self hasHeadset] ? NO : YES;
        }
    });
}

//挂断
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper closeWithUserId:(NSString *)userId {
    if (self.hangupYourSelf || self.unusualClose) {
        return;
    }
    
    [self dissMissConnectAction:RTCConnectType_Close];
}

//异常断开
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper disConnectWithUserId:(NSString *)userId {
    self.unusualClose = YES;
    [self dissMissConnectAction:RTCConnectType_DisConnect];
}

//切换摄像头
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper didSwitchCamera:(BOOL)isCameraFront localStream:(RTCMediaStream *)stream {
}

//切换到语音
- (void)webRTCHelperDidSwapToAudio:(WebRTCHelper *)webRTChelper {
    [self switchToAudio];
    [self.callingView swapToAudio];
}

- (void)webRTCHelperSocketError:(WebRTCHelper *)webRTChelper errorCode:(NSInteger)errorCode {
    //对方将您删除好友
    if (errorCode == 3002) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ShowWinMessage(Localized(@"RTC_Tip_UserBeDelete"));
        });
    }
    
    self.hangupYourSelf = YES;
    [self dissMissConnectAction:RTCConnectType_DialingError];
}

//系统电话忙线处理：isBusyReceivers YES:对方处于系统忙线电话 NO:自己处于系统电话忙线
- (void)webRTCHelperDidSystemCalling:(WebRTCHelper *)webRTChelper isBusyReceivers:(BOOL)isBusyReceivers {
    if (isBusyReceivers) {
        self.unusualClose = YES;
        [self dissMissConnectAction:RTCConnectType_BusyReceiver];
    } else {
        self.hangupYourSelf = YES;
        [self dissMissConnectAction:RTCConnectType_Close];
    }
}

//对方处于忙线
- (void)webRTCHelperOtherIsBusy:(WebRTCHelper *)webRTCHelper {
    self.unusualClose = YES;
    [self dissMissConnectAction:RTCConnectType_BusyReceiver];
}

//接收方加入房间的时候如果发起方已经退出
- (void)webRTCHelperDidJoinRoomAndOtherHadCancel:(WebRTCHelper *)webRTChelper {
    [self dissMissConnectAction:RTCConnectType_Close];
}


#pragma mark - TSRTCCallingViewDelegate
//接听
- (void)rtcCallingViewDidAcceptClick:(TSRTCCallingView *)callingView {
    self.contenctType = RTCConnectType_Connecting;
    if (self.hadJoinRoom) {
        [[WebRTCHelper sharedInstance] createOffers];
    } else {
        self.isWaitingForJoin = YES;
        [self joinCountDown];
    }
}

//挂断
- (void)rtcCallingViewDidHangupClick:(TSRTCCallingView *)callingView {
    self.hangupYourSelf = YES;
    [self dissMissConnectAction:RTCConnectType_Close];
}

//拒绝
- (void)rtcCallingViewDidRefuseClick:(TSRTCCallingView *)callingView {
    self.hangupYourSelf = YES;
    [self dissMissConnectAction:RTCConnectType_Close];
}

//对方快速挂断时候
- (void)rtcCallingViewDidReceiveMpushHang:(TSRTCCallingView *)callingView {
    if (self.contenctType == RTCConnectType_Calling) {
        [self dissMissConnectAction:RTCConnectType_Close];
    } else {
        self.hangupYourSelf = YES;
        [self dissMissConnectAction:RTCConnectType_Close];
    }
}

//是否免提
- (void)rtcCallingView:(TSRTCCallingView *)callingView didHFClick:(BOOL)isHF {
    
}

//是否静音
- (void)rtcCallingView:(TSRTCCallingView *)callingView didMuteClick:(BOOL)isSilence {
    
}

//切换摄像头
- (void)rtcCallingView:(TSRTCCallingView *)callingView switchCamera:(BOOL)isFont {
    if (isFont) {
        _localVideoView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    } else {
        _localVideoView.transform = CGAffineTransformIdentity;
    }
}

//切换到语音
- (void)rtcCallingViewSwitchToAudio:(TSRTCCallingView *)callingView {
    [self switchToAudio];
    
    if (self.hadJoinRoom) {
        [[WebRTCHelper sharedInstance] swapToAuido];
    }
    
    if (_role == TSRTCRole_Callee && _contenctType == RTCConnectType_Calling) {
        if (self.hadJoinRoom) {
            [[WebRTCHelper sharedInstance] createOffers];
        } else {
            self.isWaitingForJoin = YES;
            self.isSwapAudio = YES;
            [self joinCountDown];
        }
    }
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    if (videoView == self.localVideoView && self.localWidth > 0) {
        return;
    }
    
    if (videoView == self.remoteVideoView && self.remoteWidth > 0) {
        return;
    }
    
    CGFloat tempWidth;
    CGFloat tempHeight;
    NSLog(@"%f",size.width);
    NSLog(@"%f",size.height);
    
    CGFloat videoWidth = size.width;
    CGFloat videoHeight = size.height;
    
    CGFloat videoRatio = size.width/size.height;
    CGFloat screenRatio = SCREEN_WIDTH/SCREEN_HEIGHT;
    NSLog(@"%f",videoRatio);
    NSLog(@"%f",screenRatio);
    
    tempWidth = SCREEN_WIDTH;
    CGFloat scale = SCREEN_WIDTH/videoWidth;
    tempHeight = videoHeight * scale;
    
    if (tempHeight < SCREEN_HEIGHT) {
        tempHeight = SCREEN_HEIGHT;
        scale = SCREEN_HEIGHT/videoHeight;
        tempWidth = videoWidth * scale;
    }

    if (videoView == self.localVideoView) {
        self.localWidth = tempWidth;
        self.localHeight = tempHeight;
        
        [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tempHeight);
            make.width.mas_equalTo(tempWidth);
            make.center.equalTo(self);
        }];
    } else {
        self.remoteWidth = tempWidth;
        self.remoteHeight = tempHeight;
        
        [self.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tempHeight);
            make.width.mas_equalTo(tempWidth);
            make.center.equalTo(self);
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutIfNeeded];
    });
}

#pragma mark - getter
- (TSRTCCallingView *)callingView {
    if (!_callingView) {
        _callingView = [[TSRTCCallingView alloc] initWithRole:_role chatType:_chatType];
        _callingView.receiveModel = _receiveModel;
        _callingView.delegate = self;
    }
    return _callingView;
}

- (RTCEAGLVideoView *)localVideoView {
    if (!_localVideoView) {
        _localVideoView = [[RTCEAGLVideoView alloc] init];
        _localVideoView.userInteractionEnabled = YES;
        _localVideoView.delegate = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeLocalAndRemote:)];
        
        [_localVideoView addGestureRecognizer:tap];
        _localVideoView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    return _localVideoView;
}

- (RTCEAGLVideoView *)remoteVideoView {
    if (!_remoteVideoView) {
        _remoteVideoView = [[RTCEAGLVideoView alloc] init];
        _remoteVideoView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeLocalAndRemote:)];
        
        [_remoteVideoView addGestureRecognizer:tap];
        _remoteVideoView.delegate = self;
        _remoteVideoView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    return _remoteVideoView;
}

#pragma mark - setter
- (void)setContenctType:(RTCConnectType)contenctType {
    if (contenctType == _contenctType) {
        return;
    }
    _contenctType = contenctType;
    self.callingView.contenctType = contenctType;
}

- (void)setReceiveModel:(FriendsModel *)receiveModel {
    _receiveModel= receiveModel;
    _callingView.receiveModel = receiveModel;
    
}

- (MessageModel *)recordModel {
    if (!_recordModel) {
        _recordModel = [[MessageModel alloc] init];
    }
    return _recordModel;
}

- (void)setMessageId:(NSString *)messageId {
    _messageId = messageId;
    self.recordModel.messageId = messageId;
}

@end
