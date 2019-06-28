//
//  UIViewController+ALSlideMenu.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "UIViewController+ALSlideMenu.h"
#import "ALSlideMenu.h"
@implementation UIViewController (ALSlideMenu)

- (ALSlideMenu *)al_sldeMenu {
    UIViewController *sldeMenu = self.parentViewController;
    while (sldeMenu) {
        if ([sldeMenu isKindOfClass:[ALSlideMenu class]]) {
            return (ALSlideMenu *)sldeMenu;
        } else if (sldeMenu.parentViewController && sldeMenu.parentViewController != sldeMenu) {
            sldeMenu = sldeMenu.parentViewController;
        } else {
            sldeMenu = nil;
        }
    }
    return nil;
}

@end
