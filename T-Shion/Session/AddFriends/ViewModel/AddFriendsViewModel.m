//
//  AddFriendsViewModel.m
//  T-Shion
//
//  Created by together on 2018/4/2.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddFriendsViewModel.h"
#import "AddFriendsModel.h"
#import "RoomSetModel.h"

@implementation AddFriendsViewModel

- (void)initialize {
    @weakify(self)
    [self.searchFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.dataArray.count>0) {
            [self.dataArray removeAllObjects];
        }
        AddFriendsModel *model = [AddFriendsModel mj_objectWithKeyValues:x];
        if (model.roomId>0) {
            RoomSetModel *roomSet = [RoomSetModel mj_objectWithKeyValues:x];
            BOOL disturb = roomSet.shieldFlag;
            BOOL top = roomSet.topFlag;
            BOOL blacklistFlag = roomSet.blacklistFlag;
            [FMDBManager updateRoomSettingWithRoomId:model.roomId disturb:disturb top:top];
            [FMDBManager setRoomBlackWithRoomId:model.roomId blacklistFlag:blacklistFlag];
        }
//        [self.dataArray addObject:model];
        [self.searchFriendsSubject sendNext:model];
    }];
    
    [self.addFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        AddFriendsModel *model = [AddFriendsModel mj_objectWithKeyValues:x];
        [FMDBManager creatMessageTableWithRoomId:model.roomId];
        [self.addFriendsSubject sendNext:nil];
    }];
}

- (RACCommand *)addFriendsCommand {
    if (!_addFriendsCommand) {
        _addFriendsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_add_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            NSLog(@"%@",model.data);
                            [subscriber sendNext:model.data];
                        }else {
                            NSLog(@"%@",error);
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
                            if ([model.status isEqualToString:@"1006"]) {
                                ShowWinMessage(Localized(@"No_User"));
                            }
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

- (RACSubject *)searchFriendsSubject {
    if (!_searchFriendsSubject) {
        _searchFriendsSubject = [RACSubject subject];
    }
    return _searchFriendsSubject;
}

- (RACSubject *)addFriendsSubject {
    if (!_addFriendsSubject) {
        _addFriendsSubject = [RACSubject subject];
    }
    return _addFriendsSubject;
}

- (RACSubject *)showAddViewSubject {
    if (!_showAddViewSubject) {
        _showAddViewSubject = [RACSubject subject];
    }
    return _showAddViewSubject;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
@end
