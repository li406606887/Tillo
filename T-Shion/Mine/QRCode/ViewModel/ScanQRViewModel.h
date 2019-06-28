//
//  ScanQRViewModel.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/23.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"


@interface ScanQRViewModel : BaseViewModel

@property (strong, nonatomic) RACCommand *searchFriendsCommand;//搜索朋友

@property (strong, nonatomic) RACCommand *searchGroupCommand;//搜索群

@property (strong, nonatomic) RACSubject *searchFriendsSubject;//添加好友返回事件

@property (strong, nonatomic) RACSubject *searchGroupEndSubject;//查询群返回事件

@end


