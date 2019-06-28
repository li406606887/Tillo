//
//  ModifyGroupViewController.h
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@interface ModifyGroupViewController : BaseViewController
@property (copy, nonatomic) GroupModel *model;

@property (nonatomic, assign) NSInteger modifyType;//0:群昵称 1:成员在群的昵称

@end
