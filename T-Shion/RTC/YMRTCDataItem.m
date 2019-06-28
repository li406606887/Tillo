//
//  YMRTCDataItem.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "YMRTCDataItem.h"
#import <SocketRocket/SocketRocket.h>
#import "YMEncryptionManager.h"
#import "GSKeyChainDataManager.h"
#import "TSSoundManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>


NSString * const kYMRTCHangNoti = @"kYMRTCHangNoti";
NSString * const kYMRTCBusyNoti = @"kYMRTCBusyNoti";

static NSString *const kSocketServer = @"websocket.aillo.cc";
//google提供的
static NSString *const RTCSTUNServerURL = @"stun:3.0.143.131:3478";
static NSString *const RTCSTUNServerURL2 = @"stun:39.108.48.52:3478";//深圳服务器
static NSString *const RTCSTUNServerURL3 = @"stun:47.75.55.117:3478";//香港服务器
//static NSString *const RTCSTUNServerURL4 = @"54.169.146.98:3478";

//static NSString *const RTCTUNServerURL = @"turn:54.169.146.98:3478";
static NSString *const RTCTUNServerURL = @"turn:3.0.143.131:3478";
static NSString *const RTCTUNServerURL2 = @"turn:39.108.48.52:3478";//深圳服务器
static NSString *const RTCTUNServerURL3 = @"turn:47.75.55.117:3478";//香港服务器

static NSString *const kMediaStreamId = @"ARDAMS";
static NSString *const kAudioTrackID = @"ARDAMSa0";
static NSString *const kVideoTrackId = @"ARDAMSv0";

@interface YMRTCDataItem ()<SRWebSocketDelegate, RTCPeerConnectionDelegate> {
    SRWebSocket *_socket;
    NSString *_mySocketId;
    NSTimer *heartBeat;
}
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCConfiguration *RTCConfig;
@property (nonatomic, copy) NSArray *ICEServers;

@property (nonatomic, strong) NSMutableArray *connectionIdArray;
@property (nonatomic, strong) NSMutableDictionary *connectionDic;

@property (nonatomic, strong) RTCMediaStream *localStream;
@property (nonatomic, strong) RTCAVFoundationVideoSource *localVideoSource;

//socket重连
@property (nonatomic, assign) NSTimeInterval reconnectTime;
@property (nonatomic, assign) BOOL isReconnecting;//是否处于重连状态

@property (nonatomic, strong) RTCAudioTrack *localAudioTrack;

@property (nonatomic, assign) BOOL hangupYourSelf;

@property (nonatomic, strong) MessageModel *recordModel;

@property (nonatomic, strong) CTCallCenter *callCenter;//系统电话监听

@end

@implementation YMRTCDataItem

- (void)dealloc {
    [[TSSoundManager sharedManager] stop];
    NSLog(@"---YMRTCDataItem销毁了--");
}

#pragma mark - 初始化
- (instancetype)initWithChatType:(YMRTCChatType)chatType
                            role:(YMRTCRole)role
                          roomId:(NSString *)roomId
                   otherInfoData:(FriendsModel *)otherInfoData {
    if (self = [super init]) {
        _chatType = chatType;
        _currentChatType = chatType;
        _role = role;
        _roomId = [NSString stringWithFormat:@"%@",roomId];
        _isMicrophone = YES;//默认: 不静音
        _otherInfoData = otherInfoData;
        //记录相关
        self.recordModel.type = chatType == YMRTCChatType_Audio ? @"rtc_audio" : @"rtc_video";
        self.recordModel.content = chatType == YMRTCChatType_Audio ? @"RTC_Msg_Audio" : @"RTC_Msg_Video";
        self.recordModel.roomId = [NSString stringWithFormat:@"%@",roomId];
        if (!_messageId) {
            self.recordModel.messageId = [NSUUID UUID].UUIDString;
        }
        
        if (role == YMRTCRole_Caller) {
            self.recordModel.sender = [SocketViewModel shared].userModel.ID;
            self.recordModel.sendType = SelfSender;
            self.recordModel.sendStatus = @"1";
        } else {
            self.recordModel.sendType = OtherSender;
        }
    }
    return self;
}

#pragma mark - 公共方法
- (void)startRtcCalling {
    self.chatState = YMRTCState_Dialing;
    if (!_localStream) {
        [self createLocalStream];
    }
    [self initWebSocket];
}

- (void)closeRtcCall:(BOOL)hangupYourSelf {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TSSoundManager sharedManager] playCloseSound];
    });
    self.hangupYourSelf = hangupYourSelf;
    [self exitRoom];
    [self saveRtcRecord];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

