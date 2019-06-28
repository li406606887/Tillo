//
//  ALSlideMenu.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/10.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ALSlideMenu.h"

@interface ALSlideMenu : UIViewController

//创建方法
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

@property (copy, nonatomic) void (^releaseBlock)(void);

@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong) UIViewController *leftViewController;

//右侧视图
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic ,assign) BOOL slideEnabled;

//显示主视图
- (void)showRootViewControllerAnimated:(BOOL)animated;

//显示左侧菜单
- (void)showLeftViewControllerAnimated:(BOOL)animated;

//显示右侧菜单
//-(void)showRightViewControllerAnimated:(BOOL)animated;

- (void)removeCache;

@end

