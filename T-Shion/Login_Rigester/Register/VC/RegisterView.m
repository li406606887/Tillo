//
//  RegisterView.m
//  T-Shion
//
//  Created by together on 2018/6/15.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "RegisterView.h"
#import "RegisterViewModel.h"
#import "UIView+BorderLine.h"
#import "ALDialCodeManager.h"
#import "NetworkModel.h"


#define RSAPublicKey @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnu8Hb0dmXy9BQ5vudc+AEBlDHw5ifCVthZrpaCaEcVIbFqacy6HcS3H6tmr3M1dMrs+YoLpSHdBtx2JsfS2fF7/W9AzoTZ4ZILNZMP763pJlRC5mlbVpSuZ6fIN0HVdCcWm2qJ2XLtxh3WbY/8bEJmJ/AKI7cd+JbJdX0wdaqbwIDAQAB"


@interface RegisterView ()<UITextViewDelegate> {
    dispatch_source_t  _verificationTimer;
}

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UIView *areaCodeView;
@property (nonatomic, strong) UIImageView *downFlagView;

@property (nonatomic, strong) UITextField *verificationField;
@property (nonatomic, strong) UILabel *verificationLabel;

@property (nonatomic, strong) UITextField *pwdField;
@property (nonatomic, strong) UIButton *registerBtn;

@property (strong, nonatomic) UITextView *agreement;

@property (strong, nonatomic) RegisterViewModel *viewModel;


@end

@implementation RegisterView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (RegisterViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];
    [self addSubview:self.accountField];
    [self addSubview:self.verificationField];
    [self addSubview:self.pwdField];
    [self addSubview:self.registerBtn];
    [self addSubview:self.agreement];
    
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

    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdField.mas_bottom).with.offset(65);
        make.left.equalTo(self.accountField.mas_left);
        make.right.equalTo(self.accountField.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.agreement mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registerBtn.mas_bottom).with.offset(130);
        make.centerX.equalTo(self);
    }];
}

- (void)bindViewModel {
    if (self.viewModel.countryCode.length > 0) {
        self.viewModel.areaCode = [[ALDialCodeManager sharedInstance] al_selectDialCodeWithCountryCode:self.viewModel.countryCode];
        self.areaCodeLabel.text = [NSString stringWithFormat:@"+%@",self.viewModel.areaCode];
    } else {
        [self getDefaultIPDialCode];
    }
    
    @weakify(self)
    [self.viewModel.verificationSuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self createTimer];
    }];
}

- (void)areaCodeClick {
    [self.viewModel.clickAreaSubject sendNext:nil];
}

- (BOOL)isRegisterEnable {
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

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([[URL scheme] isEqualToString:@"userAgreement"]) {
        NSLog(@"用户协议---------------");
        [self.viewModel.agreementSubject sendNext:@(2)];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"terms"]) {
        NSLog(@"条款---------------");
        [self.viewModel.agreementSubject sendNext:@(1)];
        return NO;
    }
    return YES;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:Localized(@"register_title")
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
            self.registerBtn.enabled = [self isRegisterEnable];
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
            self.registerBtn.enabled = [self isRegisterEnable];
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

            [dic setObject:@"1" forKey:@"type"];
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
            self.registerBtn.enabled = [self isRegisterEnable];
        }];
    }
    return _pwdField;
}


- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:Localized(@"register") forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = [UIFont ALBoldFontSize17];
        
        [_registerBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_registerBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        _registerBtn.layer.masksToBounds = YES;
        _registerBtn.layer.cornerRadius = 25;
        _registerBtn.enabled = NO;
        
        @weakify(self);
        [[_registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:self.verificationField.text forKey:@"smsCode"];
            [param setObject:self.accountField.text forKey:@"mobile"];
            
            [param setObject:[NSString ym_encryptAES:self.pwdField.text] forKey:@"password"];

            [param setObject:self.viewModel.areaCode forKey:@"dialCode"];
            [self.viewModel.registerCommand execute:param];
        }];

    }
    return _registerBtn;
}

- (UITextView *)agreement {
    if (!_agreement) {
        _agreement = [[UITextView alloc] init];
        _agreement.backgroundColor = [UIColor clearColor];
        _agreement.textAlignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:Localized(@"register_agreement")];
        
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"userAgreement://"
                                 range:[[attributedString string] rangeOfString:Localized(@"register_termsOfService")]];
        
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"terms://"
                                 range:[[attributedString string] rangeOfString:Localized(@"register_privacyPolicy")]];
        _agreement.attributedText = attributedString;
        _agreement.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor ALBlueColor],
                                          NSUnderlineColorAttributeName: [UIColor ALTextNormalColor],
                                          NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
        _agreement.delegate = self;
        _agreement.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
        _agreement.scrollEnabled = NO;
    }
    return _agreement;
}

@end
