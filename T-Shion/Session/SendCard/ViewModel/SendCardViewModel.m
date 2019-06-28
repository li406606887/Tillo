//
//  SendCardViewModel.m
//  AilloTest
//
//  Created by together on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "SendCardViewModel.h"

@implementation SendCardViewModel

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        NSMutableArray *array = [FriendsModel sortFriendsArray:self.array toIndexArray:self.indexArray];
        [_dataArray addObjectsFromArray:array];
    }
    return _dataArray;
}

- (NSMutableArray *)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (NSArray *)array {
    if (!_array) {
        NSMutableArray *dataArray = [FMDBManager selectFriendTable];
        NSArray *mutableArray = [NSMutableArray arrayWithArray:dataArray];
        for (FriendsModel *fm in mutableArray) {
            if ([fm.userId isEqualToString:self.uid]) {
                [dataArray removeObject:fm];
            }
        }
        _array = [NSArray arrayWithArray:dataArray];
    }
    return _array;
}

- (RACSubject *)clickSubject {
    if (!_clickSubject) {
        _clickSubject = [RACSubject subject];
    }
    return _clickSubject;
}
@end
