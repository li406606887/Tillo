//
//  ALDialCodeModel.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/10.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALDialCodeModel.h"

@implementation ALDialCodeModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"cn_name" : @"name",
             @"en_name" : @"en",
             @"countryCode" : @"shortName",
             @"dialCode" : @"tel"
             };
}


@end

@implementation ALDialCodeSectionModel



@end