- (void)pushRtcCalling {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"call" forKey:@"cmd"];
    [param setObject:@"single" forKey:@"chatType"];
    [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
    [param setObject:@[self.otherInfoData.userId] forKey:@"receivers"];
    [param setObject:self.roomId forKey:@"roomId"];//加密房间要修改
    
    if (_currentChatType == YMRTCChatType_Video) {
        [param setObject:@"video" forKey:@"type"];//类型音频 视频
    } else {
        [param setObject:@"audio" forKey:@"type"];
    }
    
    NSString *remoteIdentity = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:self.otherInfoData.userId];
    if (remoteIdentity)
        [param setObject:remoteIdentity forKey:@"remoteIdentityKey"];
    
    NSString *jsonString = [NSString dictionaryToJson:param];
    NSDictionary *paramAes = @{@"EncryptAESkey":[NSString ym_encryptAES:jsonString]};
    
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        RequestModel *model = [TSRequest postRequetWithApi:api_post_call withParam:paramAes error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (!error && [model.status intValue] == 200) {
                //拨号成功,创建offer
                self.chatState = YMRTCState_Calling;
                [self createOffers];
            } else {
                //拨号失败
                self.chatState = YMRTCState_DialingError;
                [self closeRtcCall:YES];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemStatusChanged:)]) {
                [self.delegate RTC_DataItemStatusChanged:self];
            }
        });
    });
}

- (void)swapToAudio {
    _currentChatType = YMRTCChatType_Audio;
    if (_socket.readyState != SR_OPEN) return;
    
    NSDictionary *dic = @{@"cmd":@"swapped",
                          @"roomId":_roomId,
                          @"socketId":_mySocketId,
                          @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                          @"deviceId":[GSKeyChainDataManager readUUID]
                          };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket send:param];
    
    [self unmuteVideoIn];
    self.isSpeakerEnabled = NO;
}

- (void)saveRtcRecord {
    YMRTCRecordType recordType;
    int unreadCount = 0;
    //保存记录
    if (self.role == YMRTCRole_Caller) {
        //如果是拨打者
        switch (self.chatState) {
            case YMRTCState_DisConnect:
                recordType = YMRTCRecordType_DisConnect;
                break;
                
            case YMRTCState_BusyReceiver:
                recordType = YMRTCRecordType_BusyReceiver;
                break;
                
            case YMRTCState_DialingError:
                recordType = YMRTCRecordType_DialingError;
                break;
                
            case YMRTCState_ConnectingError:
                recordType = YMRTCRecordType_ConnectingError;
                break;
                
            case YMRTCState_Close_Caller_Cancel:
                recordType = YMRTCRecordType_Cancel;
                break;
                
            case YMRTCState_Close_Caller_Timeout:
                recordType = YMRTCRecordType_Timeout;
                break;
                
            case YMRTCState_Close_Callee_Refuse:
                recordType = YMRTCRecordType_Refuse;
                break;
                
            case YMRTCState_Close:
                recordType = YMRTCRecordType_Close;
                break;
                
            default:
                recordType = YMRTCRecordType_Cancel;
                break;
        }
    } else {
        unreadCount = 1;
        //如果是接收者
        switch (self.chatState) {
            case YMRTCState_BusyReceiver:
                recordType = YMRTCRecordType_BusyReceiver;
                break;
                
            case YMRTCState_DialingError:
                recordType = YMRTCRecordType_DialingError;
                break;
                
            case YMRTCState_ConnectingError:
                recordType = YMRTCRecordType_ConnectingError;
                break;
                
            case YMRTCState_Close_Caller_Cancel:
                recordType = YMRTCRecordType_Cancel;
                break;
                
                
            case YMRTCState_Close_Callee_Refuse:
                recordType = YMRTCRecordType_Refuse;
                unreadCount = 0;
                break;
                
            case YMRTCState_Close:
                recordType = YMRTCRecordType_Close;
                unreadCount = 0;
                break;
                
            default:
                recordType = YMRTCRecordType_Cancel;
                break;
        }
    }
    
    self.recordModel.rtcStatus = recordType;
    self.recordModel.timestamp = [NSDate getNowTimestamp];
    if (self.chatState == YMRTCState_Close || self.chatState == YMRTCState_DisConnect) {
        //如果正常通话或者异常断开，记录时长
        NSInteger duration = (NSInteger)self.callDuration;
        if (duration == 0) duration = 1;
        self.recordModel.duration = [NSString stringWithFormat:@"%ld",duration];
    }
    
    if (self.role == YMRTCRole_Callee) {
        self.recordModel.senderInfo = self.otherInfoData;
    }
    self.recordModel.sendStatus = @"1";

    if (![FMDBManager isAlreadyHadMsg:self.recordModel]) {
        [FMDBManager insertSessionOnlineWithType:@"singleChat" message:self.recordModel withCount:unreadCount];
    }
    [FMDBManager insertMessageWithContentModel:self.recordModel];


    if ([self.roomId isEqualToString:[SocketViewModel shared].room]) {
        [[SocketViewModel shared].sendMessageSubject sendNext:self.recordModel];
    }
    
    [[SocketViewModel shared].getUnreadSessionSubject sendNext:nil];
}

