//
//  ALAssetSource.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/1.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALAssetSource.h"

@implementation ALAssetSource

@end


@implementation ALAssetSource (Tool)


+ (void)videoInfoWithAsset: (PHAsset *)asset completion: (void(^)(ALAssetSource *model))completion {
    ALAssetSource *sourceModel = [ALAssetSource new];
    sourceModel.sourceType = ALAssetSourceType_VIDEO;
    sourceModel.duration = asset.duration;
    static PHImageRequestID requestID = -1;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, 500);
    CGSize size = CGSizeZero;
    if (requestID >= 1 && size.width / width == scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }

    PHImageRequestOptions *imgOption = [[PHImageRequestOptions alloc] init];
    imgOption.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    imgOption.resizeMode = PHImageRequestOptionsResizeModeFast;
    imgOption.synchronous = YES;
    
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:imgOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        /** 必须做判断，要不然将走多次完成的completion的block */
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            sourceModel.originalImage = result;
            [self videoDataWithAsset:asset completion:^(NSData *data, NSURL *videoURL) {
                sourceModel.sourceData = data;
                if (completion) {
                    completion(sourceModel);
                }
            }];
        }
    }];
}

+ (void)videoDataWithAsset: (PHAsset *)asset completion: (void(^)(NSData *data, NSURL *videoURL))completion
{
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        NSString *key = info[@"PHImageFileSandboxExtensionTokenKey"];
        NSString *path = [key componentsSeparatedByString:@";"].lastObject;
        NSURL *url = [NSURL fileURLWithPath:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (completion) completion(data,url);
    }];
}


+ (NSString *)createVideoShotImageFileName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    
    NSString *imageName = [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg",destDateString];
    return imageName;
}


+ (NSString *)createVideoFileName {
    NSString *videoType = @".mp4";
    NSString *videoDestDateString = [self createFileNamePrefix];
    NSString *videoFileName = [NSString stringWithFormat:@"%@%@",@"ShotVideo",[videoDestDateString stringByAppendingString:videoType]];
    
    return videoFileName;
}

/**
 *  创建文件名
 */
+ (NSString *)createFileNamePrefix {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    
    return destDateString;
}

+ (BOOL)isGif:(PHAsset *)asset {
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    return [orgFilename containsString:@"GIF"] || [orgFilename containsString:@"gif"];
}

+ (BOOL)isVideo:(PHAsset *)asset {
    return asset.mediaType == PHAssetMediaTypeVideo;
}

@end
