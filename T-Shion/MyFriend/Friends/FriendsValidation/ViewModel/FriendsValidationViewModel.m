//
//  FriendsValidationViewModel.m
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsValidationViewModel.h"

@implementation FriendsValidationViewModel
- (void)initialize {
    @weakify(self)
    [self.getValidationFriendCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [FMDBManager deleteAllFriendRequest];
         self.tableModel = [RequestTableModel mj_objectWithKeyValues:x];
        self.dataArray = [FriendsModel mj_objectArrayWithKeyValuesArray:[x objectForKey:@"rows"]];
        NSArray *array = [x objectForKey:@"rows"];
        for (NSDictionary *dic in array) {
             [FMDBManager updataFriendRequestData:dic];
        }
        [self.sourceDataArray removeAllObjects];
        [self.sourceDataArray addObjectsFromArray:array];
        [TShionSingleCase shared].newFriend = NO;
        NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:key];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFirendPrompt" object:@"0"];
        [self.getValidationFriendSubject sendNext:nil];
    }];
    
    [self.agreeCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        //我通过你的朋友验证请求，现在我们可以开始聊天了
        self.agreeModel.roomId = [x objectForKey:@"roomId"];
        if ([x objectForKey:@"openEndToEndEncrypt"]) {
            self.agreeModel.enableEndToEndCrypt = [[x objectForKey:@"openEndToEndEncrypt"] boolValue];
        }
        [FMDBManager creatMessageTableWithRoomId:self.agreeModel.roomId];
        [FMDBManager updateFriendTableWithFriendsModel:self.agreeModel];
        MessageModel *message = [[MessageModel alloc] init];
        message.sendStatus = @"1";
        message.readStatus = @"1";
        message.messageId = [NSUUID UUID].UUIDString;
        message.roomId = self.agreeModel.roomId;
        message.backId = [NSUUID UUID].UUIDString;
        message.sender = [SocketViewModel shared].userModel.ID;
        message.content = Localized(@"Pass_Friend_Message");
        message.type = @"text";
        message.timestamp = [NSDate getNowTimestamp];
        [FMDBManager insertMessageWithContentModel:message];
        [FMDBManager insertSessionOnlineWithType:@"singleChat" message:message withCount:0];
        [self.agreeSubject sendNext:nil];
    }];
    
    [self.deleteRequestCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        [self.deleteRequestSubject sendNext:nil];
    }];
}

- (RACCommand *)getValidationFriendCommand {
    if (!_getValidationFriendCommand) {
        _getValidationFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_friend_request withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
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
    return _getValidationFriendCommand;
}

- (RACCommand *)agreeCommand {
    if (!_agreeCommand) {
        _agreeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_pass_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
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
    return _agreeCommand;
}

- (RACCommand *)deleteRequestCommand {
    if (!_deleteRequestCommand) {
        _deleteRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_friendRequest withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
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
    return _deleteRequestCommand;
}

-(RACSubject *)getValidationFriendSubject {
    if (!_getValidationFriendSubject) {
        _getValidationFriendSubject = [RACSubject subject];
    }
    return _getValidationFriendSubject;
}

- (RACSubject *)agreeSubject {
    if (!_agreeSubject) {
        _agreeSubject = [RACSubject subject];
    }
    return _agreeSubject;
}

- (RACSubject *)gotoSearchFriendSubject {
    if (!_gotoSearchFriendSubject) {
        _gotoSearchFriendSubject = [RACSubject subject];
    }
    return _gotoSearchFriendSubject;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (RACSubject *)deleteRequestSubject {
    if (!_deleteRequestSubject) {
        _deleteRequestSubject = [RACSubject subject];
    }
    return _deleteRequestSubject;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
        for (NSDictionary *data in self.sourceDataArray) {
            FriendsModel *model = [FriendsModel mj_objectWithKeyValues:data];
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}

- (NSMutableArray *)sourceDataArray {
    if (!_sourceDataArray) {
        _sourceDataArray = [FMDBManager selectFriendRequest];
    }
    return _sourceDataArray;
}
@end
