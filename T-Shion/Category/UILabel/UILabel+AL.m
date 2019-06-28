//
//  UILabel+AL.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "UILabel+AL.h"

@implementation UILabel (AL)

//
//+ (CGFloat)setLimiteNumTo:(int)num
//                 forLabel:(UILabel *)label
//         forMaxTitleWidth:(CGFloat)widthMax {
//    CGSize size = [@"字体" sizeWithFont:label.font
//                    constrainedToSize:CGSizeMake(widthMax, CGFLOAT_MAX)
//                        lineBreakMode:label.lineBreakMode];
//    CGFloat oneHeight = size.height;
//
//    CGSize textSize = [label.text sizeWithFont:label.font
//                             constrainedToSize:CGSizeMake(widthMax, CGFLOAT_MAX)
//                                 lineBreakMode:label.lineBreakMode];
//
//    int finilyNum = (int) ceilf(textSize.height / oneHeight);
//    if (finilyNum >= num) {
//        finilyNum = num;
//    }
//    label.numberOfLines = finilyNum;
//    label.textAlignment = NSTextAlignmentLeft;
//    widthMax = widthMax>textSize.width?textSize.width:widthMax;
//
//    label.frame = CGRectMake(label.x, label.y, widthMax, oneHeight * finilyNum);
//
//    return oneHeight;
//}

/*
 * 创建基本Label，并且是居中
 */
+ (UILabel *)constructLabel:(CGRect)frame
                       text:(NSString *)text
                       font:(UIFont *)font
                  textColor:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    if (font) {
        label.font = font;
    }
    if (color) {
        label.textColor = color;
    }
    if (text) {
        label.text = text;
    }
    label.userInteractionEnabled = NO;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    //    [label sizeToFit];
    return label;
}

/*
 * 创建Label，大小自适应
 */
+ (UILabel *)constructLabelSizeToFitWithText:(NSString *)text
                                        font:(UIFont *)font
                                   textColor:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    if (font) {
        label.font = font;
    }
    if (color) {
        label.textColor = color;
    }
    
    if (text) {
        label.text = text;
    }
    [label sizeToFit];
    label.frame = CGRectMake(0, 0, label.width, label.height);
    
    return label;
}

@end
