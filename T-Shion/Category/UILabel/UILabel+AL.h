//
//  UILabel+AL.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (AL)

//+ (CGFloat)setLimiteNumTo:(int)num
//                 forLabel:(UILabel *)label
//         forMaxTitleWidth:(CGFloat)widthMax;
/*
 * 创建基本Label，并且是居中
 */
+ (UILabel *)constructLabel:(CGRect)frame
                       text:(NSString *)text
                       font:(UIFont *)font
                  textColor:(UIColor *)color;

/*
 * 创建Label，大小自适应
 */
+ (UILabel *)constructLabelSizeToFitWithText:(NSString *)text
                                        font:(UIFont *)font
                                   textColor:(UIColor *)color;


@end
