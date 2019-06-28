//
//  YMRTCBrowser.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "YMRTCBrowser.h"
#import "YMIBUtilities.h"
#import "YMRTCCallingView.h"
#import "TSSoundManager.h"
#import "YMRTCHelper.h"
#import "ALCameraRecordViewController.h"

#define kIs_iPhoneX (SCREEN_WIDTH >= 375.0f && SCREEN_HEIGHT >= 812.0f)

@interface YMRTCBrowser () <YMRTCCallingViewDelegate, YMRTCDataItemDelegate,RTCEAGLVideoViewDelegate> {
     dispatch_source_t  _callingTimer;
}

@property (nonatomic, strong) YMRTCCallingView *callingView;
@property (nonatomic, strong) YMRTCDataItem *dataItem;


@property (nonatomic, strong) RTCEAGLVideoView *localVideoView;
@property (nonatomic, strong) RTCEAGLVideoView *remoteVideoView;

@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;

@property (nonatomic, assign) CGFloat localWidth;
@property (nonatomic, assign) CGFloat localHeight;

@property (nonatomic, assign) CGFloat remoteWidth;
@property (nonatomic, assign) CGFloat remoteHeight;

@property (nonatomic, assign) NSInteger callingTime;//拨打时间


@end

@implementation YMRTCBrowser

#pragma mark - 初始化
- (instancetype)initWithDataItem:(YMRTCDataItem *)dataItem {
    if (self = [super init]) {
        _dataItem = dataItem;
        _dataItem.chatState = YMRTCState_Dialing;
        _dataItem.delegate = self;
    }
    return self;
}

#pragma mark - 生命周期
- (void)dealloc {
    NSLog(@"------YMRTCBrowser销毁了------");
    [YMRTCHelper sharedInstance].currentRtcItem = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //连接操作在这边执行
//    if (_dataItem.role == YMRTCRole_Caller) {
//        [self startRtcCalling];
//    }
    [self startRtcCalling];
}


#pragma mark - 视图构造
- (void)setupViews {
    self.view.backgroundColor = [UIColor blackColor];
    if (_dataItem.currentChatType == YMRTCChatType_Video) {
        [self.view addSubview:self.localVideoView];
    }
    [self.view addSubview:self.callingView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.callingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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


#pragma mark - 拨号和接收等操作
- (void)startRtcCalling {
    //拨号中
    [self.dataItem startRtcCalling];
    if (self.dataItem.role == YMRTCRole_Caller) {
        [[TSSoundManager sharedManager] playCallerSound];
    } else {
        [[TSSoundManager sharedManager] playCalleeSound];
    }
    
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kYMRTCHangNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self handleMpushHangEvent];
    }];
    
    //如果对方忙线
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kYMRTCBusyNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self handleMpushBusyEvent];
    }];
}

#pragma mark - 极限操作相关
- (void)handleMpushHangEvent {
    //来自mpush的挂断通知
    if (self.dataItem.role == YMRTCRole_Callee) {
        if (self.dataItem.chatState < YMRTCState_Connected) {
            //作为接收者, 还没接听，对方已取消
            self.dataItem.chatState = YMRTCState_Close_Caller_Cancel;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
        
    } else {
        //作为发起者收到通话结束请求
        if (self.dataItem.chatState < YMRTCState_Connected) {
            //如果还在拨打中,接收方拒绝
            self.dataItem.chatState = YMRTCState_Close_Callee_Refuse;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
    }
    
    [self.dataItem closeRtcCall:NO];
    [self RTC_DataItemStatusChanged:self.dataItem];
}

- (void)handleMpushBusyEvent {
    self.dataItem.chatState = YMRTCState_BusyReceiver;
    [self.dataItem closeRtcCall:NO];
    [self RTC_DataItemStatusChanged:self.dataItem];
}

#pragma mark - 拨打计时相关
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
        
        if (self.callingTime == 60) {
            //如果拨打计时到点，自动挂断
            [self destoryCallingTimer];
            self.dataItem.chatState = YMRTCState_Close_Caller_Timeout;
            [self RTC_DataItemStatusChanged:self.dataItem];
            [self.dataItem closeRtcCall:YES];
        }
    });
    
    dispatch_resume(_callingTimer);
}

- (void)destoryCallingTimer {
    if (_callingTimer) {
        dispatch_source_cancel(_callingTimer);
        _callingTimer = nil;
    }
}

