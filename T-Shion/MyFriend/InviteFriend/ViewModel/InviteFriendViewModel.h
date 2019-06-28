//
//  InviteFriendViewModel.h
//  T-Shion
//
//  Created by together on 2018/12/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface InviteFriendViewModel : BaseViewModel
@property (strong, nonatomic) RACSubject *sendMessageSubject;
@property (strong, nonatomic) RACSubject *refreshUISubject;
@property (strong, nonatomic) NSMutableArray *addressArray;
@property (strong, nonatomic) NSMutableArray *originArray;
@end

NS_ASSUME_NONNULL_END
