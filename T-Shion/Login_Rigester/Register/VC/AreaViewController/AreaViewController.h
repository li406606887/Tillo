//
//  AreaViewController.h
//  T-Shion
//
//  Created by together on 2018/4/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@interface AreaViewController : BaseViewController
@property (copy, nonatomic) void (^areaNameBlock) (NSString *code);
@end
