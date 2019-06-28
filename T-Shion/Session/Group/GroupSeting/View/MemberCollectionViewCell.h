//
//  MemberCollectionViewCell.h
//  T-Shion
//
//  Created by together on 2018/8/13.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) MemberModel *model;
@property (strong, nonatomic) UIButton *setBtn;
@property (copy, nonatomic) void (^modifyBlock) (BOOL status);
@property (copy, nonatomic) void (^memberClickBlock) (MemberModel *model);
@property (assign, nonatomic) int type;
@end
