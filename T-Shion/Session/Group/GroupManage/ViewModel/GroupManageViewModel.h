//
//  GroupManageViewModel.h
//  T-Shion
//
//  Created by together on 2019/4/19.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupManageViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *putGroupInviteCommand;
@property (weak, nonatomic) GroupModel *group;
@end

NS_ASSUME_NONNULL_END
