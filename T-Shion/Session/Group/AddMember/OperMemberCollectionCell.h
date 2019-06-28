//
//  OperMemberCollectionCell.h
//  T-Shion
//
//  Created by together on 2019/1/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OperMemberCollectionCell : UICollectionViewCell
@property (copy, nonatomic) FriendsModel *model;
@property (copy, nonatomic) MemberModel *member;
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *setBtn;
@property (copy, nonatomic) void (^modifyBlock) (void);
@end

NS_ASSUME_NONNULL_END
