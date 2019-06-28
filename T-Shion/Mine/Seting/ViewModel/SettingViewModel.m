//
//  SettingViewModel.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/23.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingViewModel.h"

@implementation SettingViewModel

- (void)initialize {
    @weakify(self)
    [self.logoutCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.loginOutSuccessSubject sendNext:nil];
    }];
}


#pragma mark - getter and setter
- (RACCommand *)logoutCommand {
    if (!_logoutCommand) {
        _logoutCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingWin(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   NSError *error = nil;
                    RequestModel *model = [TSRequest deleteRequetWithApi:api_delete_logout withParam:nil error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:nil];
                        }else {
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
    return _logoutCommand;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (RACSubject *)cardClickSubject {
    if (!_cardClickSubject) {
        _cardClickSubject = [RACSubject subject];
    }
    return _cardClickSubject;
}

- (RACSubject *)exitClickSubject {
    if (!_exitClickSubject) {
        _exitClickSubject = [RACSubject subject];
    }
    return _exitClickSubject;
}

- (RACSubject *)loginOutSuccessSubject {
    if (!_loginOutSuccessSubject) {
        _loginOutSuccessSubject = [RACSubject subject];
    }
    return _loginOutSuccessSubject;
}

@end
