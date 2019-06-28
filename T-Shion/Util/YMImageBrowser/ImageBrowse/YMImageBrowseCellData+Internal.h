//
//  YMImageBrowseCellData+Internal.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowseCellData.h"

typedef NS_ENUM(NSInteger, YMImageBrowseCellDataState) {
    YMImageBrowseCellDataStateInvalid,
    YMImageBrowseCellDataStateImageReady,
    YMImageBrowseCellDataStateCompressImageReady,
    
    YMImageBrowseCellDataStateThumbImageReady,
    
    YMImageBrowseCellDataStateIsDecoding,
    YMImageBrowseCellDataStateDecodeComplete,
    
    YMImageBrowseCellDataStateIsCompressingImage,
    YMImageBrowseCellDataStateCompressImageComplete,
    
    YMImageBrowseCellDataStateIsLoadingPHAsset,
    YMImageBrowseCellDataStateLoadPHAssetSuccess,
    YMImageBrowseCellDataStateLoadPHAssetFailed,
    
    YMImageBrowseCellDataStateIsQueryingCache,
    YMImageBrowseCellDataStateQueryCacheComplete,
    
    YMImageBrowseCellDataStateIsDownloading,
    YMImageBrowseCellDataStateDownloadProcess,
    YMImageBrowseCellDataStateDownloadSuccess,
    YMImageBrowseCellDataStateDownloadFailed,
};


@interface YMImageBrowseCellData ()

@property (nonatomic, assign) YMImageBrowseCellDataState dataState;

@property (nonatomic, strong) UIImage *compressImage;
@property (nonatomic, assign) CGFloat downloadProgress;
@property (nonatomic, assign) BOOL    cutting;
@property (nonatomic, assign) CGFloat zoomScale;

- (void)loadData;

- (void)cuttingImageToRect:(CGRect)rect complete:(void(^)(UIImage *image))complete;

//是否需要压缩
- (BOOL)needCompress;

- (YMImageBrowseFillType)getFillTypeWithLayoutDirection:(YMImageBrowserLayoutDirection)layoutDirection;

+ (CGFloat)getMaximumZoomScaleWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(YMImageBrowseFillType)fillType;

+ (CGRect)getImageViewFrameWithContainerSize:(CGSize)containerSize imageSize:(CGSize)imageSize fillType:(YMImageBrowseFillType)fillType;

+ (CGSize)getContentSizeWithContainerSize:(CGSize)containerSize imageViewFrame:(CGRect)imageViewFrame;


@end

