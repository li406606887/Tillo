//
//  AddFriendsViewModel.h
//  T-Shion
//
//  Created by together on 2018/4/2.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface AddFriendsViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *searchFriendsCommand;//搜索朋友

@property (strong, nonatomic) RACCommand *addFriendsCommand;//添加好友请求

@property (strong, nonatomic) RACSubject *searchFriendsSubject;//添加好友返回事件

@property (strong, nonatomic) RACSubject *showAddViewSubject;//显示添加好友页面信号

@property (strong, nonatomic) RACSubject *addFriendsSubject;//添加朋友事件

@property (strong, nonatomic) NSMutableArray *dataArray;


@end
