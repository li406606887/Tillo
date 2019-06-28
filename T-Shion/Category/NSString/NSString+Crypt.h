//
//  NSString+Crypt.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/5/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Crypt)

/**
 AES加密方法
 @param content 需要加密的字符串
 @return 加密后的字符串
 */
+ (NSString *)ym_encryptAES:(NSString *)content;

/**
 AES解密方法
 @param content 需要解密的字符串
 @return 解密后的字符串
 */
+ (NSString *)ym_decryptAES:(NSString *)content;

@end