#pragma mark - WebSocket 相关
- (void)initWebSocket {
    NSString *resquestStr;
    
#ifdef AilloTest
    resquestStr = [NSString stringWithFormat:@"ws://%@:%@/ws",RTCHostUrl,@"8005"];
#endif

#ifdef AilloRelease
    NSString *serverURL = self.role == YMRTCRole_Caller ? kSocketServer : self.receiveHostURL;
    resquestStr = [NSString stringWithFormat:@"wss://%@/ws",serverURL];
#endif
    
    NSURL *requestURL = [NSURL URLWithString:resquestStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10];
    
    _socket = [[SRWebSocket alloc] initWithURLRequest:request];
    _socket.delegate = self;
    [_socket open];
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setMode:AVAudioSessionModeVoiceChat error:nil];
    
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
}

- (void)joinRtcRoom {
    if (_socket.readyState != SR_OPEN) return;
    //加入单聊rtc在私密房间发起时的处理
    //是从加密房间发起需要的，服务端获取密聊离线提醒时需要的
    NSString *remoteIdentity = @"";
    NSString *temp = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:_otherInfoData.userId];
    if (temp) remoteIdentity = temp;
    
    NSString *type = _currentChatType == YMRTCChatType_Audio ? @"audio" : @"video";

    NSDictionary *dic = @{@"cmd":@"join",
                          @"type":type,
                          @"chatType":@"single",
                          @"roomId":_roomId,
                          //接收者必须要传offline,为了判断发起者是否在线
                          @"status":_role == YMRTCRole_Callee ? @"offline":@"",
                          @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                          @"deviceId":[GSKeyChainDataManager readUUID],
                          @"remoteIdentityKey":remoteIdentity
                          };

    NSMutableDictionary *parmas = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (_role == YMRTCRole_Caller) {//发起方需要传,接收方不需要传receivers
        [parmas setObject:@[_otherInfoData.userId] forKey:@"receivers"];
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:parmas
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [_socket send:paramStr];
}

- (void)reconnectWithOldSocketId:(NSString *)socketId {
    NSDictionary *dic = @{@"cmd":@"reconnect",
                          @"socketId":socketId,
                          @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                          @"deviceId":[GSKeyChainDataManager readUUID]
                          };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket send:param];
}

- (void)exitRoom {
    NSString *senderToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (_mySocketId != nil && senderToken != nil) {
        
        //判断是取消拨打，还是挂断
        BOOL isCancel = _chatState <= YMRTCState_Calling && _role == YMRTCRole_Caller;
        
        NSDictionary *dic;
        if (isCancel) {
            dic = @{@"cmd":@"close_room",
                    @"socketId":_mySocketId,
                    @"status":@"cancel",
                    @"sender":senderToken,
                    @"deviceId":[GSKeyChainDataManager readUUID]
                    };
        } else {
            dic = @{@"cmd":@"close_room",
                    @"socketId":_mySocketId,
                    @"sender":senderToken,
                    @"deviceId":[GSKeyChainDataManager readUUID]
                    };
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (_socket.readyState == SR_OPEN) {
            [_socket send:param];
        }
    } else {
        //如果还没加入房间调用http挂断请求
        [self hangupRequest];
    }
    
    _localStream = nil;
    _localVideoSource = nil;
    _localAudioTrack = nil;
    
    [self closeAllPeerConnection];
    [self SRWebSocketClose];
    
    self.callCenter = nil;
    self.isReconnecting = NO;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

- (void)hangupRequest {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:@[self.otherInfoData.userId] forKey:@"receivers"];
    [param setObject:self.otherInfoData.roomId forKey:@"roomId"];
    
    NSString *type = _currentChatType == YMRTCChatType_Video ? @"video" : @"audio";
    [param setObject:type forKey:@"type"];//类型音频 视频
    
    NSString *jsonString = [NSString dictionaryToJson:param];
    NSDictionary *paramAes = @{@"EncryptAESkey":[NSString ym_encryptAES:jsonString]};
    [[SocketViewModel shared].postCancelRTCCommand execute:paramAes];
}

#pragma mark - WebSocket心跳相关
- (void)initHeartBeat {
    @weakify(self)
    dispatch_main_async_safe(^{
        @strongify(self)
        [self destoryHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        self->heartBeat = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(sendHeart) userInfo:nil repeats:YES];
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [[NSRunLoop currentRunLoop] addTimer:self->heartBeat forMode:NSRunLoopCommonModes];
    })
}

- (void)destoryHeartBeat {
    //取消心跳
    @weakify(self)
    dispatch_main_async_safe(^{
        @strongify(self)
        if (self->heartBeat) {
            [self->heartBeat invalidate];
            self->heartBeat = nil;
        }
    })
}

- (void)sendHeart {
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"ping",
                                                             @"mySocketId":_mySocketId,
                                                             @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                                                             @"deviceId":[GSKeyChainDataManager readUUID]} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    dispatch_queue_t queue =  dispatch_queue_create("aillo.rtc.websocket", NULL);
    
    @weakify(self);
    dispatch_async(queue, ^{
        @strongify(self);
        if (self->_socket) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (self->_socket.readyState == SR_OPEN) {
                [self->_socket send:param];    // 发送数据
                NSLog(@"-----发送ping");
            } else if (self->_socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                [self reconnectWebSocket];
                
            } else if (self->_socket.readyState == SR_CLOSING || self->_socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                
                NSLog(@"断开重连重连");
                
                [self reconnectWebSocket];
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
            NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
        }
    });
}

