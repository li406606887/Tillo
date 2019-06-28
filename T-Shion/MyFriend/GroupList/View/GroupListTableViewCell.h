//
//  GroupMessageTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/7/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "GroupModel.h"

@interface GroupListTableViewCell : BaseTableViewCell
@property (copy, nonatomic) GroupModel *groupModel;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *name;
@property (nonatomic, strong) UIView *segLine;
@end
