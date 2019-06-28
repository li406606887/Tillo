//
//  BaseViewController.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNavigationBar];
    self.navigationController.navigationBar.barTintColor = self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor ALKeyBgColor];
     [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];

    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    //点击背景收回键盘
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //隐藏键盘工具栏
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [self addChildView];
    [self bindViewModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 滑动开始会触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    [[IQKeyboardManager sharedManager] resignFirstResponder];
    if (self.navigationController.viewControllers.count <= 1) return NO;
    return YES;
}

- (void)setUpNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [self rightButton];//设置导航栏右边按钮
    self.navigationItem.titleView = [self centerView];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[UIColor ALLineColor] size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (UIBarButtonItem *)leftButton {
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btn setImage:[UIImage imageNamed:@"NavigationBar_Back"] forState:UIControlStateNormal];//设置左边按钮的图片
    [btn addTarget:self action:@selector(actionOnTouchBackButton:) forControlEvents:UIControlEventTouchUpInside];//设置按钮的点击事件
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (UIBarButtonItem *)rightButton {
    return nil;
}

- (UIView *)centerView {
    return nil;
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionOnTouchBackButton:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hiddenFriendsViewController:(UIButton *)button {
//    [self.tabBarController.view addSubview:[TShionSingleCase shared].friends];
//    [[TShionSingleCase shared].friends show];
}

- (void)addChildView {
}

- (void)bindViewModel {
    
}

@end
