//
//  TShionSingleCase.m
//  T-Shion
//
//  Created by together on 2018/3/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TShionSingleCase.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

static TShionSingleCase *singleCase;

@implementation TShionSingleCase
+ (TShionSingleCase *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleCase = [[TShionSingleCase alloc] init];
    });
    return singleCase;
}

+ (NSString *)doucumentPath {
    //wsp修改 切换帐号导致数据库取错问题 2019.3.18
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if (userID) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:userID];
    }
    return nil;
}

//wsp添加,用于群聊头像路径，2019.4.10
+ (NSString *)groupHeadPath {
    NSString *headPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"GroupHead"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:headPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", headPath);
        }
    }
    return headPath;
}
//end

#pragma mark - 头像相关
+ (NSString *)originalAvatarPath {
    NSString *headPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"OriginalAvatar"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:headPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", headPath);
        }
    }
    
    return headPath;
}

+ (NSString *)originalAvatarImgPathWithUserId:(NSString *)userId {
    NSString *originalAvatarImgPath = [[TShionSingleCase originalAvatarPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"OriginalAvatar_%@.jpg",userId]];
    return originalAvatarImgPath;
}

+ (NSString *)thumbAvatarPath {
    NSString *headPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"ThumbAvatar"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:headPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", headPath);
        }
    }

    return headPath;
}

+ (NSString *)thumbAvatarImgPathWithUserId:(NSString *)userId {
    NSString *thumbAvatarImgPath = [[TShionSingleCase thumbAvatarPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThumbAvatar_%@.jpg",userId]];
    return thumbAvatarImgPath;
}

+ (NSString *)myThumbAvatarImgPath {
    NSString *thumbAvatarImgPath = [[TShionSingleCase thumbAvatarPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThumbAvatar_%@.jpg",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
    return thumbAvatarImgPath;
}

#pragma mark - 群头像相关
+ (NSString *)originalGroupHeadPath {
    NSString *headPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"OriginalGroupHead"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:headPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", headPath);
        }
    }
    
    return headPath;
}

+ (NSString *)originalGroupHeadImgPathWithGroupId:(NSString *)groupId {
    NSString *originalAvatarImgPath = [[TShionSingleCase originalGroupHeadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"OriginalGroupHeadPath_%@.jpg",groupId]];
    return originalAvatarImgPath;
}

+ (NSString *)thumbGroupHeadPath {
    NSString *headPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:@"ThumbGroupHead"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:headPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:headPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", headPath);
        }
    }
    
    return headPath;
}

+ (NSString *)thumbGroupHeadImgPathWithGroupId:(NSString *)GroupId {
    NSString *thumbAvatarImgPath = [[TShionSingleCase thumbGroupHeadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"ThumbGroupHead_%@.jpg",GroupId]];
    return thumbAvatarImgPath;
}


+ (BOOL)isHeadphone {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
        AudioServicesPlaySystemSound(sound);
    }
    else {
        NSLog(@"Error: audio file not found at path: %@", path);
    }
}

+ (void)playMessageReceivedSound {
    [self playSoundWithName:@"messageReceived" type:@"aiff"];
}
+ (void)playMessageReceivedSystemSound {
    AudioServicesPlaySystemSound(1007);
}
+ (void)playMessageSentSound {
    [self playSoundWithName:@"messageSent" type:@"aiff"];
}

+ (void)playMessageReceivedVibration {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)loadingAvatarWithImageView:(UIImageView *)avatarView url:(NSString *)url filePath:(NSString *)filePath {
    [self loadingAvatarWithImageView:avatarView url:url filePath:filePath placeHolder:nil];
}

+ (void)loadingAvatarWithImageView:(UIImageView *)avatarView url:(NSString *)url filePath:(NSString *)filePath placeHolder:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block UIImage *avatar;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            avatar = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                avatarView.image = avatar;
            });
        } else {
            avatar = image ? image : [UIImage imageNamed:@"Avatar_Deafult"];
        }
        
        [avatarView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:avatar completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = UIImageJPEGRepresentation(image, 1);//指定新建文件夹路径
                    BOOL result = [data writeToFile:filePath atomically:YES];
                    if (result) {
                        NSLog(@"好友头像成功更新保存到本地");
                    } else {
                        NSLog(@"好友头像更新失败保存到本地");
                    }
                });
               
            }
        }];
    });
}

+ (void)loadingGroupAvatarWithImageView:(UIImageView *)avatarView url:(NSString *)url filePath:(NSString *)filePath {
    [self loadingGroupAvatarWithImageView:avatarView url:url filePath:filePath placeHolder:nil];
}

+ (void)loadingGroupAvatarWithImageView:(UIImageView *)avatarView url:(NSString *)url filePath:(NSString *)filePath placeHolder:(UIImage*)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block UIImage *avatar;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            avatar = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                avatarView.image = avatar;
            });
        } else {
            avatar = image ? image : [UIImage imageNamed:@"Group_Deafult_Avatar"];
        }
        
        [avatarView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:avatar completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error == nil) {
                NSData *data = UIImageJPEGRepresentation(image, 1);//指定新建文件夹路径
                BOOL result = [data writeToFile:filePath atomically:YES];
                if (!result) {
                    NSLog(@"好友头像保存失败");
                }
            }
        }];
    });
}

@end
