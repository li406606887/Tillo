//
//  LookingForPwdViewController.m
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LookingForPwdViewController.h"
#import "LookingForPwdView.h"
#import "AreaViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface LookingForPwdViewController ()

@property (strong, nonatomic) LookingForPwdView *mainView;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation LookingForPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"Retrieve_password")];
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
    [self.view addSubview:self.backBtn];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.lookforPwdSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
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

}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(15);
        make.top.equalTo(self.view.mas_top).with.offset(is_iPhoneX ? 50 : 30);
    }];
    
    [super viewDidLayoutSubviews];
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

#pragma mark - getter
- (LookingForPwdView *)mainView {
    if (!_mainView) {
        _mainView = [[LookingForPwdView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (LookingForViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LookingForViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"NavigationBar_Back"] forState:UIControlStateNormal];
        
        @weakify(self)
        [[_backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _backBtn;
}

- (void)dealloc {
    NSLog(@"找回密码界面释放了");
}

@end
