//
//  NewManagerViewModel.h
//  AilloTest
//
//  Created by together on 2019/4/19.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NewManagerViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *transferManagerCommand;
@property (strong, nonatomic) RACSubject *transferSuccessSubject;
@end

NS_ASSUME_NONNULL_END
