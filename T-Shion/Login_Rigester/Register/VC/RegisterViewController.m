//
//  RegisterViewController.m
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "RegisterViewController.h"
#import "AreaViewController.h"
#import "RegisterView.h"
#import "PrivacyThatViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface RegisterViewController ()

@property (strong, nonatomic) RegisterView *mainView;

@property (strong, nonatomic) UIButton *loginBtn;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTitle:Localized(@"register")];
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
    [self.view addSubview:self.loginBtn];
}

- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.top.equalTo(self.view.mas_top).with.offset(is_iPhoneX ? 50 : 30);
    }];
    
    [super updateViewConstraints];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.clickAreaSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self chooseAreaCode];
    }];
    
    [[self.viewModel.loginSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(didAutoLoginSuccess)]) {
            [self.delegate didAutoLoginSuccess];
        }
    }];
    
    [self.viewModel.agreementSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        PrivacyThatViewController *privacy = [[PrivacyThatViewController alloc] init];
        privacy.type = [x intValue];
        [self.navigationController pushViewController:privacy animated:YES];
    }];
    
    
    [self.viewModel.goBackSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
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
//    [self.navigationController pushViewController:area animated:YES];
}

- (void)dealloc {
    NSLog(@"注册一界面释放了");
}

#pragma mark - getter
- (RegisterView *)mainView {
    if (!_mainView) {
        _mainView = [[RegisterView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (RegisterViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RegisterViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.titleLabel.font = [UIFont ALBoldFontSize17];
        [_loginBtn setTitle:Localized(@"login") forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
        
        @weakify(self)
        [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _loginBtn;
}


@end
