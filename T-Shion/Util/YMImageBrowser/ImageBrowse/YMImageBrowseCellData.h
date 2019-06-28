//
//  YMImageBrowseCellData.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "YMImageBrowserCellDataProtocol.h"
#import "YMImage.h"
#import "YMIBLayoutDirectionManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YMImageBrowseFillType) {
    YMImageBrowseFillTypeUnknown,
    // 图像的宽度可达屏幕的宽度，高度自动调整.
    YMImageBrowseFillTypeFullWidth,
    // 图像最大化显示，但保证完整性.
    YMImageBrowseFillTypeCompletely
};

typedef __kindof UIImage * _Nullable (^YMIBLocalImageBlock)(void);

@interface YMImageBrowseCellData : NSObject<YMImageBrowserCellDataProtocol>

@property (nonatomic, copy, nullable) YMIBLocalImageBlock imageBlock;

/** 网络图片地址 */
@property (nonatomic, strong, nullable) NSURL *url;

/** 系统相册资源 */
@property (nonatomic, strong, nullable) PHAsset *phAsset;

@property (nonatomic, weak, nullable) id sourceObject;

/** 预览图 */
@property (nonatomic, strong, nullable) UIImage *thumbImage;

/** 预览图地址，如果缓存中没找到，那就是无效的 */
@property (nonatomic, strong, nullable) NSURL *thumbUrl;

/** The final image. */
@property (nonatomic, strong, readonly, nullable) YMImage *image;

/** 图像的最大缩放比例，必须大于或等于1。
 如果没有显式设置，它将通过图像的像素自动计算。 */
@property (nonatomic, assign) CGFloat maxZoomScale;

/** When the zoom scale is automatically calculated, the result multiplied by this surplus as the final scaling. The defalut is 1.5. */
@property (nonatomic, class) CGFloat globalZoomScaleSurplus;

/** 最大纹理大小，默认是'(CGSize){4096, 4096}'。
 当图像超过此纹理大小时，将异步压缩和异步剪切。
 最好在实例化所有变量之前设置此值。
 */
@property (nonatomic, class) CGSize globalMaxTextureSize;

/** 默认是 'YMImageBrowseFillTypeFullWidth'. */
@property (nonatomic, class) YMImageBrowseFillType globalVerticalfillType;

/** 默认是 'YMImageBrowseFillTypeFullWidth'. */
@property (nonatomic, class) YMImageBrowseFillType globalHorizontalfillType;

/** 当该值有效时，当前实例变量将忽略 globalVerticalfillType 设置 */
@property (nonatomic, assign) YMImageBrowseFillType verticalfillType;

/** 当该值有效时，当前实例变量将忽略 globalHorizontalfillType 设置 */
@property (nonatomic, assign) YMImageBrowseFillType horizontalfillType;

/** 是否允许保存到相册， 默认 YES. */
@property (nonatomic, assign) BOOL allowSaveToPhotoAlbum;

/** 扩展信息 */
@property (nonatomic, strong, nullable) id extraData;

/** 是否异步解码，默认YES */
@property (nonatomic, class) BOOL shouldDecodeAsynchronously;

@end

NS_ASSUME_NONNULL_END
