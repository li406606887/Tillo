//
//  ALAlertView.h
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALAlertView : NSObject

+ (void)initWithTitle:(NSString *)title sureTitle:(NSString *)sureTitle controller:(UIViewController*)controller sureBlock:(void(^)(void))sureBlock;

+ (void)initWithTitle:(NSString *)title array:(NSArray*)array controller:(UIViewController*)controller sureBlock:(void(^)(int index))sureBlock;
@end
