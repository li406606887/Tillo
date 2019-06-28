//
//  SendInviteViewModel.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SendInviteViewModel.h"
#import "AddFriendsModel.h"

@implementation SendInviteViewModel

- (void)initialize {
    @weakify(self)
    [self.addFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        FriendsModel *model;
        NSString *roomId = [NSString stringWithFormat:@"%@",[x objectForKey:@"roomId"]];
        if (roomId.length>8) {
            model = [FriendsModel mj_objectWithKeyValues:x];
            model.userId = self.model.uid;
            model.name = self.model.name;
            model.showName = self.model.name;
            model.nickName = @"";
            model.avatar = self.model.avatar;
            model.sex = self.model.sex;
            model.mobile = self.model.mobile;
            model.roomId = roomId;
            model.enableEndToEndCrypt = [[x objectForKey:@"openEndToEndEncrypt"] boolValue];
            [FMDBManager updateFriendTableWithFriendsModel:model];
        }
        [self.addFriendsSubject sendNext:model];

    }];
}

- (RACCommand *)addFriendsCommand {
    if (!_addFriendsCommand) {
        _addFriendsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_add_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model.message.length>0) {
                                ShowViewMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _addFriendsCommand;
}

- (RACSubject *)addFriendsSubject {
    if (!_addFriendsSubject) {
        _addFriendsSubject = [RACSubject subject];
    }
    return _addFriendsSubject;
}



@end
