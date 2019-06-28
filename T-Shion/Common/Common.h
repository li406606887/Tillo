//
//  Common.h
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#ifndef Common_h
#define Common_h

#ifdef DEBUG
#define NSLog(...) NSLog(@"%@", [NSString stringWithFormat:__VA_ARGS__])
#else
#define NSLog(...)
#endif

#define IOS_VERSION   [[[UIDevice currentDevice] systemVersion] floatValue]//版本号

#define IOS_Version_11 IOS_VERSION < 11.0


#define LoadingView(a) [MBProgressHUD loadingViewWithMessage:a];
#define LoadingWin(a) [MBProgressHUD loadingWindowWithMessage:a];
#define ShowViewMessage(a) [MBProgressHUD showViewPromptTitle:a];
#define ShowWinMessage(a) [MBProgressHUD showWindowPromptTitle:a];
#define HiddenHUD  [MBProgressHUD hiddenHUD];

#define Localized(key)  [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"Language"]

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)//屏幕款
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)//屏幕高

#define is_iPhoneX (SCREEN_WIDTH >= 375.0f && SCREEN_HEIGHT >= 812.0f)

#endif /* Common_h */
