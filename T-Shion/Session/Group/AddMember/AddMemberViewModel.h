//
//  AddMemberViewModel.h
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface AddMemberViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *addMemberCommand;
@property (copy, nonatomic) GroupModel *model;
@property (strong, nonatomic) RACSubject *addSuccessSucject;
@end