- (void)reconnectWebSocket {
    self.isReconnecting = YES;
    [self SRWebSocketClose];
    
    //超过15秒就不再重连 所以只会重连3次
    if (self.reconnectTime > 16) {
        //您的网络状况不是很好，请检查网络后重试
        return;
    }
    
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        self->_socket = nil;
        [self initWebSocket];
        NSLog(@"---------重连-----------");
    });
    
    //重连时间2的指数级增长
    if (self.reconnectTime == 0) {
        self.reconnectTime = 2;
    } else {
        self.reconnectTime *= 2;
    }
}

- (void)SRWebSocketClose {
    if (_socket){
        [_socket close];
    }
    
    _socket = nil;
    //断开连接时销毁心跳
    [self destoryHeartBeat];
}

#pragma mark -
- (void)addSystemCallingObserve {
    self.callCenter = nil;
    self.callCenter = [[CTCallCenter alloc] init];
    if ([self.callCenter.currentCalls count] > 0) {
        //作为接受者，在进行系统电话，收到RTC邀请，要给对方反馈以及主动挂断
        [self feedbackSystemCalling];
        
        //这边要进行主动挂断操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemDidFeedbackSystemCalling:)]) {
            [self.delegate RTC_DataItemDidFeedbackSystemCalling:self];
        }
        return;
    }
    
    
    @weakify(self);
    self.callCenter.callEventHandler = ^(CTCall * call) {
        @strongify(self);
        BOOL isSystemCalling;
        
        if ([call.callState isEqualToString:CTCallStateDisconnected]) {
            NSLog(@"Call has been disconnected");//电话被挂断
        } else if ([call.callState isEqualToString:CTCallStateConnected]) {
            NSLog(@"Call has been connected");//电话被接听
            isSystemCalling = YES;
        } else if ([call.callState isEqualToString:CTCallStateIncoming]) {
            NSLog(@"Call is incoming");//来电话了
            isSystemCalling = YES;
        } else if ([call.callState isEqualToString:CTCallStateDialing]) {
            NSLog(@"Call is Dialing");//拨号
            isSystemCalling = YES;
        } else {
            NSLog(@"Nothing is done");
        }
        
        if (isSystemCalling) {
            //如果接收到系统电话
            [self feedbackSystemCalling];
            if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemDidReceivedSystemCalling:)]) {
                [self.delegate RTC_DataItemDidReceivedSystemCalling:self];
            }
        }
    };
}


