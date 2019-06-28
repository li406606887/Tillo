//
//  SettingViewController.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/23.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingView.h"
#import "SettingViewModel.h"
#import "ArchiveViewController.h"
#import "StorageViewController.h"
#import "AboutUsViewController.h"
#import "TabBarViewController.h"
#import "SubmitBugViewController.h"
#import "NavCenterTitleView.h"
#import "SettingPwdController.h"
#import "LanguageViewController.h"
#import "BlackUserViewController.h"
#import "AppDelegate.h"
#import "SettingHeadView.h"
#import "MyInfoViewController.h"
#import "QRCodeViewController.h"
#import "NotifySetViewController.h"
#import "DownSetingViewController.h"

@interface SettingViewController ()<SettingHeadViewDelegate>
@property (strong , nonatomic) SettingView *mainView;
@property (strong , nonatomic) SettingViewModel *viewModel;
@property (strong, nonatomic) NavCenterTitleView *navigationView;
@property (nonatomic, strong) SettingHeadView *headView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.headView];
    [self.view addSubview:self.mainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - system
- (void)updateViewConstraints {
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo(is_iPhoneX ? 190 : 160);
    }];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.headView.mas_bottom);
    }];
    
    [super updateViewConstraints];
}

- (UIView *)centerView {
    return self.navigationView;
}

#pragma mark - private
- (void)bindViewModel {
    @weakify(self);
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        
        UINavigationController *tempNav;
        
        if (([x integerValue] != 7) && ([x integerValue] != 4)) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate.slideVC showRootViewControllerAnimated:YES];
            tempNav = delegate.main.selectedViewController;
        }
        
        switch ([x intValue]) {
            case 0: {
                SettingPwdController *setPwdVC = [[SettingPwdController alloc] init];
                [tempNav pushViewController:setPwdVC animated:YES];
            }
                break;
            case 1: {
                NotifySetViewController *setPwdVC = [[NotifySetViewController alloc] init];
                [tempNav pushViewController:setPwdVC animated:YES];
            }
                break;
            case 2: {
                DownSetingViewController *downSet = [[DownSetingViewController alloc] init];
                [tempNav pushViewController:downSet animated:YES];
            }
                break;
            case 3: {
                StorageViewController *storage = [[StorageViewController alloc] init];
                [tempNav pushViewController:storage animated:YES];
            }
                break;
                
            case 4: {
                BlackUserViewController *blackVC = [[BlackUserViewController alloc] init];
                [tempNav pushViewController:blackVC animated:YES];
            }
                break;
                
            case 5: {
                LanguageViewController *language = [[LanguageViewController alloc] init];
                BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:language];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
            }
                break;
                
            case 6: {
                SubmitBugViewController *submitBug = [[SubmitBugViewController alloc] init];
                [tempNav pushViewController:submitBug animated:YES];
            }
                break;
                
            case 7: {
                AboutUsViewController *about = [[AboutUsViewController alloc] init];
                [tempNav pushViewController:about animated:YES];
            }
                break;
                
            case 8: {
                [[TSRequest request] cancelAllOperations];
                [self.viewModel.logoutCommand execute:nil];
            }
                break;
                
                
            default:
                break;
        }
    }];
    
    [[self.viewModel.loginOutSuccessSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        if ([x intValue] == 0) {
            [SocketViewModel cleanUserData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"exitLogin" object:nil];
        }
    }];
}

#pragma mark - SettingHeadViewDelegate
- (void)shouldGotoUserInfo {
    UINavigationController *tempNav;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.slideVC showRootViewControllerAnimated:YES];
    tempNav = delegate.main.selectedViewController;
    
    MyInfoViewController *myInfo = [[MyInfoViewController alloc] init];
    [tempNav pushViewController:myInfo animated:YES];
}

- (void)didQRCodeButtonClick {
    UINavigationController *tempNav;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.slideVC showRootViewControllerAnimated:YES];
    tempNav = delegate.main.selectedViewController;
    
    QRCodeViewController *qrCodeVC = [[QRCodeViewController alloc] init];
    [tempNav pushViewController:qrCodeVC animated:YES];
}

#pragma mark - getter and setter
- (SettingView *)mainView {
    if (!_mainView) {
        _mainView = [[SettingView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (SettingViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SettingViewModel alloc] init];
    }
    return _viewModel;
}

- (SettingHeadView *)headView {
    if (!_headView) {
        _headView = [[SettingHeadView alloc] init];
        _headView.delegate = self;
    }
    return _headView;
}

- (void)dealloc {
    NSLog(@"setting释放了");
    
}
@end
