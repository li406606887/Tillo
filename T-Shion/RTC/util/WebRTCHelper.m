//
//  WebRTCHelper.m
//  WebScoketTest
//
//  Created by 涂耀辉 on 17/3/1.
//  Copyright © 2017年 涂耀辉. All rights reserved.
//

//  WebRTCHelper.m
//  WebRTCDemo
//


#import "WebRTCHelper.h"
#import <UIKit/UIKit.h>
#import "GSKeyChainDataManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "NetworkModel.h"
#import "TSRTCChatViewController.h"
#import "ALCameraRecordViewController.h"

#import "YMEncryptionManager.h"

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



typedef enum : NSUInteger {
    //发送者
    RoleCaller,
    //被发送者
    RoleCallee,
} Role;

@interface WebRTCHelper ()<RTCPeerConnectionDelegate> {
    SRWebSocket *_socket;
    NSString *_server;
    NSString *_room;
    NSString *_port;
    
    RTCMediaStream *_localStream;
    
    NSString *_myId;
    Role _role;
    
    NSArray *_receiverIds;
    
    NSString *_chatType;//1.single 2.group
    
    NSString *_type;//1.audio 2.video
    
    NSTimer *heartBeat;
    
    BOOL _isReceiver;
}

@property (nonatomic, strong) RTCAudioTrack *localAudioTrack;

@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) NSMutableArray *connectionIdArray;
@property (nonatomic, strong) NSMutableDictionary *connectionDic;
@property (nonatomic, copy) NSArray *ICEServers;
@property (nonatomic, strong) RTCConfiguration *RTCConfig;
@property (nonatomic, strong) RTCAVFoundationVideoSource *localVideoSource;
@property (nonatomic, assign) NSInteger socketTimerDuration;

@property (nonatomic, strong) CTCallCenter *callCenter;//系统电话监听
@property (nonatomic, assign) BOOL isSystemCalling;//当前是否在进行系统电话

@property (nonatomic, assign) NSTimeInterval reconnectTime;
@property (nonatomic, assign) BOOL isReconnecting;//是否处于重连状态


@end

@implementation WebRTCHelper

static WebRTCHelper *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

/**
 *  与服务器建立连接
 *
 *  @param server 服务器地址
 *  @param room   房间号
 */
