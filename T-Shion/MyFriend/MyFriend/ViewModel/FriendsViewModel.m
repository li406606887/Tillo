//
//  FriendsViewModel.m
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsViewModel.h"
#import "FriendsModel.h"

@implementation FriendsViewModel
- (NSMutableArray *)userSorting:(NSMutableArray *)modelArr {
    ///modify by chw for reduce code redundancy 2019.02.27
    self.indexArray = [NSMutableArray arrayWithCapacity:0];
    
    return [FriendsModel sortFriendsArray:modelArr toIndexArray:self.indexArray];
}

- (RACSubject *)setingClickSubject {
    if (!_setingClickSubject) {
        _setingClickSubject = [RACSubject subject];
    }
    return _setingClickSubject;
}

- (RACSubject *)sendMessageClickSubject {
    if (!_sendMessageClickSubject) {
        _sendMessageClickSubject = [RACSubject subject];
    }
    return _sendMessageClickSubject;
}

- (RACSubject *)validationClickSubject {
    if (!_validationClickSubject) {
        _validationClickSubject = [RACSubject subject];
    }
    return _validationClickSubject;
}

- (RACSubject *)iconClickSubject {
    if (!_iconClickSubject) {
        _iconClickSubject = [RACSubject subject];
    }
    return _iconClickSubject;
}

- (RACSubject *)scrollSubject {
    if (!_scrollSubject) {
        _scrollSubject = [RACSubject subject];
    }
    return _scrollSubject;
}

- (NSMutableArray *)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *array = [FMDBManager selectFriendTable];
        _dataArray = [self userSorting:array];
    }
    return _dataArray;
}
@end