#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"【RTC】-> websocket建立成功");
    [self addSystemCallingObserve];
    if (self.isReconnecting && _mySocketId.length > 0) {
        NSLog(@"-----发送重连cmd------%@",_mySocketId);
        [self reconnectWithOldSocketId:_mySocketId];
    } else {
        [self joinRtcRoom];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (webSocket != _socket) return;
    NSLog(@"【RTC】-> 收到服务器消息:%@",message);
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *eventName = dataDict[@"cmd"];
    
    if ([eventName isEqualToString:@"join"])
    {
        //发送加入房间后的反馈
        [self handleJoinEvent:dataDict];
    }
    else if ([eventName isEqualToString:@"ice_candidate"])
    {
        //接收到新加入的人发了ICE候选，（即经过ICEServer而获取到的地址）
        [self handleIceCandidateEvent:dataDict];
    }
    else if ([eventName isEqualToString:@"new_peer"])
    {
        //其他新人加入房间的信息
        [self handleNewPeerEvent:dataDict];
    }
    else if ([eventName isEqualToString:@"remove_peer"])
    {
        //有人离开房间的事件
        [self handleRemovePeerEvent:dataDict];
    }
    else if ([eventName isEqualToString:@"offer"])
    {
        //这个新加入的人发了个offer  拿到SDP
        [self handleOfferEvent:dataDict];
    }
    else if ([eventName isEqualToString:@"answer"])
    {
        //回应offer
        [self handleAnswerEvent:dataDict];
    }
    else if ([eventName isEqualToString:@"swapped"])
    {
        //切换到语音
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemDidSwapToAudio:)]) {
            [self.delegate RTC_DataItemDidSwapToAudio:self];
        }
    }
    else if ([eventName isEqualToString:@"cancel"])
    {
        //作为接收者, 还没接听，对方已取消
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItem:didRemovePeer:)]) {
            [self.delegate RTC_DataItem:self didRemovePeer:@""];
        }
    }
    else if ([eventName isEqualToString:@"error"])
    {
        //服务端返回的socket报错
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItem:didSocketError:)]) {
            [self.delegate RTC_DataItem:self didSocketError:[dataDict[@"status"] integerValue]];
        }
    }
    else if ([eventName isEqualToString:@"busy"])
    {
        //接收方处于忙线中
        if (_role == YMRTCRole_Caller) {
            self.chatState = YMRTCState_BusyReceiver;
            [self closeRtcCall:YES];
            if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemStatusChanged:)]) {
                [self.delegate RTC_DataItemStatusChanged:self];
            }
        }
    }
    else if ([eventName isEqualToString:@"systemBusy"])
    {
        //对方处于系统电话忙线中
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemDidOtherSystemCalling:)]) {
            [self.delegate RTC_DataItemDidOtherSystemCalling:self];
        }
    }
    else if ([eventName isEqualToString:@"reconnect"])
    {
        //重连成功后
        NSLog(@"-----重连成功------");
        NSString *socketId = dataDict[@"socketId"];
        _mySocketId = socketId;
        self.isReconnecting = NO;
        self.reconnectTime = 0;
        [self initHeartBeat];
    }
    else if ([eventName isEqualToString:@"onceSend"])
    {
        //在拨打或者通话过程中有别人给你拨打
        MessageModel *msgModel = [[MessageModel alloc] init];
        msgModel.messageId = [NSString stringWithFormat:@"%@",dataDict[@"id"]];
        msgModel.roomId = [NSString stringWithFormat:@"%@",dataDict[@"roomId"]];
        msgModel.sender = [NSString stringWithFormat:@"%@",dataDict[@"sender"]];;
        msgModel.timestamp = [NSDate getNowTimestamp];
        msgModel.readStatus = @"0";
        if ([dataDict[@"type"] isEqualToString:@"audio"]) {
            msgModel.type = @"rtc_audio";
            msgModel.content = @"RTC_Msg_Audio";
        } else {
            msgModel.type = @"rtc_video";
            msgModel.content = @"RTC_Msg_Video";
        }
        
        msgModel.rtcStatus = RTCMessageStatus_OthersCancel;
        [FMDBManager insertMessageWithContentModel:msgModel];
        [FMDBManager insertSessionOnlineWithType:@"singleChat" message:msgModel withCount:1];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%s",__func__);
    NSLog(@"%ld:%@",(long)error.code, error.localizedDescription);
    
    if (webSocket == _socket) {
        NSLog(@"************************** socket 连接失败************************** ");
        _socket = nil;
        //连接失败就重连
        [self reconnectWebSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"%s",__func__);
    NSLog(@"%ld:%@",(long)code, reason);
    
    [self SRWebSocketClose];
}

#pragma mark - WebSocket 收到消息处理相关
- (void)handleJoinEvent:(NSDictionary *)dataDict {
    NSArray *connections = dataDict[@"otherIds"];//得到所有者的socketId的连接
    NSArray *busyReceivers = dataDict[@"busyReceivers"];
    
    _mySocketId = dataDict[@"socketId"]; //拿到给自己分配的ID
    
    if (_socket && _socket.readyState == SR_OPEN) {
        //加入房间成功之后发送心跳
        [self initHeartBeat];
    }
    
    [self.connectionIdArray addObjectsFromArray:connections];//把其他人ID加到连接数组中去
    
    [self createPeerConnections];//创建点对点连接
    [self addLocalStreamToPeerConnection];//添加本地流
    
    BOOL isBusyReceivers = busyReceivers.count > 0;
    
    if (_role == YMRTCRole_Caller) {
        if (isBusyReceivers) {
            //如果对方忙线
            self.chatState = YMRTCState_BusyReceiver;
            [self closeRtcCall:YES];
            if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemStatusChanged:)]) {
                [self.delegate RTC_DataItemStatusChanged:self];
            }
        } else {
           [self pushRtcCalling];//如果是发起者，发送rtc请求
        }
    } else {
        //如果是接收者这是已加入房间并等待接收的状态
        self.chatState = YMRTCState_Calling;
    }
    
    //加入房间成功回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItem:didJoinRoom:)]) {
        [self.delegate RTC_DataItem:self didJoinRoom:isBusyReceivers];
    }

    //如果是接收者,且当前已从视频通话切换到语音通话
    if (_role == YMRTCRole_Callee && [dataDict[@"swapped"] boolValue]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemDidSwapToAudio:)]) {
            [self.delegate RTC_DataItemDidSwapToAudio:self];
        }
    }
}

- (void)handleIceCandidateEvent:(NSDictionary *)dataDict {
    //4.接收到新加入的人发了ICE候选，（即经过ICEServer而获取到的地址）
    NSString *socketId = dataDict[@"socketId"];
    NSString *sdpMid = dataDict[@"id"];
    NSInteger sdpMLineIndex = [dataDict[@"label"] integerValue];
    NSString *sdp = dataDict[@"candidate"];
    
    //生成远端网络地址对象
    RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:(int)sdpMLineIndex sdpMid:sdpMid];
    
    //拿到当前对应的点对点连接
    RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:socketId];
    
    //添加到点对点连接中
    [peerConnection addIceCandidate:candidate];
}

- (void)handleNewPeerEvent:(NSDictionary *)dataDict {
    //其他新人加入房间的信息
    NSString *socketId = dataDict[@"socketId"];
    if ([socketId isEqualToString:_mySocketId]) return;
    
    RTCPeerConnection *peerConnection = [self createPeerConnection:socketId];
    
    if (!_localStream) [self createLocalStream];
    
    [peerConnection addStream:_localStream];
    [self.connectionIdArray addObject:socketId];
    [self.connectionDic setObject:peerConnection forKey:socketId];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItem:didJoinNewPeer:)]) {
        [self.delegate RTC_DataItem:self didJoinNewPeer:socketId];
    }
}

