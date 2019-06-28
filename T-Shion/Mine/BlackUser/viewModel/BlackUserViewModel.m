//
//  BlackUserViewModel.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/7.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BlackUserViewModel.h"

@implementation BlackUserViewModel

- (void)initialize {
    @weakify(self)
    [self.loadDataCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.dataArray removeAllObjects];
        self.dataArray = [FriendsModel mj_objectArrayWithKeyValuesArray:x];
        for (FriendsModel *model in self.dataArray) {
            [FMDBManager setRoomBlackWithRoomId:model.roomId blacklistFlag:YES];
        }
        [self.refreshEndSubject sendNext:nil];
    }];
    
    [self.removeCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.removeEndSubject sendNext:nil];
    }];
}

- (RACCommand *)loadDataCommand {
    if (!_loadDataCommand) {
        _loadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_blackUserList withParam:nil error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _loadDataCommand;
}

- (RACCommand *)removeCommand {
    if (!_removeCommand) {
        _removeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_blackUser withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            if (model.message.length>0) {
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
    
    return _removeCommand;
}


- (RACSubject *)refreshEndSubject {
    if (!_refreshEndSubject) {
        _refreshEndSubject = [RACSubject subject];
    }
    return _refreshEndSubject;
}

- (RACSubject *)removeEndSubject {
    if (!_removeEndSubject) {
        _removeEndSubject = [RACSubject subject];
    }
    return _removeEndSubject;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [FMDBManager selectBlackFriend];
    }
    return _dataArray;
}
@end
