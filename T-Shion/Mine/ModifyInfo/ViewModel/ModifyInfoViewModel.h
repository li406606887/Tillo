//
//  ModifyInfoViewModel.h
//  T-Shion
//
//  Created by together on 2018/6/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface ModifyInfoViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *modifyInfoCommand;
@property (strong, nonatomic) RACCommand *modifyFriendInfoCommand;
@property (copy, nonatomic) NSString *friendId;
@property (strong, nonatomic) RACSubject *modifySuccessSubject;
@end
