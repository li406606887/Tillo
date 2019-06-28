//
//  ModifyInfoViewModel.m
//  T-Shion
//
//  Created by together on 2018/6/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ModifyInfoViewModel.h"

@implementation ModifyInfoViewModel
- (void)initialize {
    @weakify(self)
    [self.modifyInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.modifySuccessSubject sendNext:nil];
    }];
    
    [self.modifyFriendInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.modifySuccessSubject sendNext:nil];
    }];
}

- (RACCommand *)modifyInfoCommand {
    if (!_modifyInfoCommand) {
        _modifyInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_update_info withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD
                        if (!error) {
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
    return _modifyInfoCommand;
}

- (RACCommand *)modifyFriendInfoCommand {
    if (!_modifyFriendInfoCommand) {
        _modifyFriendInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_update_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD
                        if (!error) {
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
    return _modifyFriendInfoCommand;
}

- (RACSubject *)modifySuccessSubject {
    if (!_modifySuccessSubject) {
        _modifySuccessSubject = [RACSubject subject];
    }
    return _modifySuccessSubject;
}
@end
