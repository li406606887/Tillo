//
//  DeleteGroupMemberViewController.h
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@class GroupModel;

@interface DeleteGroupMemberViewController : BaseViewController
- (instancetype)initWithGroupModel:(GroupModel *)model data:(NSMutableDictionary *)data;

@end
