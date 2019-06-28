//
//  AddFriendSearchView.h
//  T-Shion
//
//  Created by together on 2018/12/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddFriendSearchView : UIView
@property (strong, nonatomic) UITextField *searchField;
@property (copy, nonatomic) void (^searchUserBlock) (NSDictionary *data);
@end

NS_ASSUME_NONNULL_END
