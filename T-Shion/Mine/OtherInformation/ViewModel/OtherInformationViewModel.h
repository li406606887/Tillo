//
//  OhterInformationViewModel.h
//  T-Shion
//
//  Created by together on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"
#import "FriendsModel.h"

@interface OtherInformationViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *getUserInfoCommand;
//@property (strong, nonatomic) RACCommand *shieldingMessageCommand;
@property (strong, nonatomic) RACCommand *deleteFriendCommand;
@property (strong, nonatomic) RACSubject *refreshUISubject;
@property (strong, nonatomic) RACSubject *cellClickSubject;
@property (strong, nonatomic) RACSubject *deleteClickSubject;
@property (strong, nonatomic) RACSubject *menuItemClickSubject;
@property (strong, nonatomic) RACSubject *deleteSuccessSubject;
@property (strong, nonatomic) RACSubject *clickAvatarSubject;
@property (strong, nonatomic) RACSubject *lookForMsgSubject;
@property (copy, nonatomic) FriendsModel *model;
//add by chw 2019.04.16 for Encryption
@property (strong, nonatomic) RACSubject *startCryptSession;//发起加密聊天
@property (strong, nonatomic) RACSubject *checkSecurCodeSubject;//验证安全码
@property (nonatomic, assign) BOOL isCrypt;//是否是加密聊天进来的
@end
