
//
//  MineViewModel.m
//  T-Shion
//
//  Created by together on 2018/6/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MineViewModel.h"

@implementation MineViewModel


- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (RACSubject *)headClickSubject {
    if (!_headClickSubject) {
        _headClickSubject = [RACSubject subject];
    }
    return _headClickSubject;
}
@end