- (void)connectServer:(NSString *)server
                 port:(NSString *)port
                 room:(NSString *)room
             chatType:(NSString *)chatType
                 type:(NSString *)type
          receiverIds:(NSArray *)receiverIds
           isReceiver:(BOOL)isReceiver {
    _inCalling = YES;
    _server = server;
    _port = port;
    _room = room;
    _chatType = chatType;
    _type = type;
    _receiverIds = receiverIds;
    _isReceiver = isReceiver;
    
    if (!_localStream) [self createLocalStream];
    
    NSString *resquestStr;
#ifdef AilloTest
    resquestStr = [NSString stringWithFormat:@"ws://%@:%@/ws",server,port];
    self.socketTimerDuration = 2;
#endif
    
#ifdef AilloRelease
    resquestStr = [NSString stringWithFormat:@"wss://%@/ws",server];
    self.socketTimerDuration = 10;
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


#pragma mark - socket心跳相关
//初始化心跳
- (void)initHeartBeat {
    NSLog(@"初始化心跳");
    
    @weakify(self);
    dispatch_main_async_safe(^{
        @strongify(self);
        [self destoryHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        self->heartBeat = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(sendHeart) userInfo:nil repeats:YES];
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [[NSRunLoop currentRunLoop] addTimer:self->heartBeat forMode:NSRunLoopCommonModes];
    })
}

//取消心跳
- (void)destoryHeartBeat {
    @weakify(self);
    dispatch_main_async_safe(^{
        @strongify(self);
        if (self->heartBeat) {
            [self->heartBeat invalidate];
            self->heartBeat = nil;
        }
    })
}

- (void)sendHeart {
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"ping",
                                                             @"mySocketId":self->_myId,
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
        [self connectServer:self->_server
                       port:self->_port
                       room:self->_room
                   chatType:self->_chatType
                       type:self->_type
                receiverIds:self->_receiverIds
                 isReceiver:self->_isReceiver];
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

#pragma mark - websocket操作
/**
 *  加入房间
 *  @param room 房间号
 */
- (void)joinRoom:(NSString *)room {
    
    if (_socket.readyState == SR_OPEN) {
        //加入单聊rtc在私密房间发起时的处理
        NSString *remoteIdentity = @"";
        if (_receiverIds.count > 0)
        {//remoteIdentity 是从加密房间发起需要的，服务端获取密聊离线提醒时需要的
            NSString *temp = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:[_receiverIds firstObject]];
            if (temp)
                remoteIdentity = temp;
        }
        
        
        NSDictionary *dic = @{@"cmd":@"join",
                              @"type":_type,
                              @"chatType":_chatType,
                              @"roomId":_room,
                              @"status":_isReceiver ? @"offline":@"",
                              @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                              @"deviceId":[GSKeyChainDataManager readUUID],
                              @"remoteIdentityKey":remoteIdentity
                              };
        
        NSMutableDictionary *parmas = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (!_isReceiver) {//接收方不需要传receivers
            [parmas setObject:_receiverIds forKey:@"receivers"];
        }
        
        NSLog(@"加入房间参数%@",parmas);
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:parmas
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [_socket send:paramStr];
        
        _isCameraFront = YES;
        _isMicrophone = YES;
    }
}

/**
 *  退出房间
 */
- (void)exitRoom:(BOOL)isCancel {
    _inCalling = NO;
    NSString *senderToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (_myId != nil && senderToken != nil) {
        
        NSDictionary *dic;
        if (isCancel) {
            dic = @{@"cmd":@"close_room",
                    @"socketId":_myId,
                    @"status":@"cancel",
                    @"sender":senderToken,
                    @"deviceId":[GSKeyChainDataManager readUUID]
                    };
        } else {
            dic = @{@"cmd":@"close_room",
                    @"socketId":_myId,
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
    }
    
    _localStream = nil;
    _localVideoSource = nil;
    _localAudioTrack = nil;
    
    @weakify(self)
    [self.connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        [self closePeerConnection:obj];
    }];
    
    
    [self SRWebSocketClose];
    
    self.callCenter = nil;
    self.isSystemCalling = NO;
    self.isReconnecting = NO;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

//收到邀请时如果处于忙线中给对方反馈
- (void)feedbackSystemCalling {
    
    if (_socket.readyState == SR_OPEN) {
        
        NSDictionary *dic = @{@"cmd":@"systemBusy",
                              @"receivers":_receiverIds,
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

    if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSystemCalling:isBusyReceivers:)]) {
        [self.delegate webRTCHelperDidSystemCalling:self isBusyReceivers:NO];
    }
}

- (void)reconnectWithOldSocketId:(NSString *)socketId {
    NSDictionary *dic = @{@"cmd":@"reconnect",
                          @"socketId":_myId,
                          @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                          @"deviceId":[GSKeyChainDataManager readUUID]
                          };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket send:param];
}

//切换到语音
- (void)swapToAuido {
    if (_socket.readyState != SR_OPEN) {
        NSLog(@"----------------还没连接成功");
        return;
    }
    NSLog(@"----------------切换语音");
    _type = @"audio";
    NSDictionary *dic = @{@"cmd":@"swapped",
                          @"roomId":_room,
                          @"socketId":_myId,
                          @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                          @"deviceId":[GSKeyChainDataManager readUUID]
                          };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_socket send:param];
    [self unmuteVideoIn];
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
    
    if ([self.delegate respondsToSelector:@selector(webRTCHelper:closeWithUserId:)]) {
        [self.delegate webRTCHelper:self closeWithUserId:connectionId];
    }
}

/**
 *  创建本地流，并且把本地流回调出去
 */
