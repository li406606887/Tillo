//
//  CreatGroupTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsTableViewCell.h"

@interface CreatGroupTableViewCell : FriendsTableViewCell
@property (strong, nonatomic) UIButton *selectedBtn;
@property (copy, nonatomic) void (^clickBlock) (BOOL state);
@end
