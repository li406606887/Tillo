//
//  FriendsValidationTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/3/30.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface FriendsValidationTableViewCell : BaseTableViewCell
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UIImageView *phoneImage;
@property (strong, nonatomic) UILabel *phoneLabel;
@property (strong, nonatomic) UILabel *validationInfo;
@property (strong, nonatomic) UIButton *agree;
@property (nonatomic, strong) UIView *segline;

@property (copy, nonatomic) void (^buttonClickBlock)(FriendsModel *model);

@property (weak, nonatomic) FriendsModel *model;
@end
