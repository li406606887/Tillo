//
//  ALDialCodeManager.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALDialCodeModel.h"

@interface ALDialCodeManager : NSObject

+ (instancetype)sharedInstance;

- (void)al_dialCodeSectionWithEnglish:(BOOL)isEnglish complection:(void (^)(NSArray<ALDialCodeSectionModel *> *, NSArray<NSString *> *, NSArray<ALDialCodeModel *> *))completcion;

- (NSString *)al_selectDialCodeWithCountryCode:(NSString *)countryCode;

@end

