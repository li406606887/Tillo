//
//  LoginViewController.m
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "LoginView.h"
#import "RegisterViewController.h"
#import "RegisterViewModel.h"
#import "LookingForPwdViewController.h"
#import "AreaViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"


@interface LoginViewController ()<RegisterViewControllerDelegate>

@property (strong, nonatomic) UIButton *registerBtn;
@property (strong, nonatomic) LoginView *mainView;
@property (strong, nonatomic) LoginViewModel *viewModel;

@property (nonatomic, strong) RegisterViewModel *registerViewModel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"login")];
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
    [self.view addSubview:self.registerBtn];
}

- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.top.equalTo(self.view.mas_top).with.offset(is_iPhoneX ? 50 : 30);
    }];
    
    [super updateViewConstraints];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.loginSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.releaseBlock();
    }];
    
    [[self.viewModel.forgetClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        LookingForPwdViewController *looking = [[LookingForPwdViewController alloc] init];
        looking.delegate = self;
        if (self.viewModel.countryCode.length > 0) {
            looking.viewModel.countryCode = self.viewModel.countryCode;
        }
        [self.navigationController pushViewController:looking animated:YES];
    }];
    
    [[self.viewModel.clickAreaSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self chooseAreaCode];
    }];
}

- (void)chooseAreaCode {
    @weakify(self)
    AreaViewController *area = [[AreaViewController alloc] init];
    area.areaNameBlock = ^(NSString *code) {
        @strongify(self)

        self.viewModel.areaCode = code;
        self.mainView.areaCodeLabel.text = [NSString stringWithFormat:@"+%@",self.viewModel.areaCode];

    };
    
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:area];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - RegisterViewControllerDelegate
- (void)didAutoLoginSuccess {
    self.releaseBlock();
}

#pragma mark - getter
- (LoginView *)mainView {
    if (!_mainView) {
        _mainView = [[LoginView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerBtn.titleLabel.font = [UIFont ALBoldFontSize17];
        [_registerBtn setTitle:Localized(@"register") forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
        
        @weakify(self)
        [[_registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            RegisterViewController *registerVc = [[RegisterViewController alloc] init];
            registerVc.delegate = self;
            if (self.viewModel.countryCode.length > 0) {
                registerVc.viewModel.countryCode = self.viewModel.countryCode;
            }
            [self.navigationController pushViewController:registerVc animated:YES];
        }];
    }
    return _registerBtn;
}

- (void)dealloc {
//    NSLog(@"登录界面释放了");
}
@end
