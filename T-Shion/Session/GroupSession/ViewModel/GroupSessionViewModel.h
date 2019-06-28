//
//  GroupSessionViewModel.h
//  T-Shion
//
//  Created by together on 2018/7/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface GroupSessionViewModel : BaseViewModel
@property (strong, nonatomic) RACSubject *dialogueCellClickSubject;

@property (strong, nonatomic) RACSubject *menuCellClickSubject;

@property (strong, nonatomic) RACSubject *cellClickSubject;

@property (strong, nonatomic) RACSubject *refreshTableSubject;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) RACCommand *getSessionListCommand;
@end
