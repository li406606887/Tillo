//
//  GroupMemberTableView.h
//  T-Shion
//
//  Created by together on 2018/12/18.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupMemberTableView : BaseView
@property (copy, nonatomic) void (^itemCellClick)(id _Nullable data);
- (instancetype)initWithFrame:(CGRect)frame roomId:(NSString *)roomId array:(NSArray*)array;
@property (copy, nonatomic) void (^sendMessageClick)(id _Nullable data);
@end

NS_ASSUME_NONNULL_END
