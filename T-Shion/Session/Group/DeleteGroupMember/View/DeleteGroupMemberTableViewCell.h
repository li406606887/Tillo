//
//  DeleteGroupMemberTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsTableViewCell.h"

@interface DeleteGroupMemberTableViewCell : FriendsTableViewCell
@property (copy, nonatomic) void (^clickBlock) (BOOL sate);
@end
