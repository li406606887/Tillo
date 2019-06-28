//
//  NSString+AL.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AL)

/**
 * 获取内容size
 */
+ (CGSize )getStringSizeWithString:(NSString *)string
                           maxSize:(CGSize )maxSize
                        attributes:(NSDictionary *)dic;

/**
 * 获取相册名字进行中文转化
 */
+ (NSString *)replaceEnglishAssetCollectionNamme:(NSString *)englishName;

/**
 * 字符串转16进制
 */
+ (NSString *)convertStringToHexStr:(NSString *)str;

/**
 * 获取首大写字母
 */
+ (NSString *)getStringFirstLetterWithString:(NSString *)string;

/**
 * 移除字符串第一个元素
 */
+ (NSString*)removeLastOneChar:(NSString*)origin;

/**
 * dictionary 转 json
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

/**
 * array 转 json
 */
+ (NSString *)arrayToJSONString:(NSArray *)array;

/**
 * json 转 dictionary
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSArray *)arrayWithJsonString:(NSString *)jsonString ;

@end

NS_ASSUME_NONNULL_END
