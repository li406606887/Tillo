//
//  GroupMessageRoomController.h
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "GroupModel.h"

@interface GroupMessageRoomController : BaseViewController  
- (instancetype)initWithModel:(GroupModel *)model count:(int)count type:(RefreshMessageType)type;
- (instancetype)initWithModel:(GroupModel *)model count:(int)count type:(RefreshMessageType)type isCrypt:(BOOL)isCrypt;
@end