- (void)handleRemovePeerEvent:(NSDictionary *)dataDict {
    //得到socketId，关闭这个peerConnection
    NSString *socketId = dataDict[@"socketId"];
    if (![socketId isEqualToString:_mySocketId]) {
        [self closePeerConnection:socketId];
    }
}

- (void)handleOfferEvent:(NSDictionary *)dataDict {
    //作为发起者则变成开始连接状态
    self.chatState = YMRTCState_Connecting;
    
    //这个新加入的人发了个offer  拿到SDP
    NSString *sdp = dataDict[@"sdp"];
    NSString *socketId = dataDict[@"socketId"];
    if ([socketId isEqualToString:_mySocketId]) return;
    
    //拿到这个点对点的连接
    RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:socketId];
    
    //根据类型和SDP 生成SDP描述对象
    RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdp];
    
    __weak  RTCPeerConnection *weakPeerConnection = peerConnection;
    @weakify(self);
    [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
        @strongify(self);
        [self peerConnection:weakPeerConnection didSetSessionDescriptionWithError:error];
    }];
    
    //设置当前角色状态为被呼叫，（被发offer）
//    _role = RoleCallee;
}

- (void)handleAnswerEvent:(NSDictionary *)dataDict {
    NSString *sdp = dataDict[@"sdp"];
    NSString *socketId = dataDict[@"socketId"];
    if ([socketId isEqualToString:_mySocketId]) return;
    
    RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:socketId];
    
    RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdp];
    
    __weak  RTCPeerConnection *weakPeerConnection = peerConnection;
    @weakify(self);
    [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
        @strongify(self);
        [self peerConnection:weakPeerConnection didSetSessionDescriptionWithError:error];
    }];
}

#pragma mark - 系统电话相关
//收到邀请时如果处于忙线中给对方反馈
- (void)feedbackSystemCalling {
    
    if (_socket.readyState == SR_OPEN) {
        
        NSDictionary *dic = @{@"cmd":@"systemBusy",
                              @"receivers":@[self.otherInfoData.userId],
                              @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                              @"deviceId":[GSKeyChainDataManager readUUID]
                              };
        
        NSLog(@"%@",dic);
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [_socket send:param];
    }
}


#pragma mark - offer 和 answer
/** 为所有连接创建offer */
- (void)createOffers {
    //给每一个点对点连接，都去创建offer
    @weakify(self)
    [self.connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        @strongify(self)
        
        [obj offerForConstraints:[self offerOranswerConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            @strongify(self)
            NSLog(@"========peerConnection创建offer=======");
            [self peerConnection:obj didCreateSessionDescription:sdp error:error];
        }];
    }];
}



/** 创建点对点连接 */
- (void)createPeerConnections {
    //从我们的连接数组里快速遍历
    
    @weakify(self)
    [self.connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //根据连接ID去初始化 RTCPeerConnection 连接对象
        @strongify(self)
        RTCPeerConnection *connection = [self createPeerConnection:obj];
        //设置这个ID对应的 RTCPeerConnection对象
        [self.connectionDic setObject:connection forKey:obj];
    }];
}

/**
 创建点对点连接

 @param connectionId 连接对象Id
 @return 点对点连接对象
 */
- (RTCPeerConnection *)createPeerConnection:(NSString *)connectionId {
    //用工厂来创建连接
    RTCPeerConnection *connection = [self.factory peerConnectionWithConfiguration:self.RTCConfig
                                                                      constraints:[self peerConnectionConstraints]
                                                                         delegate:self];
    
    return connection;
}

/** peerConnection约束 */
- (RTCMediaConstraints *)peerConnectionConstraints {
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : @"ture"};
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
    
    return constraints;
}

/** 为所有点对点连接添加本地流 */
- (void)addLocalStreamToPeerConnection {
    @weakify(self)
    [self.connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        @strongify(self)
        if (!self.localStream) [self createLocalStream];
        
        [obj addStream:self.localStream];
    }];
}

- (void)createLocalStream {
    _localStream = [self.factory mediaStreamWithStreamId:kMediaStreamId];
    //音频
    RTCAudioTrack *localAudioTrack = [self.factory audioTrackWithTrackId:kAudioTrackID];
    [_localStream addAudioTrack:localAudioTrack];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItem:didAddLocalAudioTrack:)]) {
        [self.delegate RTC_DataItem:self didAddLocalAudioTrack:localAudioTrack];
    }
    //如果是语音通话则无需创建视频流
    if (_currentChatType == YMRTCChatType_Audio) return;
    
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [deviceArray lastObject];
    //检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        NSLog(@"没有视频权限");
    } else {
        if (!device) {
            NSLog(@"该设备不能打开摄像头");
            return;
        }
        
        //添加本地视频流
        RTCVideoTrack *localVideoTrack = [self.factory videoTrackWithSource:self.localVideoSource trackId:kVideoTrackId];
        [_localStream addVideoTrack:localVideoTrack];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItem:didAddLocalVideoTrack:)]) {
            [self.delegate RTC_DataItem:self didAddLocalVideoTrack:localVideoTrack];
        }
    }
}


