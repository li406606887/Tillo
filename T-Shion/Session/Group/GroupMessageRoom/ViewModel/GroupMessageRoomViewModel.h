//
//  GroupMessageRoomViewModel.h
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface GroupMessageRoomViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *getMemberCommand;//获取成员列表

@property (strong, nonatomic) RACSubject *refreshTableSubject;//刷新列表

@property (strong, nonatomic) RACSubject *showMemberSubject;//显示群成员

@property (strong, nonatomic) RACSubject *clickMemberSubject;//

@property (strong, nonatomic) RACSubject *choosePhotoSubject;//选择照片

@property (strong, nonatomic) RACSubject *clickHeadIconSubject;//点击头像

@property (strong, nonatomic) RACSubject *messageClickUrlSubject;//消息链接点击

@property (strong, nonatomic) RACSubject *messageClickFileSubject;//点击文件消息

@property (nonatomic, strong) RACSubject *messageTransmitSubject;//点击转发消息,chw 2019.02.27

@property (nonatomic, strong) RACSubject *sendMsgSubject;//发送消息

@property (nonatomic, strong) RACSubject *addFriendSubject;//添加好友

@property (strong, nonatomic) NSMutableArray *dataList;

@property (strong, nonatomic) NSMutableSet *dataSet;

@property (strong, nonatomic) NSMutableDictionary *unsendDictionary;

@property (strong, nonatomic) NSMutableDictionary *downLoadingDictionary;

@property (copy, nonatomic) GroupModel *groupModel;

@property (assign, nonatomic) int msgCount;//初次加载消息数

@property (assign, nonatomic) int unreadCount;//未读消息数

@property (assign, nonatomic) int unreadMsgIndex;//未读消息位置

@property (weak, nonatomic) MessageModel *unreadFirstModel;//未读的第一条消息

@property (copy, nonatomic) NSDate *lastDate;//最后一条时间类型消息的时间

@property (assign, nonatomic) RefreshMessageType type;//刷新类型

@property (strong, nonatomic) NSMutableDictionary *members;//群内所有成员
@property (strong, nonatomic) NSMutableArray *memberArray;//群内所有成员

- (void)getLocationHistoryMessage;

- (void)refreshHistoryMessage:(NSString *)timestamp;

- (void)resendMessageWithModel:(MessageModel *)model;

- (void)sendMessageWithModel:(MessageModel *)model;

//消息转发
- (void)transmitMessageWithModel:(MessageModel*)model;
//消息撤回
- (void)withdrawMsgWithModel:(MessageModel *)model;
//截屏提醒
- (void)sendScreenShotMessage;
//是否是加密
@property (nonatomic, assign) BOOL isCrypt;

@end
