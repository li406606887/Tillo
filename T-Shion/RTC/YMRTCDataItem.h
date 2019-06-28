//
//  YMRTCDataItem.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import <WebRTC/RTCMacros.h>

UIKIT_EXTERN NSString *const kYMRTCHangNoti;//挂断通知
UIKIT_EXTERN NSString *const kYMRTCBusyNoti;//忙线通知

typedef NS_ENUM(NSInteger, YMRTCRole) {
    YMRTCRole_Caller,//发起者
    YMRTCRole_Callee//接收者
};

typedef NS_ENUM(NSInteger, YMRTCChatType) {
    YMRTCChatType_Audio,//语音通话
    YMRTCChatType_Video//视频通话
};

typedef NS_ENUM(NSInteger, YMRTCState) {
    //发起者：拨号中,http请求成功之后socket连接成功才算拨号成功 被呼叫者：socket连接中的状态,加入房间中
    YMRTCState_Dialing = 1,
    YMRTCState_Calling = 2,               //发起者：呼叫中 被呼叫者：等待接受
    YMRTCState_Connecting = 3,            //连接中：ice穿透连接的状态
    YMRTCState_Connected = 4,             //已连接：连接成功正常通话
    YMRTCState_DisConnect = 5,            //异常断开连接
    YMRTCState_BusyReceiver = 6,          //接收方忙线
    YMRTCState_DialingError = 7,          //拨号失败
    YMRTCState_ConnectingError = 8,       //连接失败
    YMRTCState_Close_Caller_Cancel = 9,   //通话结束:还没接听，拨打方取消
    YMRTCState_Close_Caller_Timeout = 10, //通话结束:还没接听，拨打方由于拨打时间过长取消
    YMRTCState_Close_Callee_Refuse = 11,  //通话结束:还没接听，接收方拒绝
    YMRTCState_Close = 12,                //正常的通话结束关闭
};

typedef NS_ENUM(NSInteger, YMRTCRecordType) {
    YMRTCRecordType_Cancel = 10,//拨打者取消拨打
    YMRTCRecordType_Timeout = 11, //拨打方由于拨打时间过长取消
    YMRTCRecordType_Refuse = 12,//接收者拒绝
    YMRTCRecordType_BusyReceiver = 13,//对方忙线
    YMRTCRecordType_DialingError = 14,//拨号失败或加入房间失败
    YMRTCRecordType_ConnectingError = 15,//连接失败
    YMRTCRecordType_DisConnect = 16,//异常断开连接
    YMRTCRecordType_Close = 17,//正常通话结束
};


NS_ASSUME_NONNULL_BEGIN

@class YMRTCDataItem;
@protocol YMRTCDataItemDelegate <NSObject>

@optional
- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didAddLocalAudioTrack:(RTCAudioTrack *)audioTrack;
- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didAddLocalVideoTrack:(RTCVideoTrack *)videoTrack;
- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didAddRemoteStream:(RTCMediaStream *)stream;


- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didJoinRoom:(BOOL)isBusyReceivers;
- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didJoinNewPeer:(NSString *)peerId;
- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didRemovePeer:(NSString *)peerId;
- (void)RTC_DataItem:(nonnull YMRTCDataItem *)item didSocketError:(NSInteger)errorCode;

- (void)RTC_DataItemDidOtherSystemCalling:(nonnull YMRTCDataItem *)item;
- (void)RTC_DataItemDidReceivedSystemCalling:(nonnull YMRTCDataItem *)item;
- (void)RTC_DataItemDidFeedbackSystemCalling:(nonnull YMRTCDataItem *)item;

- (void)RTC_DataItemDisconnected:(nonnull YMRTCDataItem *)item;

- (void)RTC_DataItemDidSwapToAudio:(nonnull YMRTCDataItem *)item;
- (void)RTC_DataItemStatusChanged:(nonnull YMRTCDataItem *)item;


@end


@interface YMRTCDataItem : NSObject

- (instancetype)initWithChatType:(YMRTCChatType)chatType
                            role:(YMRTCRole)role
                          roomId:(NSString *)roomId
                   otherInfoData:(FriendsModel *)otherInfoData;


@property (nonatomic, weak) id <YMRTCDataItemDelegate> delegate;


/** 拨打角色：发起者或者接收者 */
@property (nonatomic, assign, readonly) YMRTCRole role;

/** 通话类型：语音或者视频 */
@property (nonatomic, assign, readonly) YMRTCChatType chatType;

/** 当前通话类型：从视频切换到语音 */
@property (nonatomic, assign) YMRTCChatType currentChatType;

/** 通话状态 */
@property (nonatomic, assign, readwrite) YMRTCState chatState;

/** 消息的房间id */
@property (nonatomic, copy, nonnull) NSString *roomId;

/** 消息id */
@property (nonatomic, copy) NSString *messageId;

/** 服务端分配给接收者的socket Host */
@property (nonatomic, copy) NSString *receiveHostURL;

/** 对方的个人信息：头像,名称,用户id等. 用于页面展示 */
@property (nonatomic, strong) FriendsModel *otherInfoData;

/** 扩展信息 */
@property (nonatomic, strong, nullable) id extraData;

/** 通话时长 */
@property (nonatomic, assign) NSTimeInterval callDuration;

@property (nonatomic, assign) BOOL isMicrophone;//是否使用麦克风 yes 使用 no 静音;
@property (nonatomic, assign) BOOL isSpeakerEnabled;//是否是扬声器 yes 扬声器 no 听筒;
@property (nonatomic, assign) BOOL isCameraFront;//前后摄像头 yes前置 no后置;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - 公共方法
- (void)startRtcCalling;

- (void)closeRtcCall:(BOOL)hangupYourSelf;

- (void)createOffers;

- (void)swapToAudio;



@end

NS_ASSUME_NONNULL_END
