//
//  InviteFriendViewModel.m
//  T-Shion
//
//  Created by together on 2018/12/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "InviteFriendViewModel.h"
#import "ALContactManager.h"

@implementation InviteFriendViewModel
- (void)initialize {
    @weakify(self)
    [[ALContactManager sharedInstance] al_accessContactsComplection:^(BOOL state, NSArray<ALSysPerson *> * array) {
        @strongify(self)
        [self.originArray addObjectsFromArray:array];
        [self.refreshUISubject sendNext:nil];
    }];
}

- (NSMutableArray *)addressArray {
    if (!_addressArray) {
        _addressArray = [NSMutableArray array];
    }
    return _addressArray;
}

- (NSMutableArray *)originArray {
    if (!_originArray) {
        _originArray = [NSMutableArray array];
    }
    return _originArray;
}

- (RACSubject *)sendMessageSubject {
    if (!_sendMessageSubject) {
        _sendMessageSubject = [RACSubject subject];
    }
    return _sendMessageSubject;
}

- (RACSubject *)refreshUISubject {
    if (!_refreshUISubject) {
        _refreshUISubject = [RACSubject subject];
    }
    return _refreshUISubject;
}
@end
