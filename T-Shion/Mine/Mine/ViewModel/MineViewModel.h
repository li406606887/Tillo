//
//  MineViewModel.h
//  T-Shion
//
//  Created by together on 2018/6/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface MineViewModel : BaseViewModel
@property (strong, nonatomic) RACSubject *cellClickSubject;
@property (strong, nonatomic) RACSubject *headClickSubject;
@end