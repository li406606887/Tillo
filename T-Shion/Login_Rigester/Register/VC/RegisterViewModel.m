    //
//  RegisterViewModel.m
//  T-Shion
//
//  Created by together on 2018/4/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "RegisterViewModel.h"
#import "TSRequest.h"
//add by chw 2019.04.15 for encryption
#import "YMEncryptionManager.h"
@implementation RegisterViewModel
- (void)initialize {
    self.areaCode = @"855";
    @weakify(self)
    [self.sendVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.verificationSuccessSubject sendNext:nil];
    }];
    
    [self.registerCommand.executionSignals.switchToLatest subscribeNext:^(NSMutableDictionary *input) {
        @strongify(self)
        [input removeObjectForKey:@"smsCode"];
        [self.loginCommand execute:input];
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
        //add by chw 2019.04.15 for encryption
        [YMEncryptionManager generateDataBase];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //做点延时，防止数据库异步操作还没完成就对它进行操作
            [[YMEncryptionManager shareManager] setUserID:model.ID];
            [[YMEncryptionManager shareManager] uploadKeyAfterLogin];
        });
    }];
    
    [self.setNickNameCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.setNickNameSubject sendNext:nil];
    }];
    
    [self.setHeadIconCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.setHeadIconSubject sendNext:nil];
    }];
    
    [self.getInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [SocketViewModel shared].userModel = [UserInfoModel mj_objectWithKeyValues:x];
        [self.getInfoSubject sendNext:x];
    }];
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

- (RACCommand *)registerCommand {
    if (!_registerCommand) {
        _registerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(Localized(@"register_tip_registering"))
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    NSLog(@"%@",input);
                    RequestModel *model = [TSRequest postRequetWithApi:api_register withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD
                        if (!error) {
                            [subscriber sendNext:input];
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
    return _registerCommand;
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


- (RACSubject *)verificationSuccessSubject {
    if (!_verificationSuccessSubject) {
        _verificationSuccessSubject = [RACSubject subject];
    }
    return _verificationSuccessSubject;
}

- (RACSubject *)registerSubject {
    if (!_registerSubject) {
        _registerSubject = [RACSubject subject];
    }
    return _registerSubject;
}

- (RACSubject *)loginSubject {
    if (!_loginSubject) {
        _loginSubject = [RACSubject subject];
    }
    return _loginSubject;
}

- (RACSubject *)setNickNameSubject {
    if (!_setNickNameSubject) {
        _setNickNameSubject = [RACSubject subject];
    }
    return _setNickNameSubject;
}

- (RACSubject *)setHeadIconSubject {
    if (!_setHeadIconSubject) {
        _setHeadIconSubject = [RACSubject subject];
    }
    return _setHeadIconSubject;
}

- (RACSubject *)getInfoSubject {
    if (!_getInfoSubject) {
        _getInfoSubject = [RACSubject subject];
    }
    return _getInfoSubject;
}

- (RACSubject *)clickAreaSubject {
    if (!_clickAreaSubject) {
        _clickAreaSubject = [RACSubject subject];
    }
    return _clickAreaSubject;
}

- (RACSubject *)goBackSubject {
    if (!_goBackSubject) {
        _goBackSubject = [RACSubject subject];
    }
    return _goBackSubject;
}

- (RACSubject *)agreementSubject {
    if (!_agreementSubject) {
        _agreementSubject = [RACSubject subject];
    }
    return _agreementSubject;
}

@end
