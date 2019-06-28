//
//  SettingPwdController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingPwdController.h"
#import "SettingPwdView.h"
#import "SettingPwdViewModel.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface SettingPwdController ()

@property (nonatomic, strong) SettingPwdView *mainView;
@property (nonatomic, strong) SettingPwdViewModel *viewModel;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIButton *backBtn;


@end


@implementation SettingPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"Set_password")];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)fd_prefersNavigationBarHidden {
//    return YES;
//}

- (void)addChildView {
    [self.view addSubview:self.mainView];
//    [self.view addSubview:self.backBtn];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).with.offset(15);
//        make.top.equalTo(self.view.mas_top).with.offset(30);
//    }];

    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self);
    
    [[self.viewModel.submitEndSuject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - getter
- (SettingPwdView *)mainView {
    if (!_mainView) {
        _mainView = [[SettingPwdView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (SettingPwdViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SettingPwdViewModel alloc] init];
    }
    return _viewModel;
}

//- (UIButton *)backBtn {
//    if (!_backBtn) {
//        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_backBtn setImage:[UIImage imageNamed:@"NavigationBar_Back"] forState:UIControlStateNormal];
//
//        @weakify(self)
//        [[_backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            @strongify(self)
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
//    }
//    return _backBtn;
//}


@end
