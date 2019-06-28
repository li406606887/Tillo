//
//  DialogueContentViewModel.h
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"
#import "MessageModel.h"
#import "FriendsModel.h"

@interface MessageRoomViewModel : BaseViewModel

@property (strong, nonatomic) RACSubject *refreshMsgListSubject;//刷新列表

@property (strong, nonatomic) RACSubject *choosePhotoSubject;//选择照片

@property (strong, nonatomic) RACSubject *clickHeadIconSubject;//点击头像

@property (strong, nonatomic) RACSubject *callingVideoSubject;//点击头像

@property (strong, nonatomic) RACSubject *rtcCallSubject;//点击rtc消息

@property (strong, nonatomic) RACSubject *messageClickUrlSubject;//点击连接消息

@property (strong, nonatomic) RACSubject *messageClickFileSubject;//点击文件消息

@property (nonatomic, strong) RACSubject *messageTransmitSubject;//点击转发消息,chw 2019.02.27
@property (nonatomic, strong) RACSubject *sendMsgSubject;//发送消息

@property (nonatomic, strong) RACSubject *addFriendSubject;//添加好友

@property (strong, nonatomic) NSMutableArray *dataList;

@property (strong, nonatomic) NSMutableSet *dataSet;

@property (strong, nonatomic) NSMutableDictionary *unsendDictionary;

@property (strong, nonatomic) NSMutableDictionary *downLoadingDictionary;

@property (copy, nonatomic) FriendsModel *friendModel;

@property (assign, nonatomic) int msgCount;

@property (assign, nonatomic) int unreadCount;

@property (weak, nonatomic) MessageModel *unreadFirstModel;

@property (assign, nonatomic) int unreadMsgIndex;

@property (copy, nonatomic) NSDate *lastDate;

@property (assign, nonatomic) RefreshMessageType type;    

- (void)getLocationHistoryMessage;

- (void)refreshHistoryMessage:(NSString *)timestamp;

- (void)resendMessageWithModel:(MessageModel *)model;

- (void)sendMessageWithModel:(MessageModel *)model;

///消息转发
- (void)transmitMessageWithModel:(MessageModel*)model;
//撤回
- (void)withdrawMsgWithModel:(MessageModel *)model;

//add by chw 2019.04.16 for Encryption
@property (nonatomic, assign) BOOL isCrypt;

- (void)sendScreenShotMessage;
@end
