//
//  YMIBPhotoAlbumManager.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>


@interface YMIBPhotoAlbumManager : NSObject

/**
 获取相册权限
 */
+ (void)getPhotoAlbumAuthorizationSuccess:(void(^)(void))success failed:(void(^)(void))failed;

/**
 从PHAsset获取AVAsset.
 */
+ (void)getAVAssetWithPHAsset:(PHAsset *)phAsset success:(void(^)(AVAsset *asset))success failed:(void(^)(void))failed;

/**
 从PHAsset获取图片data.
 */
+ (void)getImageDataWithPHAsset:(PHAsset *)phAsset success:(void(^)(NSData *data))success failed:(void(^)(void))failed;

+ (void)saveImageToAlbum:(UIImage *)image;

+ (void)saveDataToAlbum:(NSData *)data;

+ (void)saveVideoToAlbumWithPath:(NSString *)path;


@end

