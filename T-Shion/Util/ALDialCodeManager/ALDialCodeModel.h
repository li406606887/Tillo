//
//  ALDialCodeModel.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/10.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALDialCodeModel : NSObject

@property (nonatomic, copy) NSString *cn_name;//中文名
@property (nonatomic, copy) NSString *en_name;//英文名
@property (nonatomic, copy) NSString *countryCode;//国家代码
@property (nonatomic, copy) NSString *dialCode;//区号

@end

@interface ALDialCodeSectionModel : NSObject

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSArray <ALDialCodeModel *> *dialArray;

@end