- (void)createLocalStream {
    
    _localStream = [self.factory mediaStreamWithStreamId:kMediaStreamId];
    
    //音频
    RTCAudioTrack *localAudioTrack = [self.factory audioTrackWithTrackId:kAudioTrackID];
    [_localStream addAudioTrack:localAudioTrack];

    if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelper:setLocalAudioTrack:)]) {
        [self.delegate webRTCHelper:self setLocalAudioTrack:localAudioTrack];
    }
    
    if ([_type isEqualToString:@"audio"]) return;
    
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [deviceArray lastObject];
    //检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelper:setLocalVideoTrack:)]) {
            [self.delegate webRTCHelper:self setLocalVideoTrack:nil];
        }
    } else {
        if (!device) {
            NSLog(@"该设备不能打开摄像头");
            if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelper:setLocalVideoTrack:)]) {
                [self.delegate webRTCHelper:self setLocalVideoTrack:nil];
            }
            return;
        }
        
        RTCVideoTrack *localVideoTrack = [self.factory videoTrackWithSource:self.localVideoSource trackId:kVideoTrackId];
        [_localStream addVideoTrack:localVideoTrack];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelper:setLocalVideoTrack:)]) {
            [self.delegate webRTCHelper:self setLocalVideoTrack:localVideoTrack];
        }
    }
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

#pragma mark - offer和answer
/**
 *  为所有连接创建offer
 */
- (void)createOffers {
    //给每一个点对点连接，都去创建offer
    @weakify(self)
    [self.connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        @strongify(self)
        self->_role = RoleCaller;
        
        NSLog(@"========RTC角色改变createOffers=======");
        
        [obj offerForConstraints:[self offerOranswerConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            @strongify(self)
            NSLog(@"========peerConnection创建offer=======");
            [self peerConnection:obj didCreateSessionDescription:sdp error:error];
        }];
    }];
}

/**
 *  为所有连接添加流
 */
- (void)addStreams {
    //给每一个点对点连接，都加上本地流
    @weakify(self)
    [self.connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        @strongify(self)
        if (!self->_localStream) [self createLocalStream];
        
        [obj addStream:self->_localStream];
    }];
}

/**
 *  创建所有连接
 */
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
 *  创建点对点连接
 *
 *  @param connectionId <#connectionId description#>
 *
 *  @return <#return value description#>
 */
- (RTCPeerConnection *)createPeerConnection:(NSString *)connectionId {
    //用工厂来创建连接
    RTCPeerConnection *connection = [self.factory peerConnectionWithConfiguration:self.RTCConfig
                                                                      constraints:[self peerConnectionConstraints]
                                                                         delegate:self];
    
    return connection;
}

/**
 *  peerConnection约束
 *
 *  @return <#return value description#>
 */
- (RTCMediaConstraints *)peerConnectionConstraints {
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : @"ture"};
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
    
    return constraints;
}

/**
 *  设置offer/answer的约束
 */
- (RTCMediaConstraints *)offerOranswerConstraint {
    
    NSString *status = [_type isEqualToString:@"audio"] ? @"false":@"true";
    
    NSDictionary *mandatoryConstraints = @{@"OfferToReceiveAudio" : @"ture",
                                           @"OfferToReceiveVideo":status};
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    
    return constraints;
}

