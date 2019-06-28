//
//  MessageModel.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendsModel;
@class MemberModel;

/*
 消息类型
 */
typedef NS_OPTIONS(int, MessageType) {
    MESSAGE_NotifyTime,//通知   0
    MESSAGE_TEXT,      //文字   1
    MESSAGE_AUDIO,     //声音   2
    MESSAGE_IMAGE,     //图片   3
    MESSAGE_Video,     //视频   4
    MESSAGE_RTC,       //音视频 5
    MESSAGE_File,      //文件   6
    MESSAGE_Location,  //位置   7
    MESSAGE_Passfriend,//好友通过8
    MESSAGE_Withdraw,  //撤回   9
    MESSAGE_System,    //系统信息10
    MESSAGE_New_Msg,    //系统信息11
    MESSAGE_Contacts_Card,    //个人名片12
};

/*
 刷新数据的方式
 */
typedef NS_OPTIONS(int, RefreshMessageType) {
    Loading_HAVE_NEW_MESSAGES = 0, //有新消息     0
    Loading_NO_NEW_MESSAGES,       //没有新消息   2
    Loading_LOOKFOR_MESSAGES,      //查找历史记录  2
    REFRESH_Delete_MESSAGE,        //刷新删除消息  3
    REFRESH_NEW_MESSAGE,           //加载新的消息  4
    REFRESH_HISTORY_MESSAGES,      //刷新历史消息  5
    REFRESH_Table_MESSAGES,        //刷新历史消息  6
};

/*
 消息发送方
 */
typedef NS_OPTIONS(int, MsgSendType) {
    OtherSender=1,//其他人
    SelfSender//自己
};

/*
 消息发送状态
 */
typedef NS_OPTIONS(int, MsgSendStatus) {
    SendStatusSended=1,//送达
    SendStatusUnSended, //未发送
    SendStatusInSending, //发送中
};

/*
 消息接收状态
 */
typedef NS_OPTIONS(int, MsgReadStatus) {
    MsgReadStatusRead = 1,//消息已读
    MsgReadStatusUnRead //消息未读
};

/*
 RTC记录状态
 */
typedef NS_ENUM(NSInteger, RTCMessageStatus) {
    RTCMessageStatus_Default,//正常通话
    RTCMessageStatus_YourCancel,//自己取消
    RTCMessageStatus_OthersCancel,//对方取消
    RTCMessageStatus_YourRefuse,//自己拒绝
    RTCMessageStatus_OthersRefuse,//对方拒绝
    RTCMessageStatus_BusyReceiver,//对方忙线
};


@interface MessageModel : NSObject <NSCopying>
/*
 * 消息类型
 */
@property (nonatomic, assign) MessageType msgType;
/*
 * 消息发送类型
 */
@property (nonatomic, assign) MsgSendType sendType;
/*
 * 消息发送状态 1是送达 2是失败 3是发送中
 */
@property (nonatomic, copy) NSString *sendStatus;
/*
 * 消息读取状态 1是已读 2其他是未读 3 未查看
 */
@property (nonatomic, copy) NSString *readStatus;
/*
 * 里面有好友信息
 */
@property (nonatomic) FriendsModel *senderInfo;
/*
 *
 */
@property (nonatomic) MemberModel *member;
/*
 * 文件大小  文件类型
 */
@property (nonatomic, copy) NSString *fileSize;
/*
 * 消息ID
 */
@property (nonatomic, copy) NSString *messageId;
/*
 * 消息回执ID
 */
@property (nonatomic, copy) NSString *backId;//回执ID
/*
 * 房间号
 */
@property (nonatomic, copy) NSString *roomId;
/*
 * 消息时间戳
 */
@property (nonatomic, copy) NSString *timestamp;
/*
 * 发送者ID
 */
@property (nonatomic, copy) NSString *sender;
/*
 * 消息类别 文本 声音 文件 图片
 */
@property (nonatomic, copy) NSString *type;
/*
 * 消息文本内容
 */
@property (nonatomic, copy) NSString *content;
/*
 * 资源id
 */
@property (nonatomic, copy) NSString *sourceId;
/*
 * 时长
 */
@property (nonatomic, copy) NSString *duration;
/*
 * 群ID
 */
@property (nonatomic, copy) NSString *group;
/*
 * 接收者id
 */
@property (nonatomic, copy) NSString *receiver;
/*
 * 文件名
 */
@property (nonatomic, copy) NSString *fileName;
/*
 * 消息时间
 */
@property (nonatomic, copy) NSString *times;
/*
 * 小图
 */
@property (nonatomic, strong) id smallImage;
/*
 * 大图名称
 */
@property (nonatomic, strong) NSString *bigImage;


/**
 位置信息：包含位置的经纬度以及位置名称和截图URL的json字符串
 */
@property (nonatomic, copy) NSString *locationInfo;


/**
 视频或图片的宽高比,第一帧
 */
@property (nonatomic, copy) NSString *measureInfo;


/**
 视频第一帧图片名
 */
@property (nonatomic, copy) NSString *videoIMGName;

/*
 * 是否播放声音
 */
@property (nonatomic, assign) BOOL isPlay;
/*
 * 是否显示小时的时间
 */
@property (nonatomic, assign) BOOL showMessageTime;
/*
 * 内容的高度
 */
@property (nonatomic, assign) CGFloat contentHeight;
/*
 * 图片尺寸
 */
@property (nonatomic, assign) CGSize imageSize;

/*
 * 视频尺寸
 */
@property (nonatomic, assign) CGSize videoSize;


/*
 * 是否下载中 YES 是  No 不是
 */
@property(nonatomic) BOOL downloading;
/*
 * 是否播放中 YES 是  No 不是
 */
@property(nonatomic) BOOL audioPlaying;

@property (nonatomic, copy) NSArray *atModelList;//群聊被@的成员信息

#pragma mark - RTC
@property (nonatomic, assign) NSInteger rtcChatType;//0.语音，1.视频

@property (nonatomic, assign) NSInteger rtcStatus;//RTC记录状态

+ (MessageModel *)initMessageWithResult:(FMResultSet *)result;

+ (NSString *)getFileTypeWithSuffix:(NSString *)suffix;

//add by chw 2019.04.16 for Encryption
@property (nonatomic, assign) BOOL isCryptoMessage; //是否加密会话
@property (nonatomic, assign) NSInteger cryptoType; //加密类型3 Prekey,2 Whisper
@property (nonatomic, copy) NSString *remoteIdentityKey;//接收者身份密钥
@property (nonatomic, copy) NSString *originalContent;  //保存原有的
@property (nonatomic, copy) NSString *originalSourceId; //保存原有的
@property (nonatomic, copy) NSString *originalLocationInfo;//保存原有的

@property (nonatomic, copy) NSString *fileKey;//加密消息的文件的AES256的key，以逗号隔开的字符串，逗号前面是key，逗号后面是iv

//add by chw 2019.05.21 for "消息丢失"
@property (nonatomic, assign) BOOL isOffLine;

@end
