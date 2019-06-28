//
//  ScanQRViewModel.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/23.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ScanQRViewModel.h"
#import "AddFriendsModel.h"

@implementation ScanQRViewModel

- (void)initialize {
    @weakify(self)
    [self.searchFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (!x) {
            [self.searchFriendsSubject sendNext:nil];
            return;
        }
        AddFriendsModel *model = [AddFriendsModel mj_objectWithKeyValues:x];
        [self.searchFriendsSubject sendNext:model];
    }];
    
    [self.searchGroupCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.searchGroupEndSubject sendNext:x];
    }];
}


- (RACCommand *)searchFriendsCommand {
    if (!_searchFriendsCommand) {
        _searchFriendsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_search_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            NSLog(@"%@",model.data);
                            [subscriber sendNext:model.data];
                        }else {
                            [subscriber sendNext:nil];
                            NSLog(@"%@",error);
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _searchFriendsCommand;
}

- (RACCommand *)searchGroupCommand {
    if (!_searchGroupCommand) {
        _searchGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_groupQrCode_join withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [subscriber sendNext:model];
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _searchGroupCommand;
}

- (RACSubject *)searchFriendsSubject {
    if (!_searchFriendsSubject) {
        _searchFriendsSubject = [RACSubject subject];
    }
    return _searchFriendsSubject;
}

- (RACSubject *)searchGroupEndSubject {
    if (!_searchGroupEndSubject) {
        _searchGroupEndSubject = [RACSubject subject];
    }
    return _searchGroupEndSubject;
}

@end
