//
//  MyInfoViewModel.h
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface MyInfoViewModel : BaseViewModel

@property (strong, nonatomic) RACCommand *setHeadIconCommand;

@property (strong, nonatomic) RACSubject *setHeadIconSubject;

@property (strong, nonatomic) RACSubject *cellClickSubject;

@property (strong, nonatomic) NSArray *titleArray;

@end
