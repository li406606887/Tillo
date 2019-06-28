//
//  SelectFriendViewController.h
//  T-Shion
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectFriendViewController : BaseViewController

@property (nonatomic, copy) void (^completeBlock)(FriendsModel *model);

@end

NS_ASSUME_NONNULL_END
