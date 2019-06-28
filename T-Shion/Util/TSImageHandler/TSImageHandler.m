//
//  TSImageHandler.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSImageHandler.h"
#import "PHAssetCollection+TS.h"

//static CGFloat const kDefaultThumbnailWidth = 100;

@interface TSImageHandler ()

@property (nonatomic, weak) PHPhotoLibrary *photoLibrary;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@end

@implementation TSImageHandler

+ (TSAuthorizationStatus)requestAuthorization {
    return (TSAuthorizationStatus)[PHPhotoLibrary authorizationStatus];
}

+ (void)requestAuthorization:(void (^)(TSAuthorizationStatus))handler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
        handler((TSAuthorizationStatus)[PHPhotoLibrary authorizationStatus]);
        });
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        self.concurrentQueue = dispatch_queue_create("com.TSImageHandler.global", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

//获取所有相册: PHAssetCollection
- (void)enumeratePHAssetCollectionsWithResultHandler:(void (^)(NSArray<PHAssetCollection *> *))resultHandler {
    NSMutableArray *groups = [NSMutableArray array];
    
    dispatch_sync(self.concurrentQueue, ^{
        //系统
        PHFetchResult <PHAssetCollection *>*systemAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        //自定义相册
        
        PHFetchResult <PHAssetCollection *>*userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];

        for (PHAssetCollection *collection in systemAlbums) {
            // 过滤照片数量为0的相册
            if ([collection numberOfAssets] == 0) {
                continue;
            }
            
            if ([collection.localizedTitle isEqualToString:@"Camera Roll"] || [collection.localizedTitle isEqualToString:@"相机胶卷"] ||
                [collection.localizedTitle isEqualToString:@"所有照片"] ||
                [collection.localizedTitle isEqualToString:@"All Photos"])
            {
                [groups insertObject:collection atIndex:0];
            }
            else
            {
                [groups addObject:collection];
            }
        }
        
        
        for (PHAssetCollection *collection in userAlbums) {
            if ([collection numberOfAssets] == 0) {
                continue;
            }
            [groups addObject:collection];
        }
    });
    
    dispatch_sync(self.concurrentQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            resultHandler(groups);
        });
    });
}

/**
 *  获取某相册下的资源
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)collection finishBlock:(void(^)(NSArray <PHAsset *>*result))finishBlock {
    __block NSMutableArray <PHAsset *>*results = [NSMutableArray array];
    
    dispatch_async(self.concurrentQueue, ^{
        // 获取collection这个相册中的所有资源
        PHFetchResult <PHAsset *>*assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.mediaType == PHAssetMediaTypeImage || obj.mediaType == PHAssetMediaTypeVideo) {
                [results addObject:obj];
            }
//            if (obj.mediaType == PHAssetMediaTypeImage) {
//                [results addObject:obj];
//            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            finishBlock(results);
        });
    });
}

+ (UIImage *)fixOrientation:(UIImage *)tempImage {
    
    if (tempImage.imageOrientation == UIImageOrientationUp) return tempImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (tempImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, tempImage.size.width, tempImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, tempImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, tempImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (tempImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, tempImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, tempImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, tempImage.size.width, tempImage.size.height,
                                             CGImageGetBitsPerComponent(tempImage.CGImage), 0,
                                             CGImageGetColorSpace(tempImage.CGImage),
                                             CGImageGetBitmapInfo(tempImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (tempImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,tempImage.size.height,tempImage.size.width), tempImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,tempImage.size.width,tempImage.size.height), tempImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
#pragma mark - savePhoto
/********* add by chw for save photo 2019.02.26 *********/
+ (NSString*)saveImageToAlbum:(id)image {
    // 先将image存到相机胶卷
    PHFetchResult<PHAsset *> *assets = [self saveImageToSystemAlbum:image];
    
    // 获得相册Aillo
    PHAssetCollection *ailloCollection = [self getAilloCollection];
    
    if (assets == nil || ailloCollection == nil) {
        NSLog(@"保存失败！");
        return @"";
    }
    
    // 将相片添加到相册Aillo
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:ailloCollection];
        [request insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 返回结果
    if (error) {
        NSLog(@"保存失败！");
        return @"";
    } else {
        if (assets.count>0) {
            PHAsset *asset  = assets[0];
            NSString *fileName = asset.localIdentifier;
            NSLog(@"相册保存成功，路径:%@",fileName);
            return fileName;
        }
        return @"";
    }
}

/*
 *  获得相册Aillo，没有则创建
 */
+ (PHAssetCollection *)getAilloCollection {
    // 获取软件的名字作为相册的标题
    NSString *title = @"Aillo";
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil){
        return nil;
    }
    else {// 创建完毕后再取出相册
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
    }
}

/**
 将图片保存到系统相册<相机胶卷>中

 @param image UIImage或NSString
 @return PHAsset集合
 */
+ (PHFetchResult<PHAsset *> *)saveImageToSystemAlbum:(id)image
{
    __block NSString *createdAssetId = nil;
    
    // 添加图片到<相机胶卷>
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        if ([image isKindOfClass:[UIImage class]])
            createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        else if ([image isKindOfClass:[NSString class]])
            createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:image]].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

///判断相片是否还在
+ (BOOL)phAssetsIsExist:(NSString*)assetsIdentifiers
{
    PHFetchResult<PHAsset *> * assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetsIdentifiers] options:nil];
    return (assets.count>0 ? YES : NO);
}

/********* end add by chw *********/

+ (void)saveVideoToSystemAlbum:(NSString *)videoPath showTip:(BOOL)showTip {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    
    // 要保存到系统相册中视频的标识
    __block NSString *localIdentifier;
    
    // 获取相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    // 对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        // _albumName是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:@"Aillo"])  {
            *stop = YES;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //请求创建一个Asset
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加视频
//                [collectonRequest addAssets:@[placeHolder]];
                
                [collectonRequest insertAssets:@[placeHolder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
                localIdentifier = placeHolder.localIdentifier;
            } completionHandler:^(BOOL success, NSError *error) {
                if (!showTip) return;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (success) {
                        ShowWinMessage(Localized(@"imageBrowser_save_success"));
                    } else {
                        ShowWinMessage(Localized(@"imageBrowser_save_fail"));
                        NSLog(@"保存视频失败:%@", error);
                    }
                });
                
            }];
        }
    }];
}

@end

