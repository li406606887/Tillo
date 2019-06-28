//
//  FriendsTableViewCell+SessionModel.h
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "CreatGroupTableViewCell.h"
#import "OperMemberCollectionCell.h"
#import "GroupModel.h"

@interface CreatGroupTableViewCell (GroupModel)

@property (nonatomic, strong) GroupModel *group;

@end

@interface OperMemberCollectionCell (GroupModel)

@property (nonatomic, strong) GroupModel *group;

@end

