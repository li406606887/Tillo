//
//  FMDBManager+UserInfo.h
//  T-Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"

@class UserInfoModel;

@interface FMDBManager (UserInfo)
/*
 * 更新数据 UserInfoModel
 */
+ (BOOL)updateUserInfo:(UserInfoModel *)model;

/*
 * 更新数据 UserInfoModel
 */
+ (UserInfoModel*)selectUserModel;

+ (void)setNotifySeting;

/**
 设置通知开关

 @param state yes 开 no 关
 */
+ (void)setNotifyWithReceiveSwitch:(BOOL)state;
/**
 查询通知开关

 @return state yes 开 no 关
 */
+ (BOOL)selectedNotifyWithReceiveSwitch;
/**
 设置通知详情开关
 
 @param state yes 开 no 关
 */
+ (void)setNotifyWithReceiveDetailsSwitch:(BOOL)state;
/**
 查询通知详情开关
 
 @return state yes 开 no 关
 */
+ (BOOL)selectedNotifyWithReceiveDetailsSwitch;
/**
 设置RTC通知开关
 
 @param state yes 开 no 关
 */
+ (void)setNotifyWithRTCSwitch:(BOOL)state;
/**
 查询RTC通知开关
 
 @return state yes 开 no 关
 */
+ (BOOL)selectedNotifyWithRTCSwitch;
/**
 设置声音通知开关
 
 @param state yes 开 no 关
 */
+ (void)setVoiceNotifySwitch:(BOOL)state;
/**
 查询声音通知开关
 
 @return state yes 开 no 关
 */
+ (BOOL)selectedVoiceNotifySwitch;
/**
 设置震动通知开关
 
 @param state yes 开 no 关
 */
+ (void)setShockNotifySwitch:(BOOL)state;
/**
 查询震动通知开关
 
 @return state yes 开 no 关
 */
+ (BOOL)selectedShockNotifySwitch;
@end