/** 关闭所有peerConnection */
- (void)closeAllPeerConnection {
    @weakify(self)
    [self.connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        [self closePeerConnection:obj];
    }];
}

/**
 *  关闭peerConnection
 *
 *  @param connectionId <#connectionId description#>
 */
- (void)closePeerConnection:(NSString *)connectionId {
    RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:connectionId];
    if (peerConnection) [peerConnection close];
    
    [self.connectionIdArray removeObject:connectionId];
    [self.connectionDic removeObjectForKey:connectionId];
    
    if (self.hangupYourSelf) return;//如果自己挂断不需要重复调用
    if ([self.delegate respondsToSelector:@selector(RTC_DataItem:didRemovePeer:)]) {
        [self.delegate RTC_DataItem:self didRemovePeer:connectionId];
    }
}

/**
 *  设置offer/answer的约束
 */
- (RTCMediaConstraints *)offerOranswerConstraint {
    
    NSString *status = _currentChatType == YMRTCChatType_Audio ? @"false":@"true";
    
    NSDictionary *mandatoryConstraints = @{@"OfferToReceiveAudio" : @"ture",
                                           @"OfferToReceiveVideo":status};
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    
    return constraints;
}


#pragma mark - 约束相关
/**
 *  视频的相关约束
 */
- (RTCMediaConstraints *)localVideoConstraints {
    
    NSDictionary *optionalConstraints = @{kRTCMediaConstraintsMinWidth:@"1280",
                                          kRTCMediaConstraintsMinHeight:@"720",
                                          kRTCMediaConstraintsMinFrameRate:@"15",
                                          kRTCMediaConstraintsMaxFrameRate:@"30",
                                          };
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
    return constraints;
}

- (RTCMediaConstraints *)defaultMediaAudioConstraints {
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{}
                                                                             optionalConstraints:nil];
    return constraints;
}

#pragma mark RTCSessionDescriptionDelegate
//创建了一个SDP就会被调用，（只能创建本地的）
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error {
    //设置本地的SDP
    if (error) {
        NSLog(@"peerconnection delegate create session error  -----%@",error);
        return;
    }
    
    __weak  RTCPeerConnection *weakPeerConnection = peerConnection;
    @weakify(self);
    [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"========peerConnection设置Local=======");
        [self peerConnection:weakPeerConnection didSetSessionDescriptionWithError:error];
    }];
}

//当一个远程或者本地的SDP被设置就会调用
- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    if (error) {
        NSLog(@"----------sdp错误-----------------");
        NSLog(@"peerconnection delegate session description error  -----%@",error);
        return;
    }
    
    NSString *currentId = [self getKeyFromConnectionDic : peerConnection];
    //判断，当前连接状态为，收到了远程点发来的offer，这个是进入房间的时候，尚且没人，来人就调到这里
    if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer) {
        //创建一个answer,会把自己的SDP信息返回出去
        @weakify(self);
        NSLog(@"========peerConnection创建answer=======");

        [peerConnection answerForConstraints:[self offerOranswerConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            @strongify(self);
            [self peerConnection:peerConnection didCreateSessionDescription:sdp error:error];
        }];

    }
    else if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer)
    {
        //判断连接状态为本地发送offer,接收者需要createOffer
        
        if (_role == YMRTCRole_Callee) {
            NSLog(@"========socket发送offer=======");
            NSDictionary *dic = @{@"cmd":@"offer",
                                  @"roomId":_roomId,
                                  @"socketId":currentId,
                                  @"sdp":peerConnection.localDescription.sdp,
                                  @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                                  @"deviceId":[GSKeyChainDataManager readUUID]
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [_socket send:param];
        }
    } else if (peerConnection.signalingState == RTCSignalingStateStable) {
        if (_role == YMRTCRole_Caller) {
            //发起者收到接收者的offer,回应answer
            NSLog(@"========socket发送answer=======");
            NSDictionary *dic = @{@"cmd":@"answer",
                                  @"roomId":_roomId,
                                  @"socketId":currentId,
                                  @"sdp":peerConnection.localDescription.sdp,
                                  @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                                  @"deviceId":[GSKeyChainDataManager readUUID]
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [_socket send:param];
        }
    }
}

- (NSString *)getKeyFromConnectionDic:(RTCPeerConnection *)peerConnection {
    //find socketid by pc
    static NSString *socketId;
    [self.connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:peerConnection]) {
            NSLog(@"%@",key);
            socketId = key;
        }
    }];
    return socketId;
}

#pragma mark--RTCPeerConnectionDelegate
// 拿到远程流
- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    NSLog(@"========拿到远程流=======");
    