#pragma mark--RTCSessionDescriptionDelegate
//创建了一个SDP就会被调用，（只能创建本地的）
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error {
    //设置本地的SDP
    if (error) {
        NSLog(@"peerconnection delegate create session error  -----%@",error);
        return;
    }
    
    @weakify(self);
    [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
        @strongify(self);
        NSLog(@"========peerConnection设置Local=======");
        [self peerConnection:peerConnection didSetSessionDescriptionWithError:error];
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
        
    } else if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer) {//判断连接状态为本地发送offer
        if (_role == RoleCallee) {
            
            NSLog(@"========RTC角色改变RTCSignalingStateHaveLocalOffer=======");
            NSLog(@"=======RoleCallee========");
            
            NSLog(@"========socket发送answer=======");
            NSDictionary *dic = @{@"cmd":@"answer",
                                  @"roomId":_room,
                                  @"socketId":currentId,
                                  @"sdp":peerConnection.localDescription.sdp,
                                  @"sender":[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                                  @"deviceId":[GSKeyChainDataManager readUUID]
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *param = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [_socket send:param];
        } else if(_role == RoleCaller) {//发送者,发送自己的offer
            NSLog(@"========RTC角色改变RTCSignalingStateHaveLocalOffer=======");
            NSLog(@"=======RoleCaller========");
            
            NSLog(@"========socket发送offer=======");
            
            NSDictionary *dic = @{@"cmd":@"offer",
                                  @"roomId":_room,
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
        if (_role == RoleCallee) {
            NSLog(@"========RTC角色改变RTCSignalingStateStable=======");
            NSLog(@"=======RoleCallee========");
            NSLog(@"========socket发送answer=======");
            NSDictionary *dic = @{@"cmd":@"answer",
                                  @"roomId":_room,
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

#pragma mark--RTCPeerConnectionDelegate
// 拿到远程流
- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    NSLog(@"========拿到远程流=======");
    
    NSString *uid = [self getKeyFromConnectionDic : peerConnection];
    if ([self.delegate respondsToSelector:@selector(webRTCHelper:addRemoteStream:userId:)]) {
        [self.delegate webRTCHelper:self addRemoteStream:stream userId:uid];
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    NSLog(@"========ice连接状态改变======");
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        if (newState == RTCIceConnectionStateDisconnected) {
            NSString *currentId = [self getKeyFromConnectionDic:peerConnection];
            if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelper:disConnectWithUserId:)]) {
                [self.delegate webRTCHelper:self disConnectWithUserId:currentId];
            }
        }
    });
}

//创建peerConnection之后，从server得到响应后调用，得到ICE 候选地址
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    NSString *currentId = [self getKeyFromConnectionDic : peerConnection];
    NSDictionary *dic = @{@"cmd": @"ice_candidate",
                          @"roomId":_room,
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


#pragma mark--SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (webSocket != _socket) return;
    
    NSLog(@"收到服务器消息:%@",message);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *eventName = dic[@"cmd"];
    
    //1.发送加入房间后的反馈
    if ([eventName isEqualToString:@"join"]) {
        
        NSArray *connections = dic[@"otherIds"];//得到所有者的socketId的连接
        NSArray *busyReceivers = dic[@"busyReceivers"];
        NSString *rtcServer = dic[@"rtcServer"];
        
        _myId = dic[@"socketId"]; //拿到给自己分配的ID
        
        [self.connectionIdArray addObjectsFromArray:connections];//把其他人ID加到连接数组中去
        
        //创建连接
        [self createPeerConnections];
        
        //添加
        [self addStreams];
        
        if (_socket && _socket.readyState == SR_OPEN) {
            [self initHeartBeat];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(webRTCHelper:didJoinRoom:busyReceivers:rtcServer:)]) {
            [_delegate webRTCHelper:self didJoinRoom:_myId busyReceivers:busyReceivers rtcServer:rtcServer];
        }
        
        if (_isReceiver) {
            if ([dic[@"swapped"] boolValue]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSwapToAudio:)]) {
                    [self.delegate webRTCHelperDidSwapToAudio:self];
                }
            }
        }
        
    } else if ([eventName isEqualToString:@"ice_candidate"]) {//4.接收到新加入的人发了ICE候选，（即经过ICEServer而获取到的地址）
        NSString *socketId = dic[@"socketId"];
        NSString *sdpMid = dic[@"id"];
        NSInteger sdpMLineIndex = [dic[@"label"] integerValue];
        NSString *sdp = dic[@"candidate"];
        
        //生成远端网络地址对象
        RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:(int)sdpMLineIndex sdpMid:sdpMid];
        
        //拿到当前对应的点对点连接
        RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:socketId];
        
        //添加到点对点连接中
        [peerConnection addIceCandidate:candidate];
    } else if ([eventName isEqualToString:@"new_peer"]) {//2.其他新人加入房间的信息
        //拿到新人的ID
        NSString *socketId = dic[@"socketId"];
        if ([socketId isEqualToString:_myId]) return;
        
        RTCPeerConnection *peerConnection = [self createPeerConnection:socketId];
        
        if (!_localStream) [self createLocalStream];
        
        [peerConnection addStream:_localStream];
        [self.connectionIdArray addObject:socketId];
        [self.connectionDic setObject:peerConnection forKey:socketId];
        
        if (_delegate && [_delegate respondsToSelector:@selector(webRTCHelper:didJoinNewPeer:)]) {
            [_delegate webRTCHelper:self didJoinNewPeer:socketId];
        }
        
    } else if ([eventName isEqualToString:@"remove_peer"]) {//有人离开房间的事件
        //得到socketId，关闭这个peerConnection
        NSString *socketId = dic[@"socketId"];
        if (![socketId isEqualToString:_myId]) {
            [self closePeerConnection:socketId];
        }
        
    } else if ([eventName isEqualToString:@"offer"]) {//这个新加入的人发了个offer  拿到SDP
        NSString *sdp = dic[@"sdp"];
        NSString *socketId = dic[@"socketId"];
        if ([socketId isEqualToString:_myId]) return;
        
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
        _role = RoleCallee;
        NSLog(@"========RTC角色改变eventName offer=======");
        
    } else if ([eventName isEqualToString:@"answer"]) {//回应offer
        NSString *sdp = dic[@"sdp"];
        NSString *socketId = dic[@"socketId"];
        if ([socketId isEqualToString:_myId]) return;
        
        RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:socketId];
        
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdp];
        
        @weakify(self);
        [peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
            @strongify(self);
            [self peerConnection:peerConnection didSetSessionDescriptionWithError:error];
        }];
        
    } else if ([eventName isEqualToString:@"swapped"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSwapToAudio:)]) {
            [self.delegate webRTCHelperDidSwapToAudio:self];
        }
    } else if ([eventName isEqualToString:@"cancel"]) {
        if ([self.delegate respondsToSelector:@selector(webRTCHelper:closeWithUserId:)]) {
            [self.delegate webRTCHelper:self closeWithUserId:nil];
        }
    } else if ([eventName isEqualToString:@"error"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperSocketError:errorCode:)]) {
            [self.delegate webRTCHelperSocketError:self errorCode:[dic[@"status"] integerValue]];
        }
    } else if ([eventName isEqualToString:@"busy"]) {
        //接收方处于忙线中
        if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperOtherIsBusy:)]) {
            [self.delegate webRTCHelperOtherIsBusy:self];
        }
    } else if ([eventName isEqualToString:@"systemBusy"]) {
        //对方处于系统电话忙线中
        if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSystemCalling:isBusyReceivers:)]) {
            [self.delegate webRTCHelperDidSystemCalling:self isBusyReceivers:YES];
        }
    } else if ([eventName isEqualToString:@"reconnect"]) {
        //重连成功后
        NSLog(@"-----重连成功------");
        NSString *socketId = dic[@"socketId"];
        _myId = socketId;
        self.isReconnecting = NO;
        self.reconnectTime = 0;
        [self initHeartBeat];
    } else if ([eventName isEqualToString:@"onceSend"]) {
        MessageModel *msgModel = [[MessageModel alloc] init];
        msgModel.messageId = [NSString stringWithFormat:@"%@",dic[@"id"]];
        msgModel.roomId = [NSString stringWithFormat:@"%@",dic[@"roomId"]];
        msgModel.sender = [NSString stringWithFormat:@"%@",dic[@"sender"]];;
        msgModel.timestamp = [NSDate getNowTimestamp];
        msgModel.readStatus = @"0";
        if ([dic[@"type"] isEqualToString:@"audio"]) {
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

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"websocket建立成功");
    
    self.callCenter = nil;
    self.callCenter = [[CTCallCenter alloc] init];
    if ([self.callCenter.currentCalls count] > 0) {
        //这边判断当前是否在通话中
        self.isSystemCalling = YES;
        [self feedbackSystemCalling];
        return;
    } else {
        self.isSystemCalling = NO;
    }
    
    @weakify(self);
    self.callCenter.callEventHandler = ^(CTCall * call) {
        @strongify(self);
        if([call.callState isEqualToString:CTCallStateDisconnected]) {
            NSLog(@"Call has been disconnected");//电话被挂断(我们用的这个)
            self.isSystemCalling = NO;
        } else if([call.callState isEqualToString:CTCallStateConnected]) {
            NSLog(@"Call has been connected");//电话被接听
            if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSystemCalling:isBusyReceivers:)]) {
                [self.delegate webRTCHelperDidSystemCalling:self isBusyReceivers:NO];
            }
            self.isSystemCalling = YES;
        } else if([call.callState isEqualToString:CTCallStateIncoming]) {
            NSLog(@"Call is incoming");//来电话了
            if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSystemCalling:isBusyReceivers:)]) {
                [self.delegate webRTCHelperDidSystemCalling:self isBusyReceivers:NO];
            }
            self.isSystemCalling = YES;
        } else if([call.callState isEqualToString:CTCallStateDialing]) {
            NSLog(@"Call is Dialing");//拨号
            if (self.delegate && [self.delegate respondsToSelector:@selector(webRTCHelperDidSystemCalling:isBusyReceivers:)]) {
                [self.delegate webRTCHelperDidSystemCalling:self isBusyReceivers:NO];
            }
            self.isSystemCalling = YES;
        } else {
            NSLog(@"Nothing is done");
        }
    };

    if (self.isReconnecting && _myId.length > 0) {
        NSLog(@"-----发送重连cmd------%@",_myId);
        [self reconnectWithOldSocketId:_myId];
    } else {
        [self joinRoom:_room];
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
#pragma mark 设置扬声器还是听筒
- (void)setIsSpeakerEnabled:(BOOL)isSpeakerEnabled {//Use the "handsfree" speaker instead of the ear speaker.
    _isSpeakerEnabled = isSpeakerEnabled;
    if (isSpeakerEnabled) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}
#pragma mark 设置音频关闭还是开启
- (void)setIsMicrophone:(BOOL)isMicrophone {
    _isMicrophone = isMicrophone;
    isMicrophone ? [self muteAudioIn] : [self unmuteAudioIn];
}
- (void)muteAudioIn {
    NSLog(@"audio muted");
    self.localAudioTrack = _localStream.audioTracks[0];
    [_localStream removeAudioTrack:_localStream.audioTracks[0]];
}
- (void)unmuteAudioIn {
    NSLog(@"audio unmuted");
    if (!self.localAudioTrack) {
        self.isMicrophone = YES;
        return;
    }
    [_localStream addAudioTrack:self.localAudioTrack];
}
#pragma mark 设置前后摄像头
- (void)setIsCameraFront:(BOOL)isCameraFront {
    _isCameraFront = isCameraFront;
    isCameraFront ? [self swapCameraToFront] : [self swapCameraToBack];
}

- (void)swapCameraToFront{
    self.localVideoSource.useBackCamera = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(webRTCHelper:didSwitchCamera:localStream:)]) {
        [_delegate webRTCHelper:self didSwitchCamera:YES localStream:_localStream];
    }
}

