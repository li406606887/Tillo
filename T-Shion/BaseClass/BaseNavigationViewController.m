//
//  BaseNavigationViewController.m
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "BaseViewController.h"
#import "AddFriendsViewController.h"

@class AddFriendsViewController;

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 可以在这个方法中拦截所有push进来的控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) { // 如果push进来的不是第一个控制器
        viewController.hidesBottomBarWhenPushed = YES;
        
        
        id target;
        if ([viewController isKindOfClass:[BaseViewController class]]) {
            target = viewController;
        } else {
            target = self;
        }
        
        NSString *imageName = @"NavigationBar_Back";
        
        UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:target
                                                                   action:@selector(backButtonClick)];
        backBtn.tintColor = [UIColor blackColor];
        
        UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if ([viewController isKindOfClass:[AddFriendsViewController class]]) {
            UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:nil
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:target
                                                                       action:nil];
            viewController.navigationItem.leftBarButtonItem = backBtn;
        }else {
            if (@available(iOS 11.0, *)) {
                spaceRight.width = -100;
                viewController.navigationItem.leftBarButtonItem = backBtn;
            } else {
                spaceLeft.width = -25;
                backBtn.imageInsets = UIEdgeInsetsMake(0, 22, 0, -22);
                spaceRight.width = 15;
                viewController.navigationItem.leftBarButtonItems = @[spaceLeft, backBtn, spaceRight];
            }
        }
    }
    [super pushViewController:viewController animated:animated];
    
}

- (void)back {
    [self popViewControllerAnimated:YES];
}

#pragma mark - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.childViewControllers.count > 1;
}

@end
