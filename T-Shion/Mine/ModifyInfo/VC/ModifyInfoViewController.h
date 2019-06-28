//
//  ModifyInfoViewController.h
//  T-Shion
//
//  Created by together on 2018/6/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@interface ModifyInfoViewController : BaseViewController
@property (copy, nonatomic) NSString *param;
@property (copy, nonatomic) NSString *fieldValue;
@property (assign, nonatomic) int type;//1.modify other information 0.modify self information
@property (copy, nonatomic) void (^successBlock) (id param);
@end
