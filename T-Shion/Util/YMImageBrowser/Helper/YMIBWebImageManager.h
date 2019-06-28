//
//  YMIBWebImageManager.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 A mediator between the 'YMImageBrowser' and 'SDWebImage'.
 */

NS_ASSUME_NONNULL_BEGIN

typedef void(^YMIBWebImageManagerProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

typedef void(^YMIBWebImageManagerSuccessBlock)(UIImage * _Nullable image, NSData * _Nullable data, BOOL finished);

typedef void(^YMIBWebImageManagerFailedBlock)(NSError * _Nullable error, BOOL finished);

typedef void(^YMIBWebImageManagerCacheQueryCompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data);


@interface YMIBWebImageManager : NSObject

+ (id)downloadImageWithURL:(NSURL *)url
                  progress:(YMIBWebImageManagerProgressBlock)progress
                   success:(YMIBWebImageManagerSuccessBlock)success
                    failed:(YMIBWebImageManagerFailedBlock)failed;

+ (void)cancelTaskWithDownloadToken:(id)token;

+ (void)storeImage:(nullable UIImage *)image imageData:(nullable NSData *)data forKey:(NSURL *)key toDisk:(BOOL)toDisk;

+ (void)queryCacheOperationForKey:(NSURL *)key completed:(YMIBWebImageManagerCacheQueryCompletedBlock)completed;

@end

NS_ASSUME_NONNULL_END
