//
//  UIColor+AL.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_COLOR RGB(246,246,246)
// 十六进制颜色设置
#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define HEXACOLOR(hexValue, alphaValue) [UIColor colorWithRed : ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 green : ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 blue : ((CGFloat)(hexValue & 0xFF)) / 255.0 alpha : (alphaValue)]

//RGBA颜色设置
#define RGBACOLOR(r,g,b,a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define RGB(r, g, b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface UIColor (AL)

/**
 app主色值
 
 @return UIColor
 */
+ (UIColor *)ALKeyColor;

/**
 文字深黑色
 
 @return UIColor
 */
+ (UIColor *)ALTextDarkColor;

/**
 文字正常黑
 
 @return UIColor
 */
+ (UIColor *)ALTextNormalColor;

/**
 文字浅黑
 
 @return UIColor
 */
+ (UIColor *)ALTextLightColor;

/**
 文字灰色
 
 @return UIColor
 */
+ (UIColor *)ALTextGrayColor;


/**
 按钮正常色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnNormalColor;

/**
 按钮高亮色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnHightLightColor;

/**
 按钮不可用色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnDisableColor;

/**
 按钮选中色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnSelectedColor;

/**
 按钮灰色色值
 
 @return UIColor
 */
+ (UIColor *)ALBtnGrayColor;


/**
 文字placeholder颜色
 
 @return UIColor
 */
+ (UIColor *)ALPlaceholderColor;

/**
 分割线颜色
 
 @return UIColor
 */
+ (UIColor *)ALLineColor;

/**
 主要灰色背景色
 
 @return UIColor
 */
+ (UIColor *)ALKeyBgColor;

/**
 浅灰色背景色
 
 @return UIColor
 */
+ (UIColor *)ALGrayBgColor;

/**
 蓝颜色
 
 @return UIColor
 */
+ (UIColor *)ALBlueColor;

/**
 红色
 
 @return UIColor
 */
+ (UIColor *)ALRedColor;


//add by chw 2019.04.18 for Encryption
/**
 加密聊天的昵称颜色
 
 @return UIColor
 */
+ (UIColor *)ALLockColor;

@end

