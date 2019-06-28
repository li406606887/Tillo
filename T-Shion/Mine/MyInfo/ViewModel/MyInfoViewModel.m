//
//  MyInfoViewModel.m
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MyInfoViewModel.h"

@implementation MyInfoViewModel
- (void)initialize {
    @weakify(self)
    [self.setHeadIconCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.setHeadIconSubject sendNext:nil];
    }];
}

- (RACCommand *)setHeadIconCommand {
    if (!_setHeadIconCommand) {
        _setHeadIconCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error ;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_update_info withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (error == nil) {
                            NSString *headUrl = [model.data objectForKey:@"avatar"];
                            [SocketViewModel shared].userModel.avatar = headUrl;
                            [FMDBManager updateUserInfo:[SocketViewModel shared].userModel];
                            [subscriber sendNext:nil];
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
    return _setHeadIconCommand;
}

- (RACSubject *)setHeadIconSubject {
    if (!_setHeadIconSubject) {
        _setHeadIconSubject = [RACSubject subject];
    }
    return _setHeadIconSubject;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"UserInfo_Avatar",
                        @"UserInfo_NickName",
                        @"UserInfo_Phone",
                        @"UserInfo_Address",
                        @"UserInfo_Sex"];
    }
    return _titleArray;
}

@end
