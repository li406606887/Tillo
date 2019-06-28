//
//  DialogueViewModel.m
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SessionViewModel.h"

@implementation SessionViewModel

- (RACSubject *)sessionCellClickSubject {
    if (!_sessionCellClickSubject) {
        _sessionCellClickSubject = [RACSubject subject];
    }
    return _sessionCellClickSubject;
}

- (RACSubject *)menuCellClickSubject {
    if (!_menuCellClickSubject) {
        _menuCellClickSubject = [RACSubject subject];
    }
    return _menuCellClickSubject;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (RACSubject *)refreshTableSubject {
    if (!_refreshTableSubject) {
        _refreshTableSubject = [RACSubject subject];
    }
    return _refreshTableSubject;
}

- (RACSubject *)scrollSubject {
    if (!_scrollSubject) {
        _scrollSubject = [RACSubject subject];
    }
    return _scrollSubject;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [FMDBManager selectConversationTable];
    }
    return _dataArray;
}
@end
