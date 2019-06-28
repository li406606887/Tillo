//
//  SocketViewModel.h
//  T-Shion
//
//  Created by together on 2018/4/8.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"
#import "LoginModel.h"
#import "UserInfoModel.h"
#import "Mpush.h"

typedef void(^PomeloCallback)(id callback);

@interface SocketViewModel : BaseViewModel<MPClientDelegate>
/*
 * connect socket client
 */
@property (assign, nonatomic) int status;//0 未连接或连接失败  1. 已连接  2.连接中

@property (strong, nonatomic) MPClient *client;//连接

@property (strong, nonatomic) UserInfoModel *userModel;

+ (SocketViewModel *)shared;

- (void)beginConnect:(BOOL)afterLogin;

- (void)endDisConnect;

- (void)uploadDeviceToken;

- (void)bindUser;

//更新会话的消息数以及消息数量
+ (void)updateSessionDataWithWay:(BOOL)way type:(NSString *)type message:(MessageModel *)message count:(int)count;

//获取存入会话未读的类型
+ (BOOL)getSaveMessageWayWithType:(NSString *)type roomId:(NSString *)roomId;

//踢下线或者token过期
+ (void)kickUserRequest:(BOOL)unauthorized;

+ (void)forbidUser;

+ (void)cleanUserData;

- (void)receiverNewMessage:(NSDictionary *)dictionary;

//处理系统消息
- (MessageModel *)dealSystemMessageWithDictionary:(NSDictionary *)dictionary way:(BOOL)way;

/*
 * get common net data
 */
@property (strong, nonatomic) RACCommand *getFriendsCommand;//好友数据列表

@property (strong, nonatomic) RACCommand *getGroupsCommand;//群组数据列表

@property (strong, nonatomic) RACCommand *getUnreadSessionCommand;//获取未读会话

@property (strong, nonatomic) RACCommand *getSingleChatOfflineMessageCommand;//获取单聊离线消息

@property (strong, nonatomic) RACCommand *getGroupChatOfflineMessageCommand;//获取群聊离线消息

@property (strong, nonatomic) RACCommand *getNewFriendCommand;//获取是否新好友

@property (strong, nonatomic) RACCommand *getRoomSettingCommand;//获取房间设置

@property (strong, nonatomic) RACCommand *settingRoomCommand;//设置房间

@property (strong, nonatomic) RACCommand *addFriendsCommand;//添加好友请求

/*
 * rtc 拨打音视频
 */
@property (strong, nonatomic) RACCommand *postRTCCommand;

@property (strong, nonatomic) RACCommand *postCancelRTCCommand;


@property (nonatomic, strong) RACCommand *blackUserCommand;//更新黑名单

@property (nonatomic, strong) RACCommand *refreshTokenCommand;//刷新token

@property (strong, nonatomic) RACCommand *exitGroupCommand;

@property (strong, nonatomic) RACSubject *getGroupsSubject;

@property (strong, nonatomic) RACSubject *getFriendsSubject;//刷新好友列表

@property (strong, nonatomic) RACSubject *getUnreadSessionSubject;

@property (strong, nonatomic) RACSubject *refreshRoomListSubject;

@property (strong, nonatomic) RACSubject *reconnectGetNetDataSubject;

@property (strong, nonatomic) RACSubject *sendMessageSubject;

@property (strong, nonatomic) RACSubject *messageNotifySubject;//通知

@property (strong, nonatomic) RACSubject *rtcSubject;//rtc请求返回结果

@property (strong, nonatomic) RACSubject *rtcCancelSubject;//rtc请求返回结果

@property (strong, nonatomic) RACSubject *getSingleChatOfflineMessageSubject;//获取单聊离线消息返回结果
@property (strong, nonatomic) RACSubject *sendSingleOfflineMessageSubject;//发送单聊离线消息返回结果
@property (strong, nonatomic) RACSubject *getGroupChatOfflineMessageSubject;//获取群聊离线消息返回结果
@property (strong, nonatomic) RACSubject *sendGroupOfflineMessageSubject;//发送群聊离线消息返回结果

@property (nonatomic, strong) RACSubject *blackUserEndSubject;

@property (strong, nonatomic) RACSubject *addSuccessSucject;

@property (strong, nonatomic) RACSubject *groupOperSubject;

@property (strong, nonatomic) RACSubject *exitGroupSubject;

@property (copy, nonatomic) NSString *deviceToken;

@property (weak, nonatomic) NSString *room;

+ (id)getTopViewController;

- (void)getSingleChatOfflineMessageWithParam:(NSDictionary *)param;

- (void)getGroupChatOfflineMessageWithParam:(NSDictionary *)param;
@end
