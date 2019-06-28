//
//  ChooseSexViewController.h
//  T-Shion
//
//  Created by together on 2018/6/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@interface ChooseSexViewController : BaseViewController
@property (copy, nonatomic) void (^chooseBlock) (NSString *sex);
@end
