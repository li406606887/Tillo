//
//  VoipHelper.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/8.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>

@protocol VoipHelperDelegate <NSObject>

@optional
- (void)didReceiveIncomingPushWithPayload:(PKPushPayload *)payload;

@end


@interface VoipHelper : NSObject

+ (VoipHelper *)shareInstance;

- (void)initWithServer;

@property (nonatomic, weak) id <VoipHelperDelegate> delegate;

@end
