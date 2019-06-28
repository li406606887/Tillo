//
//  DeleteGroupMemberViewModel.m
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "DeleteGroupMemberViewModel.h"

@implementation DeleteGroupMemberViewModel
- (void)initialize {
    @weakify(self)
    [self.deleteMemberCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            HiddenHUD;
            [self.deleteSuccessSubject sendNext:nil];
        });
    }];
}

- (RACCommand *)deleteMemberCommand {
    if (!_deleteMemberCommand) {
        _deleteMemberCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingWin(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_deleteMember withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
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
    return _deleteMemberCommand;
}

- (RACSubject *)deleteSuccessSubject {
    if (!_deleteSuccessSubject) {
        _deleteSuccessSubject = [RACSubject subject];
    }
    return _deleteSuccessSubject;
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
}

@end
