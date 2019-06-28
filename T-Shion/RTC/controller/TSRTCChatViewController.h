//
//  TSRTCChatViewController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "TSRTCCallingView.h"
#import "TSRTCChatView.h"

@class FriendsModel;

@interface TSRTCChatViewController : BaseViewController

- (instancetype)initWithRole:(RTCRole)role
                    chatType:(RTCChatType)chatType
                      roomID:(NSString *)roomID
              receiveIDArray:(NSArray *)receiveIDArray
              receiveHostURL:(NSString *)receiveHostURL;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatarURl;
@property (nonatomic, copy) NSString *messageId;//离线消息记录

@property (nonatomic, strong) FriendsModel *receiveModel;
@property (nonatomic, strong) TSRTCChatView *chatView;
@property (nonatomic, assign) RTCRole role;//角色

@end