#pragma mark - 公有方法
- (void)show {
    [self showFromController:YMIBGetTopController()];
}

- (void)showFromController:(UIViewController *)fromController {
    if ([fromController isKindOfClass:[YMRTCBrowser class]]) return;
    
    [YMRTCHelper sharedInstance].currentRtcItem = self.dataItem;
    
    if ([fromController isKindOfClass:[ALCameraRecordViewController class]]) {
        [fromController dismissViewControllerAnimated:NO completion:^{
            UIViewController *tempVC = YMIBGetTopController();
            [tempVC presentViewController:self animated:YES completion:nil];
        }];
        
    } else {
        [fromController presentViewController:self animated:YES completion:nil];
    }
}

- (void)hide {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - 私有方法

#pragma mark - YMRTCDataItemDelegate
- (void)RTC_DataItemStatusChanged:(YMRTCDataItem *)item {
    if (item.role == YMRTCRole_Caller) {
        [self caller_itemStatusChanged:item];
    } else {
        [self callee_itemStatusChanged:item];
    }
}

- (void)caller_itemStatusChanged:(YMRTCDataItem *)item {
    //作为发起者状态改变
    
    NSString *hideTip;
    switch (item.chatState) {
        case YMRTCState_Dialing:
            
            break;
            
        case YMRTCState_Calling:
            //如果是发起者拨号成功之后再计时
            [self callingCountDown];
            break;
            
        case YMRTCState_DisConnect:
            hideTip = Localized(@"RTC_Tip_Disconnect");//通话异常
            break;
            
        case YMRTCState_BusyReceiver:
            hideTip = Localized(@"RTC_Tip_BusyReceiver");//对方忙线
            break;
            
        case YMRTCState_DialingError:
            hideTip = Localized(@"RTC_Tip_DialError");//拨号失败
            break;
            
        case YMRTCState_Close_Caller_Timeout:
            hideTip = Localized(@"RTC_Tip_NoAnswer");//对方无应答
            break;
            
        case YMRTCState_Close_Callee_Refuse:
            hideTip = Localized(@"RTC_Tip_OthersRefuse");//对方拒绝你的通话邀请
            break;
            
        case YMRTCState_Close:
            hideTip = Localized(@"RTC_Tip_OthersCancel");//对方已挂断,结束通话
            break;
            
        default:
            break;
    }
    
    if (hideTip) {
        [self destoryCallingTimer];
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            ShowWinMessage(hideTip);
            [self performSelector:@selector(hide) withObject:nil afterDelay:2];
        });
    }
}

- (void)callee_itemStatusChanged:(YMRTCDataItem *)item {
    //作为接收者状态改变
    NSString *hideTip;
    switch (item.chatState) {
        case YMRTCState_Dialing:
            
            break;
            
        case YMRTCState_Calling:
            
            break;
            
        case YMRTCState_DisConnect:
            hideTip = Localized(@"RTC_Tip_Disconnect");//通话异常
            break;
            
        case YMRTCState_BusyReceiver:
            hideTip = Localized(@"RTC_Tip_BusyReceiver");//对方忙线
            break;
            
        case YMRTCState_DialingError:
            hideTip = Localized(@"RTC_Tip_DialError");//拨号失败
            break;
            
        case YMRTCState_Close_Caller_Cancel:
            hideTip = Localized(@"RTC_Tip_OthersCancel");
            break;
            
        case YMRTCState_Close:
            hideTip = Localized(@"RTC_Tip_OthersCancel");//对方已挂断,结束通话
            break;
            
        default:
            break;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        ShowWinMessage(hideTip);
        [self performSelector:@selector(hide) withObject:nil afterDelay:2];
    });
}

- (void)RTC_DataItem:(YMRTCDataItem *)item didAddLocalAudioTrack:(RTCAudioTrack *)audioTrack {
    //加入本地音频流
}

- (void)RTC_DataItem:(YMRTCDataItem *)item didAddLocalVideoTrack:(RTCVideoTrack *)videoTrack {
    //加入本地视频流
    self.localVideoTrack = videoTrack;
    [self.localVideoTrack addRenderer:self.localVideoView];
}

