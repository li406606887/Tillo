//
//  YMImage.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYFrameImage.h>
#import <YYImage/YYSpriteSheetImage.h>
#import <YYImage/YYImageCoder.h>
#import <YYImage/YYAnimatedImageView.h>
#elif __has_include(<YYWebImage/YYImage.h>)
#import <YYWebImage/YYFrameImage.h>
#import <YYWebImage/YYSpriteSheetImage.h>
#import <YYWebImage/YYImageCoder.h>
#import <YYWebImage/YYAnimatedImageView.h>
#else
#import "YYFrameImage.h"
#import "YYSpriteSheetImage.h"
#import "YYImageCoder.h"
#import "YYAnimatedImageView.h"
#endif


NS_ASSUME_NONNULL_BEGIN

/**
 它是一个完全兼容的“UIImage”子类。它扩展了UIImage
 支持动画WebP, APNG和GIF格式的图像数据解码。它还
 支持NSCoding协议来存档和解压多帧图像数据。
 
 如果图像是由多帧图像数据创建的，则要播放
 动画，尝试用YYAnimatedImageView替换UIImageView。
 
 注意:“YMImage”是从“YYImage”复制过来的，只是添加了一个是否解压的逻辑。
 */

@interface YMImage : UIImage <YYAnimatedImage>

+ (nullable YMImage *)imageNamed:(NSString *)name; // no cache!
+ (nullable YMImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable YMImage *)imageWithData:(NSData *)data;
+ (nullable YMImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

/**
 If the image is created from data or file, then the value indicates the data type.
 */
@property (nonatomic, readonly) YYImageType animatedImageType;

/**
 如果图像是由动画图像数据(多帧GIF/APNG/WebP)创建的，
 此属性存储原始图像数据.
 */
@property (nullable, nonatomic, readonly) NSData *animatedImageData;

/**
 如果所有帧图像都加载到内存中，那么总的内存使用量(以字节为单位)。
 如果没有从多帧图像数据创建图像，则该值为0。
 */
@property (nonatomic, readonly) NSUInteger animatedImageMemorySize;

/**
 预加载所有帧图像到内存。
 
 @discussion将此属性设置为“YES”将阻塞要解码的调用线程
 所有动画帧图像到内存中，设置为“NO”将释放预加载帧。
 如果图像被许多图像视图(如emoticon)共享，则预加载所有视图
 帧将降低CPU成本。
 
 内存成本见“animatedImageMemorySize”。
 */
@property (nonatomic) BOOL preloadAllAnimatedImageFrames;


@end

NS_ASSUME_NONNULL_END
