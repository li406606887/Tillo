//
//  DialogueViewModel.h
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface SessionViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *getChatSessionCommand;

@property (strong, nonatomic) RACSubject *sessionCellClickSubject;

@property (strong, nonatomic) RACSubject *menuCellClickSubject;

@property (strong, nonatomic) RACSubject *cellClickSubject;

@property (strong, nonatomic) RACSubject *refreshTableSubject;

@property (strong, nonatomic) RACSubject *scrollSubject;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end
