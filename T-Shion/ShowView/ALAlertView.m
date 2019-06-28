//
//  ALAlertView.m
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ALAlertView.h"

@interface ALAlertView()
@property (strong, nonatomic) UILabel *titleLabel;
//@property (strong, nonatomic) UIButton *cancel;
//@property (strong, nonatomic) UIButton *sure;
@property (strong, nonatomic) UIViewController *controller;
@end

@implementation ALAlertView
+ (void)initWithTitle:(NSString *)title sureTitle:(NSString *)sureTitle controller:(UIViewController*)controller sureBlock:(void(^)(void))sureBlock {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:sureTitle preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sureBlock();
    }];
    [alert addAction:cancel];
    [alert addAction:sure];
    [controller presentViewController:alert animated:YES completion:nil];
}

+ (void)initWithTitle:(NSString *)title array:(NSArray *)array controller:(UIViewController *)controller sureBlock:(void (^)(int index))sureBlock {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
   
    [alert addAction:cancel];
    for (int i= 0; i<array.count; i++) {
        NSString *title = array[i];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sureBlock(i);
        }];
        [alert addAction:sure];

    }
    [controller presentViewController:alert animated:YES completion:nil];
}
@end
