//
//  MBProgressHUD+Category.h
//  T-Shion
//
//  Created by together on 2018/4/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (Category)
+ (void)showWindowPromptTitle:(NSString *)title;

+ (void)showViewPromptTitle:(NSString *)title;

+ (void)showSuccess:(NSString *)Success;

+ (void)showWindowSuccess:(NSString *)success;

+ (void)showError:(NSString *)error;

+ (void)showWindowError:(NSString *)error;

+ (void)loadingWindowWithMessage:(NSString *)message;

+ (void)loadingViewWithMessage:(NSString *)message;

+ (void)hiddenHUD;

+(UIViewController *)getCurrentUIVC ;

+(UIViewController *)getCurrentWindowVC;
@end
