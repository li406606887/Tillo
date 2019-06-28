//
//  TSImageHandler.h
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/**
 *   访问相册授权状态
 */
typedef NS_ENUM(NSInteger, TSAuthorizationStatus) {
    
    TSAuthorizationStatusNotDetermined = 0,// 未确定授权
    
    TSAuthorizationStatusRestricted,// 限制授权
    
    TSAuthorizationStatusDenied,// 拒绝授权
    
    TSAuthorizationStatusAuthorized,// 已授权
};


@interface TSImageHandler : NSObject

+ (TSAuthorizationStatus)requestAuthorization;

+ (void)requestAuthorization:(void(^)(TSAuthorizationStatus status))handler;

/**
 *  获取所有相册
 */
- (void)enumeratePHAssetCollectionsWithResultHandler:(void(^)(NSArray <PHAssetCollection *>*result))resultHandler;

/**
 *  获取某相册下的资源
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)collection finishBlock:(void(^)(NSArray <PHAsset *>*result))finishBlock;

+ (UIImage *)fixOrientation:(UIImage *)tempImage;




/**
 把图片保存到项目创建的相册下,add by chw for save photo 2019.02.26

 @param image UIImage或者NSString，由于gif图片不能直接使用UIImage进行保存，所以参数会有两种，普通普遍两种方式都可以
 @return 保存后的路径
 */
+ (NSString*)saveImageToAlbum:(id)image;

///判断相片是否还在
+ (BOOL)phAssetsIsExist:(NSString*)assetsIdentifiers;

+ (void)saveVideoToSystemAlbum:(NSString *)videoPath showTip:(BOOL)showTip;

@end