//    NSString *uid = [self getKeyFromConnectionDic : peerConnection];
    self.chatState = YMRTCState_Connected;
    if ([self.delegate respondsToSelector:@selector(RTC_DataItem:didAddRemoteStream:)]) {
        [self.delegate RTC_DataItem:self didAddRemoteStream:stream];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    NSLog(@"========ice连接状态改变======");
    if (newState == RTCIceConnectionStateDisconnected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(RTC_DataItemDisconnected:)]) {
            [self.delegate RTC_DataItemDisconnected:self];
        }
    }
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        @strongify(self);
//        if (newState == RTCIceConnectionStateDisconnected) {
//            NSString *currentId = [self getKeyFromConnectionDic:peerConnection];
//            if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelper:disConnectWithUserId:)]) {
//                [self.delegate webRTCHelper:self disConnectWithUserId:currentId];
//            }
//        }
//    });
}

//创建peerConnection之后，从server得到响应后调用，得到ICE 候选地址
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    NSString *currentId = [self getKeyFromConnectionDic : peerConnection];
    NSDictionary *dic = @{@"cmd": @"ice_candidate",
                          @"roomId":_roomId,
                          @"id":candidate.sdpMid,
                          @"label":[NSNumber numberWithInteger:candidate.sdpMLineIndex],
                          @"candidate": candidate.sdp,
                          @"socketId": currentId,
                          @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                          @"deviceId":[GSKeyChainDataManager readUUID]
                          };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket send:param];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel {
    NSLog(@"=====通道打开=====");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream {}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {}

#pragma mark - 操作按钮相关
- (void)setIsMicrophone:(BOOL)isMicrophone {
    //设置是否静音
    _isMicrophone = isMicrophone;
    isMicrophone ? [self muteAudioIn] : [self unmuteAudioIn];
}

- (void)muteAudioIn {
    //静音
    NSLog(@"audio muted");
    self.localAudioTrack = _localStream.audioTracks[0];
    [_localStream removeAudioTrack:_localStream.audioTracks[0]];
}

- (void)unmuteAudioIn {
    //非静音
    NSLog(@"audio unmuted");
    if (!self.localAudioTrack) {
        self.isMicrophone = YES;
        return;
    }
    [_localStream addAudioTrack:self.localAudioTrack];
}

- (void)setIsSpeakerEnabled:(BOOL)isSpeakerEnabled {
    //是否免提
    _isSpeakerEnabled = isSpeakerEnabled;
    if (isSpeakerEnabled) {
        NSLog(@"---切换到扬声器");
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        NSLog(@"---切换到听筒");
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}

- (void)unmuteVideoIn {
    NSLog(@"video unmuted");
    if (self.connectionIdArray.count == 0) return;
    NSString *peerID = self.connectionIdArray[0];
    RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:peerID];
    [_localStream removeVideoTrack:_localStream.videoTracks[0]];
    
    [peerConnection removeStream:_localStream];
    [peerConnection addStream:_localStream];
}

- (void)setIsCameraFront:(BOOL)isCameraFront {
    _isCameraFront = isCameraFront;
    self.localVideoSource.useBackCamera = !isCameraFront;
}

#pragma mark - getter
- (NSMutableDictionary *)connectionDic {
    if (!_connectionDic) {
        _connectionDic = [NSMutableDictionary dictionary];
    }
    return _connectionDic;
}

- (NSMutableArray *)connectionIdArray {
    if (!_connectionIdArray) {
        _connectionIdArray = [NSMutableArray array];
    }
    return _connectionIdArray;
}

- (RTCPeerConnectionFactory *)factory {
    if (!_factory) {
        _factory = [[RTCPeerConnectionFactory alloc] init];
    }
    return _factory;
}

- (NSArray *)ICEServers {
    if (!_ICEServers) {
        
        RTCIceServer *server1 = [[RTCIceServer alloc] initWithURLStrings:@[RTCSTUNServerURL]];
        RTCIceServer *server2 = [[RTCIceServer alloc] initWithURLStrings:@[RTCSTUNServerURL3]];
        
        RTCIceServer *server3 = [[RTCIceServer alloc] initWithURLStrings:@[RTCTUNServerURL] username:@"kurento" credential:@"kurento"];
        
        RTCIceServer *server4 = [[RTCIceServer alloc] initWithURLStrings:@[RTCTUNServerURL3] username:@"kurento" credential:@"kurento"];
        
        _ICEServers = @[server1,server2,server3,server4];
    }
    return _ICEServers;
}

- (RTCConfiguration *)RTCConfig {
    if (!_RTCConfig) {
        _RTCConfig = [[RTCConfiguration alloc] init];
        _RTCConfig.shouldPruneTurnPorts = YES;
        _RTCConfig.iceServers = self.ICEServers;
    }
    return _RTCConfig;
}

- (RTCAVFoundationVideoSource *)localVideoSource {
    if (!_localVideoSource) {
        _localVideoSource = [self.factory avFoundationVideoSourceWithConstraints:[self localVideoConstraints]];
    }
    return _localVideoSource;
}

- (MessageModel *)recordModel {
    if (!_recordModel) {
        _recordModel = [[MessageModel alloc] init];
    }
    return _recordModel;
}

#pragma mark - setter
- (void)setMessageId:(NSString *)messageId {
    _messageId = messageId;
    _recordModel.messageId = [NSString stringWithFormat:@"%@",messageId];
}

@end
