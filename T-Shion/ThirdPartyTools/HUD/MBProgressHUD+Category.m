//
//  MBProgressHUD+Category.m
//  T-Shion
//
//  Created by together on 2018/4/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MBProgressHUD+Category.h"

@implementation MBProgressHUD (Category)
/**
 *  显示信息
 *  @param title 信息内容
 */
+ (void)showWindowPromptTitle:(NSString *)title {
    [self showMessage:title icon:nil isWindow:YES];
}
/**
 *  显示信息
 *  @param title 信息内容
 */
+ (void)showViewPromptTitle:(NSString *)title {
    [self showMessage:title icon:nil isWindow:NO];
}
/**
 *  显示信息
 *  @param title 信息内容
 */
+ (void)showWindowPromptTitle:(NSString *)title icon:(NSString*)icon{
    [self showMessage:title icon:nil isWindow:YES];
}
/**
 *  显示信息
 *  @param title 信息内容
 */
+ (void)showViewPromptTitle:(NSString *)title icon:(NSString*)icon{
    [self showMessage:title icon:icon isWindow:NO];
}
/**
 *  显示信息
 *  @param error 信息内容
 */
+ (void)showError:(NSString *)error {
    [self showViewPromptTitle:error icon:@""];
}
/**
 *  显示信息
 *  @param error 信息内容
 */
+ (void)showWindowError:(NSString *)error {
    [self showWindowPromptTitle:error icon:@""];
}
/**
 *  显示信息
 *  @param success 信息内容
 */
+ (void)showSuccess:(NSString *)success{
    [self showViewPromptTitle:success icon:@""];
}
/**
 *  显示信息
 *  @param success 信息内容
 */
+ (void)showWindowSuccess:(NSString *)success {
    [self showWindowPromptTitle:success icon:@""];
}
/**
 *  隐藏HUD
 */
+ (void)hiddenHUD {
    UIView  *winView =(UIView*)[UIApplication sharedApplication].delegate.window;
    [self hideAllHUDsForView:winView animated:YES];
    [self hideAllHUDsForView:[self getCurrentUIVC].view animated:YES];
}

+ (void)loadingViewWithMessage:(NSString *)message {
    [self loadingHubWithMessage:message icon:nil isWinDow:NO];
}

+ (void)loadingWindowWithMessage:(NSString *)message {
    [self loadingHubWithMessage:message icon:nil isWinDow:YES];
}
/**
 *  网络请求加载时
 *  @param message 信息内容
 *  @param isWinDow 是否显示在Window层
 *  @param icon 图标
 *  @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)loadingHubWithMessage:(NSString *)message icon:(NSString *)icon isWinDow:(BOOL)isWinDow  {
    MBProgressHUD *hud = [self createMBProgressHUDviewWithMessage:message isWindow:isWinDow];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    hud.label.text = message;
    hud.removeFromSuperViewOnHide = YES;
    //    hud.graceTime = 10.0f;
    return hud;
}
/**
 *  显示信息
 *
 *  @param message 信息内容
 *  @param icon 图标
 *  @param isWindow 是否显示在Window层
 */
+ (void)showMessage:(NSString *)message icon:(NSString *)icon isWindow:(BOOL)isWindow {
    
    MBProgressHUD *hud = [self createMBProgressHUDviewWithMessage:message isWindow:isWindow];
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}
/**
 *  创建HUD
 *  @param message 信息内容
 *  @param isWindow    是否是window层
 */
+ (MBProgressHUD*)createMBProgressHUDviewWithMessage:(NSString*)message isWindow:(BOOL)isWindow {
    UIView  *view = isWindow? (UIView*)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message ? message: @"";
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.label.numberOfLines = 2;
    hud.removeFromSuperViewOnHide = YES;
    hud.backgroundView.color = [UIColor clearColor];
    return hud;
}

//获取当前屏幕显示的viewcontroller
+(UIViewController *)getCurrentWindowVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal)
            {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else
    {
        result = window.rootViewController;
    }
    return  result;
}

+(UIViewController *)getCurrentUIVC {
    UIViewController  *superVC = [[self class]  getCurrentWindowVC];
    
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
        
    }else if ([superVC isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController*)superVC).viewControllers.lastObject;
    }
    return superVC;
}

@end
