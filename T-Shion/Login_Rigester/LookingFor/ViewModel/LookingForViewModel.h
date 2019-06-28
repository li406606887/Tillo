//
//  LookingForViewModel.h
//  T-Shion
//
//  Created by together on 2018/9/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface LookingForViewModel : BaseViewModel

@property (nonatomic, copy) NSString *areaCode;
@property (nonatomic, copy) NSString *countryCode;

@property (strong, nonatomic) RACCommand *loginCommand;//登录
@property (strong, nonatomic) RACCommand *lookforPwdCommand;
@property (strong, nonatomic) RACCommand *sendVerificationCodeCommand;
@property (strong, nonatomic) RACSubject *lookforPwdSubject;
@property (strong, nonatomic) RACSubject *clickAreaSubject;//选择国家代码
@property (strong, nonatomic) RACSubject *verificationSuccessSubject;
@property (strong, nonatomic) RACSubject *loginSubject;//登录成功回调


@end
