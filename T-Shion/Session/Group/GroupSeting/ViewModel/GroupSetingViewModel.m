//
//  GroupSetingViewModel.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSetingViewModel.h"

@implementation GroupSetingViewModel
- (void)initialize {
    @weakify(self)
    
    [self.updateGroupAvatarCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.updateGroupAvatarEndSubject sendNext:x];
    }];
    
    [self.getGroupInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        GroupModel *model = [GroupModel mj_objectWithKeyValues:x];
        self.model.isCrypt = model.isCrypt = [[x objectForKey:@"isEncryptGroup"] boolValue];
        self.model.owner = model.owner;
        self.model.avatar = model.avatar;
        self.model.name = model.name;
        self.model.inviteSwitch = model.inviteSwitch;
        self.model.memberCount = model.memberCount;
        [FMDBManager updateGroupListWithModel:model];
        [self.refreshMemberSubject sendNext:nil];
    }];
}


- (RACCommand *)updateGroupAvatarCommand {
    if (!_updateGroupAvatarCommand) {
        _updateGroupAvatarCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error ;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_updateGroupAvatar withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (error == nil) {
//                            NSString *headUrl = [model.data objectForKey:@"avatar"];
                        
                            [subscriber sendNext:model.data];
                        }else {
                            if (model!=nil) {
                                if (model.message.length>0) {
                                    ShowWinMessage(model.message);
                                }
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _updateGroupAvatarCommand;
}

- (RACCommand *)getGroupInfoCommand {
    if (!_getGroupInfoCommand) {
        _getGroupInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error ;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_groupInfo withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (error == nil) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model!=nil) {
                                if (model.message.length>0) {
                                    ShowWinMessage(model.message);
                                }
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getGroupInfoCommand;
}

- (void)setModel:(GroupModel *)model {
    _model = model;
    //    [self.refreshMemberSubject sendNext:self.memberArray];
}

- (RACSubject *)refreshMemberSubject {
    if (!_refreshMemberSubject) {
        _refreshMemberSubject = [RACSubject subject];
    }
    return _refreshMemberSubject;
}

- (RACSubject *)addMemberSubject {
    if (!_addMemberSubject) {
        _addMemberSubject = [RACSubject subject];
    }
    return _addMemberSubject;
}

- (RACSubject *)modifyNameSubject {
    if (!_modifyNameSubject) {
        _modifyNameSubject = [RACSubject subject];
    }
    return _modifyNameSubject;
}

- (RACSubject *)lookForHistorySubject {
    if (!_lookForHistorySubject) {
        _lookForHistorySubject = [RACSubject subject];
    }
    return _lookForHistorySubject;
}

- (RACSubject *)groupSetingSubject {
    if (!_groupSetingSubject) {
        _groupSetingSubject = [RACSubject subject];
    }
    return _groupSetingSubject;
}

- (RACSubject *)showAlertSubject {
    if (!_showAlertSubject) {
        _showAlertSubject = [RACSubject subject];
    }
    return _showAlertSubject;
}

- (RACSubject *)deleteSuccessSubject {
    if (!_deleteSuccessSubject) {
        _deleteSuccessSubject = [RACSubject subject];
    }
    return _deleteSuccessSubject;
}

- (RACSubject *)memberClickSubject {
    if (!_memberClickSubject) {
        _memberClickSubject = [RACSubject subject];
    }
    return _memberClickSubject;
}

- (RACSubject *)lookAllMemberSubject {
    if (!_lookAllMemberSubject) {
        _lookAllMemberSubject = [RACSubject subject];
    }
    return _lookAllMemberSubject;
}

- (RACSubject *)updateGroupAvatarEndSubject {
    if (!_updateGroupAvatarEndSubject) {
        _updateGroupAvatarEndSubject = [RACSubject subject];
    }
    return _updateGroupAvatarEndSubject;
}


- (RACSubject *)modifyNameInGroupSubject {
    if (!_modifyNameInGroupSubject) {
        _modifyNameInGroupSubject = [RACSubject subject];
    }
    return _modifyNameInGroupSubject;
}

- (RACSubject *)complaintsSubject {
    if (!_complaintsSubject) {
        _complaintsSubject = [RACSubject subject];
    }
    return _complaintsSubject;
}

- (NSMutableArray *)memberArray {
    if (!_memberArray) {
        _memberArray = [NSMutableArray array];
        NSMutableArray *index = [NSMutableArray array];
        NSArray *array = [MemberModel sortMembersArray:[self.data allValues] toIndexArray:index];
        for (NSArray *a in array) {
            [_memberArray addObjectsFromArray:a];
        }
    }
    return _memberArray;
}
@end
