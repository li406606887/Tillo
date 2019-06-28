//
//  WebRTCHelper.h
//  WebScoketTest
//
//  Created by 涂耀辉 on 17/3/1.
//  Copyright © 2017年 涂耀辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import <WebRTC/WebRTC.h>
#import <WebRTC/RTCMacros.h>

@protocol WebRTCHelperDelegate;

@interface WebRTCHelper : NSObject<SRWebSocketDelegate>


@property (assign, nonatomic) BOOL inCalling;//在通话中

@property (assign, nonatomic) BOOL isSpeakerEnabled;//是否是扬声器 yes 扬声器 no 听筒;
@property (assign, nonatomic) BOOL isMicrophone;//是否使用麦克风 yes 使用 no 静音;
@property (assign, nonatomic) BOOL isCameraFront;//前后摄像头 yes前置 no后置;

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id <WebRTCHelperDelegate> delegate;

/**
 *  与服务器建立连接
 *
 *  @param server 服务器地址
 @pram  port   端口号
 *  @param room   房间号
 */
- (void)connectServer:(NSString *)server
                 port:(NSString *)port
                 room:(NSString *)room
             chatType:(NSString *)chatType
                 type:(NSString *)type
          receiverIds:(NSArray *)receiverIds
           isReceiver:(BOOL)isReceiver;


/**
 *  为所有连接创建offer
 */
- (void)createOffers;

/**
 *  切换到语音
 */
- (void)swapToAuido;

/**
 *  退出房间
 */
- (void)exitRoom:(BOOL)isCancel;

- (void)initiatingData;

@end

@protocol WebRTCHelperDelegate <NSObject>

@optional

//加入房间成功
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper didJoinRoom:(NSString *)userID busyReceivers:(NSArray *)busyReceivers rtcServer:(NSString *)rtcServer;

//新成员加入
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper didJoinNewPeer:(NSString *)userID;

//拿到本地流
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper setLocalAudioTrack:(RTCAudioTrack *)audioTrack;
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper setLocalVideoTrack:(RTCVideoTrack *)videoTrack;

//拿到远程流
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper addRemoteStream:(RTCMediaStream *)stream userId:(NSString *)userId;

//关闭
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper closeWithUserId:(NSString *)userId;

//连接成功
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper disConnectWithUserId:(NSString *)userId;

//切换摄像头
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper didSwitchCamera:(BOOL)isCameraFront localStream:(RTCMediaStream *)stream;

//切换语音
- (void)webRTCHelperDidSwapToAudio:(WebRTCHelper *)webRTChelper;

- (void)webRTCHelperSocketError:(WebRTCHelper *)webRTChelper errorCode:(NSInteger)errorCode;

/**
 系统电话忙线状态

 @param webRTChelper  webRTChelper
 @param isBusyReceivers  YES:对方忙线 NO:自己处于忙线，通知对方
 */
- (void)webRTCHelperDidSystemCalling:(WebRTCHelper *)webRTChelper isBusyReceivers:(BOOL)isBusyReceivers;

//对方处于RTC忙线状态
- (void)webRTCHelperOtherIsBusy:(WebRTCHelper *)webRTCHelper;

//加入房间后对方已经退出房间
- (void)webRTCHelperDidJoinRoomAndOtherHadCancel:(WebRTCHelper *)webRTChelper;



@end
