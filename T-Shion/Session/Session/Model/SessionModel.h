//
//  DialogueModel.h
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendsModel;
@class GroupModel;
@class MessageModel;

@interface SessionModel : NSObject
@property (copy, nonatomic) NSString *roomId;
@property (copy, nonatomic) NSString *type; //群聊：groupChat，单聊：singleChat
@property (copy, nonatomic) NSString *timestamp;
@property (copy, nonatomic) NSString *text;
@property (assign, nonatomic) int unReadCount;
@property (assign, nonatomic) int offlineCount;
@property (strong, nonatomic) FriendsModel *model;
@property (strong, nonatomic) GroupModel *group;
@property (assign, nonatomic) BOOL disturb;
@property (assign, nonatomic) BOOL top;
@property (nonatomic, assign) BOOL isMentioned;//是否被@提醒
@property (copy, nonatomic) NSString *name;
@property (nonatomic, copy) NSString *draftContent;//草稿文字内容


@property (nonatomic, assign) BOOL isCrypt; //是否加密聊天

@end
