//
//  SessionModel+Transmit.h
//  AilloTest
//
//  Created by mac on 2019/2/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SessionModel (Transmit)

///转发时是否被选中了
@property (nonatomic, assign) BOOL transmitSelected;

@end

@interface FriendsModel (Transmit)
///转发时是否被选中了
@property (nonatomic, assign) BOOL transmitSelected;

///转发时在最近联系人中选中了，则联系人中不可修改(YES)
@property (nonatomic, assign) BOOL disableSelect;

@end

@interface GroupModel (Transmit)
///转发时是否被选中了
@property (nonatomic, assign) BOOL transmitSelected;

///转发时在最近联系人中选中了，则联系人中不可修改(YES)
@property (nonatomic, assign) BOOL disableSelect;

@end

NS_ASSUME_NONNULL_END
