//
//  LoginViewModel.h
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface LoginViewModel : BaseViewModel

@property (strong, nonatomic) RACSubject *forgetClickSubject;

@property (strong, nonatomic) RACCommand *loginCommand;

@property (strong, nonatomic) RACSubject *loginSubject;

@property (strong, nonatomic) RACCommand *getInfoCommand;

@property (nonatomic, strong) RACSubject *clickAreaSubject;

@property (strong, nonatomic) RACCommand *notifySetCommand;

@property (nonatomic, copy) NSString *areaCode;
@property (nonatomic, copy) NSString *countryCode;

@end
