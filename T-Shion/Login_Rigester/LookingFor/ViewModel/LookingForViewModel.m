//
//  LookingForViewModel.m
//  T-Shion
//
//  Created by together on 2018/9/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LookingForViewModel.h"

@implementation LookingForViewModel
- (void)initialize {
    @weakify(self)
    self.areaCode = @"855";
    [self.lookforPwdCommand.executionSignals.switchToLatest subscribeNext:^(NSMutableDictionary *input) {
        @strongify(self)
        [input removeObjectForKey:@"smsCode"];
        [self.loginCommand execute:input];
        [self.lookforPwdSubject sendNext:nil];
    }];
    
    [self.sendVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.verificationSuccessSubject sendNext:nil];
    }];
    
    [self.loginCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        UserInfoModel *model = [UserInfoModel mj_objectWithKeyValues:x];
        [[NSUserDefaults standardUserDefaults] setObject:model.token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:model.refreshToken forKey:@"refreshToken"];
        [[NSUserDefaults standardUserDefaults] setObject:model.ID forKey:@"userId"];
//        [TShionSingleCase shared].headPath = nil;
        if ([FMDBManager updateUserInfo:model]) {
            [self.loginSubject sendNext:x];
        }
    }];
}

- (RACCommand *)lookforPwdCommand {
    if (!_lookforPwdCommand) {
        _lookforPwdCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *data= [TSRequest putRequetWithApi:api_forget withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD
                        if (!error) {
                            [subscriber sendNext:input];
                        }else {
                            ShowViewMessage(data.message);
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _lookforPwdCommand;
}

- (RACCommand *)sendVerificationCodeCommand {
    if (!_sendVerificationCodeCommand) {
        _sendVerificationCodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(Localized(@"register_tip_getcode"))
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_get_smsCode withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD
                        if (!error) {
                            NSLog(@"验证码发送成功");
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
    return _sendVerificationCodeCommand;
}

- (RACCommand *)loginCommand {
    if (!_loginCommand) {
        _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(Localized(@"login_tip_logining"));
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_login withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model) {
                                ShowWinMessage(model.message)
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _loginCommand;
}


- (RACSubject *)lookforPwdSubject {
    if (!_lookforPwdSubject) {
        _lookforPwdSubject = [RACSubject subject];
    }
    return _lookforPwdSubject;
}

- (RACSubject *)clickAreaSubject {
    if (!_clickAreaSubject) {
        _clickAreaSubject = [RACSubject subject];
    }
    return _clickAreaSubject;
}

- (RACSubject *)verificationSuccessSubject {
    if (!_verificationSuccessSubject) {
        _verificationSuccessSubject = [RACSubject subject];
    }
    return _verificationSuccessSubject;
}

- (RACSubject *)loginSubject {
    if (!_loginSubject) {
        _loginSubject = [RACSubject subject];
    }
    return _loginSubject;
}

@end
