//
//  TSRTCCallingView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RTCRole) {
    TSRTCRole_Caller,
    TSRTCRole_Callee
};

typedef NS_ENUM(NSInteger, RTCChatType) {
    RTCChatType_Audio,
    RTCChatType_Video
};

typedef NS_ENUM(NSInteger, RTCConnectType) {

    RTCConnectType_Dialing,    //拨号中
    RTCConnectType_Calling,    //发起者：呼叫中 被呼叫者：等待接受
    RTCConnectType_Connecting, //连接中
    RTCConnectType_Connected,  //已连接
    RTCConnectType_DisConnect, //异常断开连接
    RTCConnectType_BusyReceiver, //对方忙线
    RTCConnectType_DialingError, //拨号失败
    RTCConnectType_ConnectingError, //连接失败
    RTCConnectType_Close, //关闭
};


@class TSRTCCallingView , FriendsModel;

@protocol TSRTCCallingViewDelegate <NSObject>

@optional
- (void)rtcCallingViewDidHangupClick:(TSRTCCallingView *)callingView;//挂断
- (void)rtcCallingViewDidRefuseClick:(TSRTCCallingView *)callingView;//拒绝

- (void)rtcCallingViewDidReceiveMpushHang:(TSRTCCallingView *)callingView;//收到mpush的挂断

- (void)rtcCallingViewDidAcceptClick:(TSRTCCallingView *)callingView;//接听
- (void)rtcCallingViewSwitchToAudio:(TSRTCCallingView *)callingView;//切换到语音

- (void)rtcCallingView:(TSRTCCallingView *)callingView didMuteClick:(BOOL)isSilence;//是否静音
- (void)rtcCallingView:(TSRTCCallingView *)callingView didHFClick:(BOOL)isHF;//是否免提
- (void)rtcCallingView:(TSRTCCallingView *)callingView switchCamera:(BOOL)isFont;//是否前置

@end

@interface TSRTCCallingView : UIView

- (instancetype)initWithRole:(RTCRole)role chatType:(RTCChatType)chatType;

@property (nonatomic, weak) id <TSRTCCallingViewDelegate> delegate;
@property (nonatomic, assign) RTCConnectType contenctType;
@property (nonatomic, strong) FriendsModel *receiveModel;

- (void)removeBlurView;
- (void)initOperateViews;
- (void)swapToAudio;

- (NSTimeInterval)getCallDuration;

@end
