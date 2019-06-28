//
//  UIColor+AL.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "UIColor+AL.h"

@implementation UIColor (AL)

/**
 app主色值
 
 @return UIColor
 */
+ (UIColor *)ALKeyColor {
    return RGB(95, 206, 173);
}

/**
 文字深黑色
 
 @return UIColor
 */
+ (UIColor *)ALTextDarkColor {
    return RGB(0, 0, 0);
}

/**
 文字正常黑
 
 @return UIColor
 */
+ (UIColor *)ALTextNormalColor {
    return RGB(51, 51, 51);
}

/**
 文字浅黑
 
 @return UIColor
 */
+ (UIColor *)ALTextLightColor {
    return RGB(102, 102, 102);
}


/**
 文字灰色
 
 @return UIColor
 */
+ (UIColor *)ALTextGrayColor {
    return RGB(153, 153, 153);
}


/**
 按钮正常色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnNormalColor {
    return RGB(95, 206, 173);
}

/**
 按钮高亮色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnHightLightColor {
    return RGB(157, 226, 205);
}

/**
 按钮不可用色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnDisableColor {
    return RGB(157, 226, 205);
}

/**
 按钮选中色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnSelectedColor {
    return RGB(157, 226, 205);
}

/**
 按钮灰色色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnGrayColor {
    return RGB(187, 187, 187);
}

/**
 文字placeholder颜色
 
 @return UIColor
 */
+ (UIColor *)ALPlaceholderColor {
    return RGB(204, 204, 204);
}

/**
 分割线颜色
 
 @return UIColor
 */
+ (UIColor *)ALLineColor {
    return RGB(221, 221, 221);
}


/**
 主要灰色背景色
 
 @return UIColor
 */
+ (UIColor *)ALKeyBgColor {
    return RGB(248, 248, 248);
}

/**
 浅灰色背景色
 
 @return UIColor
 */
+ (UIColor *)ALGrayBgColor {
    return RGB(241, 243, 245);
}


/**
 蓝色
 
 @return UIColor
 */
+ (UIColor *)ALBlueColor {
    return RGB(81, 143, 255);
}

/**
 红色
 
 @return UIColor
 */
+ (UIColor *)ALRedColor {
    return RGB(209, 83, 70);
}

//add by chw 2019.04.18 for Encryption
/**
 加密聊天的昵称颜色
 
 @return UIColor
 */
+ (UIColor *)ALLockColor {
    return RGB(84, 208, 172);
}

@end
