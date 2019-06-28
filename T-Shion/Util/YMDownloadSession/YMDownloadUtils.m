//
//  YMDownloadUtils.m
//  YMDownloadSessionDemo
//
//  Created by 与梦信息的Mac on 2019/4/30.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMDownloadUtils.h"
#import <CommonCrypto/CommonDigest.h>

#define kCommonUtilsGigabyte (1024 * 1024 * 1024)
#define kCommonUtilsMegabyte (1024 * 1024)
#define kCommonUtilsKilobyte 1024


@implementation YMDownloadUtils

+ (int64_t)ym_fileSystemFreeSize {
    int64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes longLongValue];
    }
    return totalFreeSpace;
}

+ (NSString *)ym_fileSizeStringFromBytes:(int64_t)byteSize {
    if (kCommonUtilsGigabyte <= byteSize) {
        return [NSString stringWithFormat:@"%@GB", [self ym_numberStringFromDouble:(double)byteSize / kCommonUtilsGigabyte]];
    }
    if (kCommonUtilsMegabyte <= byteSize) {
        return [NSString stringWithFormat:@"%@MB", [self ym_numberStringFromDouble:(double)byteSize / kCommonUtilsMegabyte]];
    }
    if (kCommonUtilsKilobyte <= byteSize) {
        return [NSString stringWithFormat:@"%@KB", [self ym_numberStringFromDouble:(double)byteSize / kCommonUtilsKilobyte]];
    }
    return [NSString stringWithFormat:@"%luB", (unsigned long)byteSize];
}

+ (NSString *)ym_numberStringFromDouble:(const double)num {
    NSInteger section = round((num - (NSInteger)num) * 100);
    if (section % 10) {
        return [NSString stringWithFormat:@"%.2f", num];
    }
    if (section > 0) {
        return [NSString stringWithFormat:@"%.1f", num];
    }
    return [NSString stringWithFormat:@"%.0f", num];
}

+ (NSString *)ym_md5ForString:(NSString *)string {
    const char *str = [string UTF8String];
    if (str == NULL) str = "";
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5Result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return md5Result;
}

+ (void)ym_createPathIfNotExist:(NSString *)path {
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil];
    }
}

+ (int64_t)ym_fileSizeWithPath:(NSString *)path {
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) return 0;
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return dic ? (int64_t)[dic fileSize] : 0;
}

+ (NSString *)ym_urlStrWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    return downloadTask.originalRequest.URL.absoluteString ? : downloadTask.currentRequest.URL.absoluteString;
}

+ (NSUInteger)sec_timestamp {
    return (NSUInteger)[[NSDate date] timeIntervalSince1970];
}


@end
