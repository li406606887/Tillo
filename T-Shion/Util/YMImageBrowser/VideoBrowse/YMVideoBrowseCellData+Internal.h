//
//  YMVideoBrowseCellData+Internal.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/21.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMVideoBrowseCellData.h"

typedef NS_ENUM(NSInteger, YMVideoBrowseCellDataState) {
    YMVideoBrowseCellDataStateInvalid,
    YMVideoBrowseCellDataStateFirstFrameReady,
    
    YMVideoBrowseCellDataStateIsLoadingFirstFrame,
    YMVideoBrowseCellDataStateLoadFirstFrameSuccess,
    YMVideoBrowseCellDataStateLoadFirstFrameFailed,
    
    YMVideoBrowseCellDataStateIsLoadingPHAsset,
    YMVideoBrowseCellDataStateLoadPHAssetSuccess,
    YMVideoBrowseCellDataStateLoadPHAssetFailed
};

typedef NS_ENUM(NSInteger, YMVideoBrowseCellDataDownloadState) {
    YMVideoBrowseCellDataDownloadStateNone,
    YMVideoBrowseCellDataDownloadStateIsDownloading,
    YMVideoBrowseCellDataDownloadStateFailed,
    YMVideoBrowseCellDataDownloadStateComplete
};


@interface YMVideoBrowseCellData ()

@property (nonatomic, assign) YMVideoBrowseCellDataState dataState;

@property (nonatomic, assign) YMVideoBrowseCellDataDownloadState dataDownloadState;

@property (nonatomic, assign) CGFloat downloadingVideoProgress;

- (void)loadData;

+ (CGRect)getImageViewFrameWithImageSize:(CGSize)size;

@end

