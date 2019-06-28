//
//  TShionSingleCase.h
//  T-Shion
//
//  Created by together on 2018/3/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionViewModel.h"

@interface TShionSingleCase : NSObject

@property (assign, nonatomic) BOOL newFriend;//是否有新的朋友

//@property (copy, nonatomic) NSString *headPath;//头像地址

@property (copy, nonatomic) NSString *deviceToken;//推送的token


#pragma mark  method
+ (TShionSingleCase *)shared;

+ (NSString *)doucumentPath;//默认资源地址

+ (NSString *)groupHeadPath;//群聊头像地址


#pragma mark - 头像相关
/** 头像原图文件夹路径 */
+ (NSString *)originalAvatarPath;

/** 根据用户id获取头像原图图本地路径 */
+ (NSString *)originalAvatarImgPathWithUserId:(NSString *)userId;

/** 头像缩略图文件夹路径 */
+ (NSString *)thumbAvatarPath;

/** 根据用户id获取头像缩略图本地路径 */
+ (NSString *)thumbAvatarImgPathWithUserId:(NSString *)userId;

/** 自己的头像缩略地址 */
+ (NSString *)myThumbAvatarImgPath;

#pragma mark - 群头像相关
/** 群头像原图文件夹路径 */
+ (NSString *)originalGroupHeadPath;

/** 根据群id获取群头像原图图本地路径 */
+ (NSString *)originalGroupHeadImgPathWithGroupId:(NSString *)groupId;

/** 头像缩略图文件夹路径 */
+ (NSString *)thumbGroupHeadPath;

/** 根据用户id获取头像缩略图本地路径 */
+ (NSString *)thumbGroupHeadImgPathWithGroupId:(NSString *)GroupId;



+ (BOOL)isHeadphone;
/*
 * 获取音频播放类型
 */
+ (void)getAudioPlayWithType;
/*
 * 收到消息播放系统声音
 */
+ (void)playMessageReceivedSystemSound;
/*
 * 收到消息播放声音
 */
+ (void)playMessageReceivedSound;
/*
 * 发送消息播放声音
 */
+ (void)playMessageSentSound;
/*
 * 收到消息震动
 */
+ (void)playMessageReceivedVibration;
/*
 * 加载头像
 */
+ (void)loadingAvatarWithImageView:(UIImageView *)avatarView url:(NSString *)url filePath:(NSString *)filePath;

+ (void)loadingAvatarWithImageView:(UIImageView *)avatarView url:(NSString *)url filePath:(NSString *)filePath placeHolder:(UIImage*)image;


/**
 加载群聊头像

 @param avatarView 视图
 @param url 图片url
 @param filePath 缓存路径
 */
+ (void)loadingGroupAvatarWithImageView:(UIImageView *)avatarView
                                    url:(NSString *)url
                               filePath:(NSString *)filePath;

@end
