//
//  GroupMessageViewModel.h
//  T-Shion
//
//  Created by together on 2018/7/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface GroupListViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *getGroupListCommand;
@property (strong, nonatomic) RACSubject *refreshUISubject;
@property (strong, nonatomic) RACSubject *cellClickSubject;
@property (strong, nonatomic) RACSubject *creatGroupSubject;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end
