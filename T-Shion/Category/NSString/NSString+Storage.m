//
//  NSString+Storage.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/5/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NSString+Storage.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Storage)

+ (NSString *)ym_imageUrlStringWithSourceId:(NSString *)sourceId {
    NSString *signStr = [NSString stringWithFormat:@"%@%@%@",kTCloudAppId,sourceId,kTCloudMD5KEY];
    NSString *signMD5Str = [NSString ym_encryptByMD5:signStr];
    
    NSString *imageUrlString = [NSString stringWithFormat:@"%@/getCustomImage",NewCloudHostUrl];
    
    imageUrlString = [imageUrlString stringByAppendingString:[NSString stringWithFormat:@"?userId=%@",kTCloudAppId]];
    
    imageUrlString = [imageUrlString stringByAppendingString:[NSString stringWithFormat:@"&userFileId=%@",sourceId]];
    
    imageUrlString = [imageUrlString stringByAppendingString:[NSString stringWithFormat:@"&sign=%@",signMD5Str]];
    
    return imageUrlString;
}

+ (NSString *)ym_encryptByMD5:(NSString *)content {
    const char *cStr = [content UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

+ (NSString *)ym_thumbAvatarUrlStringWithSourceId:(NSString *)sourceId {
    NSString *originalStr = [NSString ym_imageUrlStringWithSourceId:sourceId];
    NSString *avatarStr = [NSString stringWithFormat:@"%@&width=150&height=150",originalStr];
    return avatarStr;
}

+ (NSString *)ym_thumbAvatarUrlStringWithOriginalString:(NSString *)originalString {
    if ([originalString hasPrefix:@"https://file.aillo.cc"]) {
        return originalString;
    }
    
    NSString *avatarStr = [NSString stringWithFormat:@"%@&width=150&height=150",originalString];
    return avatarStr;
}

+ (NSString *)ym_thumbImgUrlStringWithMessage:(MessageModel *)message {
    NSString *originalStr = [NSString ym_imageUrlStringWithSourceId:message.sourceId];
    NSString *thumbStr = [NSString stringWithFormat:@"%@&width=%d&height=%d",originalStr,(int)message.imageSize.width*2,(int)message.imageSize.height*2];
    return thumbStr;
}

+ (NSString *)ym_fileUrlStringWithSourceId:(NSString *)sourceId {
    NSString *signStr = [NSString stringWithFormat:@"%@%@%@",kTCloudAppId,sourceId,kTCloudMD5KEY];
    NSString *signMD5Str = [NSString ym_encryptByMD5:signStr];
    
    NSString *fileUrlString = [NSString stringWithFormat:@"%@/download",NewCloudHostUrl];
    
    fileUrlString = [fileUrlString stringByAppendingString:[NSString stringWithFormat:@"?userId=%@",kTCloudAppId]];
    
    fileUrlString = [fileUrlString stringByAppendingString:[NSString stringWithFormat:@"&userFileId=%@",sourceId]];
    
    fileUrlString = [fileUrlString stringByAppendingString:[NSString stringWithFormat:@"&sign=%@",signMD5Str]];
    return fileUrlString;
}
@end
