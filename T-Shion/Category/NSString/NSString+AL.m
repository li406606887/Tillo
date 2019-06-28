//
//  NSString+AL.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NSString+AL.h"

@implementation NSString (AL)

+ (CGSize )getStringSizeWithString:(NSString *)string maxSize:(CGSize )maxSize attributes:(NSDictionary *)dic {
    CGRect rect = [string boundingRectWithSize:maxSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:dic
                                       context:nil];
    return  CGSizeMake(rect.size.width,rect.size.height);
}

+ (NSString *)replaceEnglishAssetCollectionNamme:(NSString *)englishName {
    if([englishName isEqualToString:@"My Photo Stream"]) {
        return @"我的照片流";
    }
    if([englishName isEqualToString:@"Selfies"]) {
        return @"自拍";
    }
    if([englishName isEqualToString:@"Bursts"]) {
        return @"连拍";
    }
    if([englishName isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    }
    if([englishName isEqualToString:@"Favorites"]) {
        return @"喜欢";
    }
    if([englishName isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    }
    if([englishName isEqualToString:@"Videos"]) {
        return @"视频";
    }
    if([englishName isEqualToString:@"Panoramas"]) {
        return @"全景";
    }
    if([englishName isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    if([englishName isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    }
    return englishName;
}

+ (NSString *)convertStringToHexStr:(NSData *)myD {
    Byte *bytes = (Byte *)[myD bytes];//下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)getStringFirstLetterWithString:(NSString *)string {
    if (string == nil || string.length<1) {
        return @"*";
    }
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef) str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *letter = [[str capitalizedString] substringToIndex:1];
    return letter;
}

+ (NSString*)removeLastOneChar:(NSString*)origin {
    NSString* cutted;
    if([origin length] > 0){
        cutted = [origin substringToIndex:(0)];// 去掉最后一个","
    }else{
        cutted = origin;
    }
    return cutted;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)arrayToJSONString:(NSArray *)array {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSArray *)arrayWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingMutableContainers
                                                       error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return array;
}



@end
