//
//  LoginView.m
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LoginView.h"
#import "UIView+BorderLine.h"
#import "ALDialCodeManager.h"
#import "NetworkModel.h"

@implementation LoginView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (LoginViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.accountField];
    [self addSubview:self.pwdField];
    [self addSubview:self.loginBtn];
    [self addSubview:self.forgetPwdBtn];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(30);
        make.top.equalTo(self.mas_top).with.offset(is_iPhoneX ? 96 : 76);
    }];
    
    [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(75);
        make.left.equalTo(self.mas_left).with.offset(30);
        make.right.equalTo(self.mas_right).with.offset(-30);
        make.height.mas_equalTo(50);
    }];
    
    [self.areaCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.areaCodeView.mas_centerY);
        make.centerX.equalTo(self.areaCodeView.mas_centerX).with.offset(-20);
    }];
    
    [self.downFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.areaCodeLabel.mas_right).with.offset(10);
        make.centerY.equalTo(self.areaCodeLabel.mas_centerY);
    }];
    
    [self.pwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountField.mas_bottom).with.offset(20);
        make.left.equalTo(self.accountField.mas_left);
        make.right.equalTo(self.accountField.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdField.mas_bottom).with.offset(65);
        make.left.equalTo(self.accountField.mas_left);
        make.right.equalTo(self.accountField.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.forgetPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginBtn.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

- (void)bindViewModel {
    [self getDefaultIPDialCode];
}


#pragma private
- (void)areaCodeClick {
    [self.viewModel.clickAreaSubject sendNext:nil];
}

- (BOOL)isLoginEnable {
    if (_accountField.text.length == 0) {
        return NO;
    }
    
    if (_pwdField.text.length < 6) {
        return NO;
    }
    return YES;
}

- (void)getDefaultIPDialCode {
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    session.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    
    NSMutableURLRequest *request = [session.requestSerializer requestWithMethod:@"GET" URLString:@"http://api.wipmania.com" parameters:nil error:nil];
    
    @weakify(self);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        @strongify(self);
        if (error) {
            return;
        }
        
        NSString *dataString = [responseObject mj_JSONString];
        NSRange range = [dataString rangeOfString:@"<br>"];
        
        if (range.length > 0) {
            NSString *countryCode = [dataString substringFromIndex:range.location + range.length];
            NSLog(@"%@",countryCode);
            self.viewModel.countryCode = countryCode;
            self.viewModel.areaCode = [[ALDialCodeManager sharedInstance] al_selectDialCodeWithCountryCode:countryCode];
            self.areaCodeLabel.text = [NSString stringWithFormat:@"+%@",self.viewModel.areaCode];
        }
    }];
    
    [task resume];
}


#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:Localized(@"login_title")
                                         font:[UIFont ALBoldFontSize28]
                                    textColor:[UIColor ALTextDarkColor]];
    }
    return _titleLabel;
}

- (UITextField *)accountField {
    if (!_accountField) {
        _accountField = [[UITextField alloc] init];
        _accountField.placeholder = Localized(@"please_enter_phone_number");
        _accountField.font = [UIFont ALFontSize17];
        
        _accountField.leftView = self.areaCodeView;
        _accountField.keyboardType = UIKeyboardTypeNumberPad;
        _accountField.leftViewMode = UITextFieldViewModeAlways;
        _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountField.borderLineColor = [UIColor ALLineColor].CGColor;
        _accountField.borderLineStyle = BorderLineStyleBottom;
        
        @weakify(self);
        [[_accountField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            self.loginBtn.enabled = [self isLoginEnable];
        }];
    }
    return _accountField;
}

- (UIView *)areaCodeView {
    if (!_areaCodeView) {
        _areaCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 50)];
        [_areaCodeView addSubview:self.downFlagView];
        [_areaCodeView addSubview:self.areaCodeLabel];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(areaCodeClick)];
        [_areaCodeView addGestureRecognizer:singleTap];
    
    }
    return _areaCodeView;
}

- (UILabel *)areaCodeLabel {
    if (!_areaCodeLabel) {

        _areaCodeLabel = [UILabel constructLabel:CGRectZero
                                            text:[NSString stringWithFormat:@"+%@",self.viewModel.areaCode]
                                            font:[UIFont ALFontSize17]
                                       textColor:[UIColor ALTextNormalColor]];
        _areaCodeLabel.userInteractionEnabled = YES;
    }
    return _areaCodeLabel;
}

- (UIImageView *)downFlagView {
    if (!_downFlagView) {
        _downFlagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow_Down"]];
        _downFlagView.userInteractionEnabled = YES;
    }
    return _downFlagView;
}

- (UITextField *)pwdField {
    if (!_pwdField) {
        _pwdField = [[UITextField alloc] init];
        _pwdField.placeholder = Localized(@"Please_enter_your_password");
        _pwdField.font = [UIFont ALFontSize17];
        
        _pwdField.secureTextEntry = YES;
        _pwdField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwdField.borderLineColor = [UIColor ALLineColor].CGColor;
        _pwdField.borderLineStyle = BorderLineStyleBottom;
        
        @weakify(self);
        [[_pwdField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            self.loginBtn.enabled = [self isLoginEnable];
        }];
    }
    return _pwdField;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:Localized(@"login") forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont ALBoldFontSize17];
        
        [_loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.layer.cornerRadius = 25;
        _loginBtn.enabled = NO;
        
        @weakify(self);
        [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:self.accountField.text forKey:@"mobile"];
            [param setObject:[NSString ym_encryptAES:self.pwdField.text] forKey:@"password"];

            [param setObject:self.viewModel.areaCode forKey:@"dialCode"];
            [self.viewModel.loginCommand execute:param];
        }];
    }
    return _loginBtn;
}

- (UIButton *)forgetPwdBtn {
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetPwdBtn setTitle:Localized(@"Forgot_password") forState:UIControlStateNormal];
        [_forgetPwdBtn.titleLabel setFont:[UIFont ALFontSize13]];
        [_forgetPwdBtn setTitleColor:[UIColor ALBlueColor] forState:UIControlStateNormal];
        
        @weakify(self)
        [[_forgetPwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.viewModel.forgetClickSubject sendNext:nil];
        }];
    }
    return _forgetPwdBtn;
}


@end
