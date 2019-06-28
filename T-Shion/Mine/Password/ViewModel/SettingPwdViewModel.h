//
//  SettingPwdViewModel.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"


@interface SettingPwdViewModel : BaseViewModel

@property (nonatomic, copy) NSString *areaCode;


@property (nonatomic, strong) RACSubject *submitEndSuject;
@property (nonatomic, strong) RACCommand *submitCommand;

@property (strong, nonatomic) RACCommand *sendVerificationCodeCommand;
@property (strong, nonatomic) RACSubject *verificationSuccessSubject;



@end

