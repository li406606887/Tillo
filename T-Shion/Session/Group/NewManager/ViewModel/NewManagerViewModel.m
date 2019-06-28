//
//  NewManagerViewModel.m
//  AilloTest
//
//  Created by together on 2019/4/19.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NewManagerViewModel.h"

@implementation NewManagerViewModel
- (void)initialize {
    @weakify(self)
    [self.transferManagerCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        GroupModel *model = [GroupModel mj_objectWithKeyValues:x];
        model.roomId = x[@"id"];
        [self.transferSuccessSubject sendNext:model];
    }];
}

- (RACCommand *)transferManagerCommand {
    if (!_transferManagerCommand) {
        _transferManagerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_transferGroup withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (error == nil) {
                            [subscriber sendNext:model.data];
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
    return _transferManagerCommand;
}

- (RACSubject *)transferSuccessSubject {
    if (!_transferSuccessSubject) {
        _transferSuccessSubject = [RACSubject subject];
    }
    return _transferSuccessSubject;
}
@end
