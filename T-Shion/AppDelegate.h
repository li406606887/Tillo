//
//  AppDelegate.h
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import "LoginViewController.h"
#import "ALSlideMenu.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TabBarViewController *main;

@property (strong, nonatomic) BaseNavigationViewController *nav;

@property (strong, nonatomic) LoginViewController *login;

@property (assign, nonatomic) BOOL state;

@property (nonatomic, strong) ALSlideMenu *slideVC;//侧滑边栏控制器

@end