- (void)swapCameraToBack {
    self.localVideoSource.useBackCamera = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(webRTCHelper:didSwitchCamera:localStream:)]) {
        [_delegate webRTCHelper:self didSwitchCamera:YES localStream:_localStream];
    }
}

- (void)unmuteVideoIn {
    NSLog(@"video unmuted");
    if (self.connectionIdArray.count == 0) {
        return;
    }
    NSString *peerID = self.connectionIdArray[0];
    RTCPeerConnection *peerConnection = [self.connectionDic objectForKey:peerID];
    [_localStream removeVideoTrack:_localStream.videoTracks[0]];
    
    [peerConnection removeStream:_localStream];
    [peerConnection addStream:_localStream];
}

- (RTCMediaConstraints *)defaultMediaStreamConstraints {
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
    return constraints;
}

#pragma mark - getter and setter
- (RTCPeerConnectionFactory *)factory {
    if (!_factory) {
        _factory = [[RTCPeerConnectionFactory alloc] init];
    }
    return _factory;
}

- (RTCAVFoundationVideoSource *)localVideoSource {
    if (!_localVideoSource) {
        _localVideoSource = [self.factory avFoundationVideoSourceWithConstraints:[self localVideoConstraints]];
    }
    return _localVideoSource;
}

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

//add by chw 2019.04.20 for "处理rtc的一些奇奇怪怪的bug"
- (void)initiatingData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error ;
        RequestModel *model = [TSRequest getRequetWithApi:api_get_initiating withParam:nil error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSString *data = [NSString ym_decryptAES:model.data];
                NSDictionary *dic = [NSString dictionaryWithJsonString:data];
                [self operateInitiatingData:dic];
                NSLog(@"initiating接口返回:%@", dic);
            }
        });
    });
}

