//
//  DeleteGroupMemberViewModel.h
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface DeleteGroupMemberViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *deleteMemberCommand;
@property (strong, nonatomic) RACSubject *deleteSuccessSubject;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) NSMutableArray *memberArray;
@property (copy, nonatomic) NSString *memberId;
@end
