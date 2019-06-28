//
//  GroupSetingViewModel.h
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"
#import "GroupModel.h"

@interface GroupSetingViewModel : BaseViewModel
@property (copy, nonatomic) GroupModel *model;

@property (strong, nonatomic) RACCommand *getGroupMemberCommand;

@property (strong, nonatomic) RACCommand *getGroupInfoCommand;

@property (strong, nonatomic) RACCommand *updateGroupAvatarCommand;

@property (strong, nonatomic) RACSubject *refreshMemberSubject;

@property (strong, nonatomic) RACSubject *addMemberSubject;

@property (strong, nonatomic) RACSubject *showAlertSubject;

@property (strong, nonatomic) RACSubject *modifyNameSubject;

@property (strong, nonatomic) RACSubject *lookForHistorySubject;

@property (strong, nonatomic) RACSubject *groupSetingSubject;

@property (strong, nonatomic) RACSubject *deleteSuccessSubject;

@property (strong, nonatomic) RACSubject *memberClickSubject;

@property (strong, nonatomic) RACSubject *lookAllMemberSubject;

@property (strong, nonatomic) RACSubject *updateGroupAvatarEndSubject;

@property (nonatomic, strong) RACSubject *modifyNameInGroupSubject;

@property (strong, nonatomic) RACSubject *complaintsSubject;

@property (weak, nonatomic) NSMutableDictionary *data;

@property (strong, nonatomic) NSMutableArray *memberArray;
@end
