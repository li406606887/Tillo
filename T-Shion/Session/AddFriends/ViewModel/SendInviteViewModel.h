//
//  SendInviteViewModel.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFriendsModel.h"

@interface SendInviteViewModel : BaseViewModel

@property (strong, nonatomic) RACCommand *addFriendsCommand;//添加好友请求
@property (strong, nonatomic) RACSubject *addFriendsSubject;//添加朋友事件
@property (nonatomic, strong) AddFriendsModel *model;

@end

