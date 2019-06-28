//
//  LoginViewModel.m
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LoginViewModel.h"
#import "LoginModel.h"
#import "UserInfoModel.h"

//add by chw 2019.04.12 for encryption
#import "YMEncryptionManager.h"

@implementation LoginViewModel
- (void)initialize {
    self.areaCode = @"855";
    @weakify(self)
    [self.loginCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        UserInfoModel *model = [UserInfoModel mj_objectWithKeyValues:x];
        if (model.ID.length > 10) {
            NSString *lastUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUserId"];
            if (![lastUserId isEqualToString:model.ID]) {
                [self.notifySetCommand execute:@{@"receive":@(YES),@"rtcReceive":@(YES)}];
            }
            [[NSUserDefaults standardUserDefaults] setObject:model.ID forKey:@"lastUserId"];
            [[NSUserDefaults standardUserDefaults] setObject:model.ID forKey:@"userId"];
            NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (userId.length>10) {
                [[NSUserDefaults standardUserDefaults] setObject:model.token forKey:@"token"];
                [[NSUserDefaults standardUserDefaults] setObject:model.refreshToken forKey:@"refreshToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
//                [TShionSingleCase shared].headPath = nil;
                
                if ([FMDBManager updateUserInfo:model]) {
                    [self.loginSubject sendNext:x];
                }
            }
            //add by chw 2019.04.15 for encryption
            [YMEncryptionManager generateDataBase];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //做点延时，防止数据库异步操作还没完成就对它进行操作
                [[YMEncryptionManager shareManager] setUserID:model.ID];
                [[YMEncryptionManager shareManager] uploadKeyAfterLogin];
            });
        }
        
    }];
    
    [self.notifySetCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"123");
    }];
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
                        HiddenHUD;
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

- (RACCommand *)notifySetCommand {
    if (!_notifySetCommand) {
        _notifySetCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_notice withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
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
    return _notifySetCommand;
}

- (RACSubject *)forgetClickSubject {
    if (!_forgetClickSubject) {
        _forgetClickSubject = [RACSubject subject];
    }
    return _forgetClickSubject;
}

- (RACSubject *)loginSubject {
    if (!_loginSubject) {
        _loginSubject = [RACSubject subject];
    }
    return _loginSubject;
}

- (RACSubject *)clickAreaSubject {
    if (!_clickAreaSubject) {
        _clickAreaSubject = [RACSubject subject];
    }
    return _clickAreaSubject;
}


@end
