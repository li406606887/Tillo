//
//  ChooseAtManViewModel.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ChooseAtManViewModel.h"

@implementation ChooseAtManViewModel

- (RACSubject *)chooseEndSubject {
    if (!_chooseEndSubject) {
        _chooseEndSubject = [RACSubject subject];
    }
    return _chooseEndSubject;
}

@end
