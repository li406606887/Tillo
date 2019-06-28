//
//  StrangerInfoViewModel.h
//  T-Shion
//
//  Created by together on 2018/8/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface StrangerInfoViewModel : BaseViewModel
@property (strong, nonatomic) RACSubject *addSuccessSucject;
@property (strong, nonatomic) RACCommand *addFriendsCommand;//添加好友请求
@property (copy, nonatomic) MemberModel *member;
@end
