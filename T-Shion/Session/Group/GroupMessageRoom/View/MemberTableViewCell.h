//
//  MemberCollectionCell.h
//  T-Shion
//
//  Created by together on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MemberTableViewCell : BaseTableViewCell

@property (strong, nonatomic) MemberModel *model;
@property (copy, nonatomic) void (^menuClickBlock) (int index);
@property (assign, nonatomic) int type;
@end

NS_ASSUME_NONNULL_END