- (void)operateInitiatingData:(NSDictionary *)dataDict {
    
    NSString *roomID = [NSString stringWithFormat:@"%@",dataDict[@"roomId"]];
    NSString *type = [dataDict objectForKey:@"type"];
    NSString *receiverHost = [dataDict objectForKey:@"rtcServer"];
    NSString *senderStr = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"sender"]];
    NSString *messageId = [NSString stringWithFormat:@"%@",dataDict[@"id"]];
    FriendsModel *receiveModel = [FMDBManager selectFriendTableWithUid:senderStr];
    

    NSArray *otherInitiateArray = dataDict[@"otherInitiateModels"];
    if (otherInitiateArray.count > 0) {
        for (NSDictionary *otherDict in otherInitiateArray) {
            NSString *msgId = [NSString stringWithFormat:@"%@",otherDict[@"id"]];
            NSString *roomId = [NSString stringWithFormat:@"%@",otherDict[@"roomId"]];
            NSString *senderId = [NSString stringWithFormat:@"%@",otherDict[@"sender"]];
            
            MessageModel *msgModel = [[MessageModel alloc] init];
            msgModel.messageId = msgId;
            msgModel.roomId = roomId;
            msgModel.sender = senderId;
            msgModel.timestamp = [NSDate getNowTimestamp];
            msgModel.readStatus = @"0";
            msgModel.rtcStatus = RTCMessageStatus_OthersCancel;
            [FMDBManager insertMessageWithContentModel:msgModel];
            [FMDBManager insertSessionOnlineWithType:@"singleChat" message:msgModel withCount:1];
        }
    }
    
    RTCChatType chatType;
    if ([type isEqualToString:@"video"]) {
        chatType = RTCChatType_Video;
    } else {
        chatType = RTCChatType_Audio;
    }
    
    UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
    if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
        return;
    }
    
    TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Callee
                                                                           chatType:chatType
                                                                             roomID:roomID
                                                                     receiveIDArray:@[senderStr] receiveHostURL:receiverHost];
    chatVC.receiveModel = receiveModel;
    chatVC.messageId = messageId;
    
    if ([topVC isKindOfClass:[ALCameraRecordViewController class]]) {
        [topVC dismissViewControllerAnimated:NO completion:^{
            UIViewController *tempVC = (UIViewController *)[SocketViewModel getTopViewController];
            [tempVC presentViewController:chatVC animated:YES completion:nil];
        }];
        
    } else {
        [topVC presentViewController:chatVC animated:YES completion:nil];
    }
}

@end
