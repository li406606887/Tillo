//
//  UIImage+AL.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (AL)

//切圆角
- (UIImage *)circleImage;

/**
 *  用color生成image
 *
 *  @param color 颜色
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
/**
 *  改变image透明度
 *
 *  @param alpha 透明度
 */
- (UIImage *)imageWithAlpha:(CGFloat)alpha;

//旋转角度
//- (UIImage *)rotation:(UIImageOrientation)orientation;

- (UIImage *)al_fixOrientation;

- (UIImage *)al_fixOrientation:(UIImageOrientation)imageOrientation;

- (UIImage *)al_scaleToHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
