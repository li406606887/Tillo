//
//  DownSettingManager.h
//  AilloTest
//
//  Created by mac on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMDownSettingManager : NSObject

+ (instancetype)defaultManager;


//自动下载设置项，0是不自动下载，1是WiFi下自动下载，2是所有网络下都自动下载
@property (nonatomic, assign) NSInteger autoDownloadPhoto;  //图片自动下载
@property (nonatomic, assign) NSInteger autoDownloadVideo;  //视频自动下载
@property (nonatomic, assign) NSInteger autoDownloadFile;   //文件自动下载

@property (nonatomic, assign) BOOL autoSavePhoto;   //是否自动保存图片
@property (nonatomic, assign) BOOL autoSaveVideo;   //是否自动保存视频

+ (BOOL)photoAutoDownload;
+ (BOOL)videoAutoDownload;
+ (BOOL)fileAutoDownload;

@end

NS_ASSUME_NONNULL_END
