//
//  NSFileManager+AL.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NSFileManager+AL.h"
#import "NSFileManager+Paths.h"

@implementation NSFileManager (AL)

+ (NSString *)pathUserChatImage:(NSString*)imageName {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *path = [NSString stringWithFormat:@"%@/User/%@/Chat/Images/", [NSFileManager documentsPath], userID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return [path stringByAppendingString:imageName];
}

+ (NSString *)pathUserChatVoice:(NSString *)voiceName {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *path = [NSString stringWithFormat:@"%@/User/%@/Chat/Voices/", [NSFileManager documentsPath], userID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return [path stringByAppendingString:voiceName];
}


+ (NSString *)pathDBCommon {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *path = [NSString stringWithFormat:@"%@/User/%@/Setting/DB/", [NSFileManager documentsPath], userID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return [path stringByAppendingString:@"common.sqlite3"];
}

+ (NSString *)pathDBMessage {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *path = [NSString stringWithFormat:@"%@/User/%@/Chat/DB/", [NSFileManager documentsPath], userID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return [path stringByAppendingString:@"message.sqlite3"];
}

+ (NSString *)cacheForFile:(NSString *)filename {
    return [[NSFileManager cachesPath] stringByAppendingString:filename];
}

@end
