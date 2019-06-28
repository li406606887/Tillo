//
//  GroupSessionViewModel.m
//  T-Shion
//
//  Created by together on 2018/7/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSessionViewModel.h"
#import "GroupSessionModel.h"

@implementation GroupSessionViewModel

- (void)initialize {
}

- (RACSubject *)dialogueCellClickSubject {
    if (!_dialogueCellClickSubject) {
        _dialogueCellClickSubject = [RACSubject subject];
    }
    return _dialogueCellClickSubject;
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

//- (NSMutableArray *)dataArray {
//    if (!_dataArray) {
//        _dataArray = [FMDBManager selectGroupConversationTable];
//    }
//    return _dataArray;
//}
@end
