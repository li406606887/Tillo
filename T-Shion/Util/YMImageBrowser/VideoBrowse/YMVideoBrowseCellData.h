//
//  YMVideoBrowseCellData.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/20.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "YMImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMVideoBrowseCellData : NSObject<YMImageBrowserCellDataProtocol>

/** 视频网络地址 */
@property (nonatomic, strong, nullable) NSURL *url;

/** 来自相册的视频资源 */
@property (nonatomic, strong, nullable) PHAsset *phAsset;

/** 来自相册的视频资源 */
@property (nonatomic, strong, nullable) AVAsset *avAsset;

@property (nonatomic, weak, nullable) id sourceObject;

/** 视频第一帧 */
@property (nonatomic, strong, nullable) UIImage *firstFrame;

/** 自动播放视频的数量。默认值为0。
 当自动播放时，用户交互可能是卡顿的，所以除非真的需要，否则不要使用自动播放 */
@property (nonatomic, assign) NSUInteger autoPlayCount;

/** 重复播放视频的次数。默认值为0。 */
@property (nonatomic, assign) NSUInteger repeatPlayCount;

/** 允许保存到相册:默认YES */
@property (nonatomic, assign) BOOL allowSaveToPhotoAlbum;

/** 扩展信息 */
@property (nonatomic, strong, nullable) id extraData;

/** 是否是点击是选中的那个视图 */
@property (nonatomic, assign) BOOL isShowIndex;

/** 是否静音播放，默认NO */
@property (nonatomic, assign) BOOL playSoundOff;

//是否是aillo消息类型
- (BOOL)isMessageData;

- (BOOL)hadLocalVideoFile;

- (void)downLoadData;

@end

NS_ASSUME_NONNULL_END
