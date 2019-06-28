//
//  InviteFriendTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/12/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "InviteFriendModel.h"
#import "ALSysPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface InviteFriendTableViewCell : BaseTableViewCell
@property (weak, nonatomic) InviteFriendModel *model;

@property (nonatomic, weak) ALSysPerson *sysPerson;
@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface InviteLinkTableViewCell : BaseTableViewCell
@property (copy, nonatomic) void (^itemClickBlock) (int index);
@end

NS_ASSUME_NONNULL_END
