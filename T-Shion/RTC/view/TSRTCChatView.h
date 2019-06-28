//
//  TSRTCChatView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRTCCallingView.h"

@class FriendsModel;

@protocol TSRTCChatViewDelegate <NSObject>

@optional
- (void)rtcChatViewShouldDissmiss;

@end


@interface TSRTCChatView : UIView

- (instancetype)initWithRole:(RTCRole)role
                    chatType:(RTCChatType)chatType
                      roomID:(NSString *)roomID
              receiveIDArray:(NSArray *)receiveIDArray
              receiveHostURL:(NSString *)receiveHostURL;

@property (nonatomic, weak) id <TSRTCChatViewDelegate> delegate;

@property (nonatomic, assign) RTCConnectType contenctType;
@property (nonatomic, strong) FriendsModel *receiveModel;
@property (nonatomic, copy) NSString *messageId;//离线消息记录

@end
