//
//  LoginView.h
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "LoginViewModel.h"

@interface LoginView : BaseView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UIView *areaCodeView;
@property (nonatomic, strong) UILabel *areaCodeLabel;
@property (nonatomic, strong) UIImageView *downFlagView;

@property (nonatomic, strong) UITextField *pwdField;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *forgetPwdBtn;

@property (strong, nonatomic) LoginViewModel *viewModel;
@end
