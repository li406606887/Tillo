//
//  SettingPwdViewModel.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingPwdViewModel.h"
#import "NetworkModel.h"

@implementation SettingPwdViewModel
- (void)initialize {
    self.areaCode = @"855";
    @weakify(self);
    [self.submitCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.submitEndSuject sendNext:nil];
    }];
    
    [self.sendVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.verificationSuccessSubject sendNext:nil];
    }];
}

- (RACSubject *)submitEndSuject {
    if (!_submitEndSuject) {
        _submitEndSuject = [RACSubject subject];
    }
    return _submitEndSuject;
}

- (RACSubject *)verificationSuccessSubject {
    if (!_verificationSuccessSubject) {
        _verificationSuccessSubject = [RACSubject subject];
    }
    return _verificationSuccessSubject;
}

- (RACCommand *)submitCommand {
    if (!_submitCommand) {
        if (!_submitCommand) {
            _submitCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
                return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                    LoadingView(@"");
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSError * error;
                        RequestModel *data= [TSRequest putRequetWithApi:api_forget withParam:input error:&error];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            HiddenHUD
                            if (!error) {
                                [subscriber sendNext:data];
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
    }
    return _submitCommand;
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


@end
