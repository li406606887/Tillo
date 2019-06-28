//
//  DialogueContentViewController.h
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendsModel.h"

@interface MessageRoomViewController : BaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
- (instancetype)initWithModel:(FriendsModel *)model count:(int)count type:(RefreshMessageType)type;

- (instancetype)initWithModel:(FriendsModel *)model count:(int)count type:(RefreshMessageType)type isCrypt:(BOOL)isCrypt;

@end