- (void)RTC_DataItem:(YMRTCDataItem *)item didAddRemoteStream:(RTCMediaStream *)stream {
    //连接成功
    self.dataItem.chatState = YMRTCState_Connected;
    [self destoryCallingTimer];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.callingView initOperateViews];
        @strongify(self);
        if (item.currentChatType == YMRTCChatType_Video) {
            [self.callingView removeBlurView];
            
            self.remoteVideoTrack = [stream.videoTracks lastObject];
            [self.remoteVideoTrack addRenderer:self.remoteVideoView];
            
            [self.view addSubview:self.remoteVideoView];
            [self.view sendSubviewToBack:self.remoteVideoView];
            [self.view bringSubviewToFront:self.localVideoView];
            
            [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view.mas_right);
                make.top.equalTo(self.view.mas_top).with.offset(kIs_iPhoneX ? 44 : 20);
                make.height.mas_equalTo(self.localHeight/4);
                make.width.mas_equalTo(self.localWidth/4);
            }];
            
        }
        
        //注意，一定要在流媒体来之后设置扬声器才有效
        if (item.currentChatType == YMRTCChatType_Audio) {
            self.dataItem.isSpeakerEnabled = NO;
        } else {
            self.dataItem.isSpeakerEnabled = [self hasHeadset] ? NO : YES;
        }
    });
}

- (void)RTC_DataItem:(YMRTCDataItem *)item didJoinRoom:(BOOL)isBusyReceivers {
    if (isBusyReceivers) return;//如果忙线不继续执行
//    if (item.role == YMRTCRole_Caller) {
//        [self callingCountDown];
//    }
}

- (void)RTC_DataItem:(YMRTCDataItem *)item didRemovePeer:(NSString *)peerId {
    
    if (item.role == YMRTCRole_Callee) {
        if (item.chatState < YMRTCState_Connected) {
            //作为接收者, 还没接听，对方已取消
            self.dataItem.chatState = YMRTCState_Close_Caller_Cancel;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
        
    } else {
        //作为发起者收到通话结束请求
        if (item.chatState < YMRTCState_Connected) {
            //如果还在拨打中,接收方拒绝
            self.dataItem.chatState = YMRTCState_Close_Callee_Refuse;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
    }
    
    [self.dataItem closeRtcCall:NO];
    [self RTC_DataItemStatusChanged:self.dataItem];
}

- (void)RTC_DataItemDidOtherSystemCalling:(YMRTCDataItem *)item {
    //对方在系统电话忙线中
    [self destoryCallingTimer];
    
    if (item.role == YMRTCRole_Callee) {
        if (item.chatState < YMRTCState_Connected) {
            //作为接收者, 还没接听，对方已取消
            self.dataItem.chatState = YMRTCState_Close_Caller_Cancel;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
        
    } else {
        //作为发起者收到通话结束请求
        if (item.chatState < YMRTCState_Connected) {
            //如果还在拨打中,接收方拒绝
            self.dataItem.chatState = YMRTCState_BusyReceiver;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
    }
    
    [self.dataItem closeRtcCall:YES];
    [self RTC_DataItemStatusChanged:self.dataItem];
}

- (void)RTC_DataItemDidReceivedSystemCalling:(YMRTCDataItem *)item {
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (item.role == YMRTCRole_Caller) {
            //如果是发起者
            if (item.chatState < YMRTCState_Connected) {
                //如果还在拨打中
                self.dataItem.chatState = YMRTCState_Close_Caller_Cancel;
            } else {
                //如果是在通话中
                self.dataItem.chatState = YMRTCState_Close;
            }
        } else {
            if (item.chatState < YMRTCState_Connected) {
                //如果还在拨打中
                self.dataItem.chatState = YMRTCState_Close_Callee_Refuse;
            } else {
                //如果是在通话中
                self.dataItem.chatState = YMRTCState_Close;
            }
        }
        
        [self.dataItem closeRtcCall:YES];
        [self hide];
    });
}

- (void)RTC_DataItem:(YMRTCDataItem *)item didSocketError:(NSInteger)errorCode {
    //对方在系统电话忙线中
    [self destoryCallingTimer];
    
    if (item.role == YMRTCRole_Callee) {
        if (item.chatState < YMRTCState_Connected) {
            //作为接收者, 还没接听，对方已取消
            self.dataItem.chatState = YMRTCState_DialingError;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
        
    } else {
        //作为发起者收到通话结束请求
        if (item.chatState < YMRTCState_Connected) {
            //如果还在拨打中,包好失败
            self.dataItem.chatState = YMRTCState_DialingError;
        } else {
            //正常通话
            self.dataItem.chatState = YMRTCState_Close;
        }
    }
    
    [self.dataItem closeRtcCall:YES];
    [self RTC_DataItemStatusChanged:self.dataItem];
}

- (void)RTC_DataItemDidFeedbackSystemCalling:(YMRTCDataItem *)item {
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.dataItem.chatState = YMRTCState_Close_Callee_Refuse;
        [self.dataItem closeRtcCall:YES];
        [self hide];
    });
}

- (void)RTC_DataItemDidSwapToAudio:(YMRTCDataItem *)item {
    //切换到语音
    [self.callingView swapAudioBtnClick:nil];
}

#pragma mark - YMRTCCallingViewDelegate
- (void)callingViewDidHangupBtnClick:(YMRTCCallingView *)callingView {
    [self destoryCallingTimer];
    //点击挂断
    NSString *hudTip;
    
    if (self.dataItem.role == YMRTCRole_Caller) {
        //如果是发起者
        if (self.dataItem.chatState < YMRTCState_Connected) {
            //如果还在拨打中
            hudTip = Localized(@"RTC_Tip_Cannel");//取消通话
        } else {
            hudTip = Localized(@"RTC_Tip_Close");//通话结束
        }
    } else {
        //如果是接收者
        hudTip = Localized(@"RTC_Tip_Close");//通话结束
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hudTip) ShowWinMessage(hudTip);
    });

    [self performSelector:@selector(hide) withObject:nil afterDelay:2];
}

