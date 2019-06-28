//
//  FriendsTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/3/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"
//#import "FriendsModel.h"

@interface FriendsTableViewCell : BaseTableViewCell
@property (strong, nonatomic) UILabel *name;

@property (strong, nonatomic) UIImageView *icon;

@property (strong, nonatomic) UIView *line;

@property (strong, nonatomic) FriendsModel *model;

@property (strong, nonatomic) GroupModel *group;

@property (strong, nonatomic) NSArray *msg;

@property (strong, nonatomic) MemberModel *member;
@end
