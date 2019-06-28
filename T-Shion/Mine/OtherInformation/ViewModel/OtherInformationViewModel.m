//
//  OhterInformationViewModel.m
//  T-Shion
//
//  Created by together on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "OtherInformationViewModel.h"
#import "FriendsModel.h"

@implementation OtherInformationViewModel
- (void)initialize {
    @weakify(self)
    [self.getUserInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        FriendsModel *friend = [FriendsModel mj_objectWithKeyValues:x];
        FriendsModel *friendsModel = [FMDBManager selectFriendTableWithUid:friend.userId];
        if (friendsModel) {//如果不是好友不要更新
            BOOL result = [FMDBManager updateFriendTableWithFriendsModel:friend];
            if (result) {
                self.model.avatar = friend.avatar;
                self.model.name = friend.name;
                self.model.nickName = friend.nickName;
                self.model.showName = friend.showName;
            }
        }
        [self.refreshUISubject sendNext:friend];
    }];

    [self.deleteFriendCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.deleteSuccessSubject sendNext:nil];
    }];
}

- (RACCommand *)getUserInfoCommand {
    if (!_getUserInfoCommand) {
        _getUserInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error ;
                    RequestModel *model = [TSRequest getRequetWithApi:api_post_friendInfo withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            if (model.message) {
                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getUserInfoCommand;
}

- (RACCommand *)deleteFriendCommand {
    if (!_deleteFriendCommand) {
        _deleteFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
               
                LoadingView(@""); dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error ;
                    RequestModel *model = [TSRequest deleteRequetWithApi:api_delete_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            if (model.message) {
                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _deleteFriendCommand;
}

- (void)setModel:(FriendsModel *)model {
    _model = model;
    [self.getUserInfoCommand execute:@{@"friendId":model.userId}];
    [self.refreshUISubject sendNext:model];
}

- (RACSubject *)menuItemClickSubject {
    if (!_menuItemClickSubject) {
        _menuItemClickSubject = [RACSubject subject];
    }
    return _menuItemClickSubject;
}

- (RACSubject *)refreshUISubject {
    if (!_refreshUISubject) {
        _refreshUISubject = [RACSubject subject];
    }
    return _refreshUISubject;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (RACSubject *)deleteClickSubject {
    if (!_deleteClickSubject) {
        _deleteClickSubject = [RACSubject subject];
    }
    return _deleteClickSubject;
}

- (RACSubject *)deleteSuccessSubject {
    if (!_deleteSuccessSubject) {
        _deleteSuccessSubject = [RACSubject subject];
    }
    return _deleteSuccessSubject;
}

- (RACSubject *)clickAvatarSubject {
    if (!_clickAvatarSubject) {
        _clickAvatarSubject = [RACSubject subject];
    }
    return _clickAvatarSubject;
}
//add by chw 2019.04.16 for Encryption
- (RACSubject*)startCryptSession {
    if (!_startCryptSession) {
        _startCryptSession = [RACSubject subject];
    }
    return _startCryptSession;
}

- (RACSubject*)checkSecurCodeSubject {
    if (!_checkSecurCodeSubject){
        _checkSecurCodeSubject = [RACSubject subject];
    }
    return _checkSecurCodeSubject;
}

- (RACSubject*)lookForMsgSubject {
    if (!_lookForMsgSubject) {
        _lookForMsgSubject = [RACSubject subject];
    }
    return _lookForMsgSubject;
}
@end
