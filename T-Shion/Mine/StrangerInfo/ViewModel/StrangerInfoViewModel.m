//
//  StrangerInfoViewModel.m
//  T-Shion
//
//  Created by together on 2018/8/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "StrangerInfoViewModel.h"

@implementation StrangerInfoViewModel
- (void)initialize {
    @weakify(self)
    [self.addFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.addSuccessSucject sendNext:nil];
    }];
}

- (RACCommand *)addFriendsCommand {
    if (!_addFriendsCommand) {
        _addFriendsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_add_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            NSLog(@"%@",model.data);
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
    return _addFriendsCommand;
}

- (void)setMember:(MemberModel *)member {
    _member = member;
}

- (RACSubject *)addSuccessSucject {
    if (!_addSuccessSucject) {
        _addSuccessSucject = [RACSubject subject];
    }
    return _addSuccessSucject;
}
@end
