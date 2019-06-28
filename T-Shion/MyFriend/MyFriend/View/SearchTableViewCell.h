//
//  SearchTableViewCell.h
//  T-Shion
//
//  Created by together on 2019/3/20.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchTableViewCell : BaseTableViewCell
@property (strong, nonatomic) UIImageView *avatar;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *centerTitle;
@property (strong, nonatomic) UILabel *describe;
@property (strong, nonatomic) UIView *line;
@property (weak, nonatomic) FriendsModel *friendModel;
@property (weak, nonatomic) GroupModel *groupModel;
@property (weak, nonatomic) NSArray *msgArray;
@end

NS_ASSUME_NONNULL_END
