//
//  YMImageBrowserCellDataProtocol.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol YMImageBrowserCellDataProtocol <NSObject>

@required
- (Class)ym_classOfBrowserCell;

@optional
- (id)ym_browserCellSourceObject;

- (BOOL)ym_browserAllowSaveToPhotoAlbum;

- (void)ym_browserSaveToPhotoAlbum;

- (CGRect)ym_browserCurrentImageFrameWithImageSize:(CGSize)size;

- (void)ym_preload;

@end

NS_ASSUME_NONNULL_END
