//
//  AddFriendsTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/4/13.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "AddFriendsModel.h"

@interface AddFriendsTableViewCell : BaseTableViewCell
@property (strong, nonatomic) UIView *iconBack;
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UIButton *agree;
@property (strong, nonatomic) UIImageView *phoneImage;
@property (strong, nonatomic) UILabel *phoneLabel;
@property (strong, nonatomic) UIView *backView;

@property (weak, nonatomic) AddFriendsModel *model;

@property (copy, nonatomic) void (^buttonClickBlock)(AddFriendsModel *model);
@end
