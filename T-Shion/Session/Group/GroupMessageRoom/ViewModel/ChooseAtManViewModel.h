//
//  ChooseAtManViewModel.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChooseAtManViewModel : BaseViewModel

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, strong) RACSubject *chooseEndSubject;

@end

NS_ASSUME_NONNULL_END
