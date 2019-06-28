//
//  NSFileManager+Paths.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Paths)

+ (NSURL *)documentsURL;
+ (NSString *)documentsPath;

+ (NSURL *)libraryURL;
+ (NSString *)libraryPath;

+ (NSURL *)cachesURL;
+ (NSString *)cachesPath;

+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path;
+ (double)availableDiskSpace;

@end

