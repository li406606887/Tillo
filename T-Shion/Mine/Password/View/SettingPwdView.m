//
//  SettingPwdView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingPwdView.h"
#import "SettingPwdViewModel.h"
#import "UIView+BorderLine.h"
#import "NetworkModel.h"

@interface SettingPwdView () {
    dispatch_source_t  _verificationTimer;
}

@property (nonatomic, strong) SettingPwdViewModel *viewModel;

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UIView *areaCodeView;
@property (nonatomic, strong) UIImageView *downFlagView;
@property (nonatomic, strong) UILabel *areaCodeLabel;

@property (nonatomic, strong) UITextField *verificationField;
@property (nonatomic, strong) UILabel *verificationLabel;

@property (nonatomic, strong) UITextField *pwdField;

@property (nonatomic, strong) UIButton *submitBtn;



@end


@implementation SettingPwdView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (SettingPwdViewModel *)viewModel;
    self.viewModel.areaCode = [SocketViewModel shared].userModel.dialCode;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.accountField];
    [self addSubview:self.verificationField];
    [self addSubview:self.pwdField];
    [self addSubview:self.submitBtn];
}

- (void)updateConstraints {
    
    [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(55);
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
    
    [self.verificationField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountField.mas_bottom).with.offset(20);
        make.left.equalTo(self.accountField.mas_left);
        make.right.equalTo(self.accountField.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.pwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verificationField.mas_bottom).with.offset(20);
        make.left.equalTo(self.verificationField.mas_left);
        make.right.equalTo(self.verificationField.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdField.mas_bottom).with.offset(65);
        make.left.equalTo(self.accountField.mas_left);
        make.right.equalTo(self.accountField.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [super updateConstraints];
}

- (void)bindViewModel {
    
    @weakify(self)
    [self.viewModel.verificationSuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self createTimer];
    }];
    
}

- (BOOL)isSubmitEnable {
    if (self.accountField.text.length == 0) {
        return NO;
    }
    
    if (self.verificationField.text.length == 0) {
        return NO;
    }
    
    if (self.pwdField.text.length < 6) {
        return NO;
    }
    
    return YES;
}

- (void)createTimer {
    
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _verificationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_verificationTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    __block NSInteger time = 59; //倒计时时间
    
    @weakify(self)
    dispatch_source_set_event_handler(_verificationTimer, ^{
        @strongify(self)
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_verificationTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                self.verificationLabel.userInteractionEnabled = YES;
                self.verificationLabel.text = [NSString stringWithFormat:@"%@",Localized(@"send_verification_code")];
            });
            
        } else {
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                self.verificationLabel.userInteractionEnabled = NO;
                self.verificationLabel.text = [NSString stringWithFormat:@"%d%@",seconds,Localized(@"verification_second")];
            });
            time--;
        }
    });
    
    dispatch_resume(_verificationTimer);
}

- (void)destroyTimer {
    if (_verificationTimer) {
        dispatch_source_cancel(_verificationTimer);
        _verificationTimer = nil;
    }
}


#pragma mark - getter

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
        _accountField.text = [SocketViewModel shared].userModel.mobile;
        _accountField.enabled = NO;
        
    }
    return _accountField;
}

- (UIView *)areaCodeView {
    if (!_areaCodeView) {
        _areaCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 50)];
        [_areaCodeView addSubview:self.downFlagView];
        [_areaCodeView addSubview:self.areaCodeLabel];
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

- (UITextField *)verificationField {
    if (!_verificationField) {
        _verificationField = [[UITextField alloc] init];
        _verificationField.placeholder = Localized(@"please_enter_verification_code");
        _verificationField.font = [UIFont ALFontSize17];
        
        _verificationField.rightView = self.verificationLabel;
        _verificationField.keyboardType = UIKeyboardTypeNumberPad;
        _verificationField.rightViewMode = UITextFieldViewModeAlways;
        _verificationField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _verificationField.borderLineColor = [UIColor ALLineColor].CGColor;
        _verificationField.borderLineStyle = BorderLineStyleBottom;
        
        @weakify(self);
        [[_verificationField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            self.submitBtn.enabled = [self isSubmitEnable];
        }];
    }
    return _verificationField;
}

- (UILabel *)verificationLabel {
    if (!_verificationLabel) {
        _verificationLabel = [UILabel constructLabel:CGRectMake(0, 0, 120, 50)
                                                text:Localized(@"send_verification_code")
                                                font:[UIFont ALFontSize14]
                                           textColor:[UIColor ALBlueColor]];
        _verificationLabel.userInteractionEnabled = YES;
        _verificationLabel.textAlignment = NSTextAlignmentRight;
        
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.accountField.text.length == 0) {
                ShowWinMessage(Localized(@"please_enter_phone_number"));
                return ;
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:self.accountField.text forKey:@"mobile"];
            [dic setObject:self.viewModel.areaCode forKey:@"dialCode"];
            [dic setObject:@"2" forKey:@"type"];
            [self.viewModel.sendVerificationCodeCommand execute:dic];
        }];
        
        [_verificationLabel addGestureRecognizer:tap];
        
    }
    return _verificationLabel;
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
            self.submitBtn.enabled = [self isSubmitEnable];
        }];
    }
    return _pwdField;
}

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitBtn setTitle:Localized(@"Submit") forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont ALBoldFontSize17];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.layer.cornerRadius = 25;
        _submitBtn.enabled = NO;
        
        @weakify(self);
        [[_submitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:self.accountField.text forKey:@"mobile"];
            
            [param setObject:[NSString ym_encryptAES:self.pwdField.text] forKey:@"password"];
            
            [param setObject:self.verificationField.text forKey:@"smsCode"];
            [param setObject:self.viewModel.areaCode forKey:@"dialCode"];
            [self.viewModel.submitCommand execute:param];
            
        }];
    }
    return _submitBtn;
}


@end
