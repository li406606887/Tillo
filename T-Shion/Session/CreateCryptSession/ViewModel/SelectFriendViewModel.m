//
//  SelectFriendViewModel.m
//  T-Shion
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "SelectFriendViewModel.h"
#import "FMDBManager+EncryptStore.h"

@implementation SelectFriendViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.friendsArray = [[FMDBManager shared] selectEncryptionFriend];
        self.indexArray = [NSMutableArray arrayWithCapacity:0];
        NSArray *friends = [FriendsModel sortFriendsArray:self.friendsArray toIndexArray:self.indexArray];
        self.dataArray = [NSMutableArray arrayWithCapacity:0];
        for (NSArray *a in friends) {
            [self.dataArray addObject:a];
        }
    }
    return self;
}

- (RACSubject*)sendMessageClickSubject {
    if (!_sendMessageClickSubject) {
        _sendMessageClickSubject = [RACSubject subject];
    }
    return _sendMessageClickSubject;
}

@end
