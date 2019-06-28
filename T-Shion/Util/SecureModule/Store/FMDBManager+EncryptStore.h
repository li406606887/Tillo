//
//  FMDBManager+EncrypteStore.h
//  T-Shion
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "FMDBManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMDBManager (EncryptStore)

- (void)createEncryptTable;


/**
 存储会话好友的密聊房间号

 @param roomId 密聊房间号
 @param userID 好友ID
 @param sender 是否是自己发起的（用于区分系统提示）
 @param timeStamp 第一条消息的时间（用于保证系统提示都在最上面）
 */
- (void)storeCryptRoomId:(NSString*)roomId userId:(NSString*)userID isSender:(BOOL)sender timeStamp:(NSTimeInterval)timeStamp;

- (NSMutableArray *)selectEncryptionFriend;

@end

NS_ASSUME_NONNULL_END
