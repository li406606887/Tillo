//
//  AddMemberViewModel.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddMemberViewModel.h"
#import "YMEncryptionManager.h"
@implementation AddMemberViewModel
- (void)initialize {
    @weakify(self)
    [self.addMemberCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.addSuccessSucject sendNext:x];
        if ([x isKindOfClass:[NSArray class]]) {
            NSArray *array = x;
            NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dic in array) {
                [a addObject:[dic objectForKey:@"userId"]];
            }
            if (a.count > 0)
                [[YMEncryptionManager shareManager] getGroupUserKeys:a];
        }
    }];
}

- (RACCommand *)addMemberCommand {
    if (!_addMemberCommand) {
        _addMemberCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_add_Member withParam:input error:&error];
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
    return _addMemberCommand;
}

- (void)setModel:(GroupModel *)model {
    _model = model;
}

- (RACSubject *)addSuccessSucject {
    if (!_addSuccessSucject) {
        _addSuccessSucject = [RACSubject subject];
    }
    return _addSuccessSucject;
}
@end