- (void)callingViewDidRefuseBtnClick:(YMRTCCallingView *)callingView {
    //接收者点击拒绝按钮
    self.dataItem.chatState = YMRTCState_Close_Callee_Refuse;
    [self.dataItem closeRtcCall:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        ShowWinMessage(Localized(@"RTC_Tip_Close"));
    });
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:2];
}

- (void)callingViewDidAcceptBtnClick:(YMRTCCallingView *)callingView {
    //接收者点击接听按钮
    [self.dataItem createOffers];
}

- (void)callingViewDidSwapAudioBtnClick:(YMRTCCallingView *)callingView {
    //点击切换语音

    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self removeAllRenderer];
        [self removeAllVideoView];
    });
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

- (void)RTC_DataItemDisconnected:(YMRTCDataItem *)item {
    self.dataItem.chatState = YMRTCState_DisConnect;
    [self.dataItem closeRtcCall:YES];
    [self RTC_DataItemStatusChanged:self.dataItem];
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
            make.center.equalTo(self.view);
        }];
    } else {
        self.remoteWidth = tempWidth;
        self.remoteHeight = tempHeight;
        
        [self.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tempHeight);
            make.width.mas_equalTo(tempWidth);
            make.center.equalTo(self.view);
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
    });
}

- (void)exchangeLocalAndRemote:(UITapGestureRecognizer *)tap {
    if (tap.view == self.localVideoView) {
        [self.view sendSubviewToBack:self.localVideoView];
        
        [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.height.mas_equalTo(self.localHeight);
            make.width.mas_equalTo(self.localWidth);
        }];
        
        [self.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(self.view.mas_top).with.offset(kIs_iPhoneX ? 44 : 20);
            make.height.mas_equalTo(self.remoteHeight/4);
            make.width.mas_equalTo(self.remoteWidth/4);
        }];
        
        [self.view bringSubviewToFront:self.remoteVideoView];
        
    } else {
        [self.view sendSubviewToBack:self.remoteVideoView];
        
        [self.remoteVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.height.mas_equalTo(self.remoteHeight);
            make.width.mas_equalTo(self.remoteWidth);
        }];
        
        [self.localVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(self.view.mas_top).with.offset(kIs_iPhoneX ? 44 : 20);
            make.height.mas_equalTo(self.localHeight/4);
            make.width.mas_equalTo(self.localWidth/4);
        }];
        
        
        [self.view bringSubviewToFront:self.localVideoView];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
    });
}


#pragma mark - getter
- (YMRTCCallingView *)callingView {
    if (!_callingView) {
        _callingView = [[YMRTCCallingView alloc] initWithDataItem:self.dataItem];
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
//        _remoteVideoView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    return _remoteVideoView;
}


@end
