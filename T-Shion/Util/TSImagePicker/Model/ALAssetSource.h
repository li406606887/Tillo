//
//  ALAssetSource.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/1.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    ALAssetSourceType_IMG = 1,
    ALAssetSourceType_GIF = 2,
    ALAssetSourceType_VIDEO = 3
} ALAssetSourceType;


@interface ALAssetSource : NSObject

@property (nonatomic, strong) NSData *sourceData;//gif/视频 数据源

@property (nonatomic, strong) UIImage *originalImage;//原图

@property (nonatomic, assign) ALAssetSourceType sourceType;//是否是gif

@property (nonatomic, assign) int duration;//视频有时长
@end


@interface ALAssetSource (Tool)

+ (BOOL)isGif:(PHAsset *)asset;

+ (BOOL)isVideo:(PHAsset *)asset;

+ (void)videoInfoWithAsset: (PHAsset *)asset completion: (void(^)(ALAssetSource *model))completion;

+ (NSString *)createVideoShotImageFileName;

+ (NSString *)createVideoFileName;


@end
