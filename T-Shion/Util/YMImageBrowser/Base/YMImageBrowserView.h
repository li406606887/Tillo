//
//  YMImageBrowserView.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMImageBrowser.h"
#import "YMImageBrowserDataSource.h"
#import "YMImageBrowserCellDataProtocol.h"
#import "YMImageBrowserCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YMImageBrowserView;

@protocol YMImageBrowserViewDelegate <NSObject>

@required

- (void)ym_imageBrowserViewDismiss:(YMImageBrowserView *)browserView;

- (void)ym_imageBrowserView:(YMImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration;

- (void)ym_imageBrowserView:(YMImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index;

- (void)ym_imageBrowserView:(YMImageBrowserView *)browserView hideTooBar:(NSInteger)hiddenType;

@end


@interface YMImageBrowserView : UICollectionView

@property (nonatomic, weak) id<YMImageBrowserDataSource> ym_dataSource;

@property (nonatomic, weak) YMImageBrowser<YMImageBrowserViewDelegate> *ym_delegate;

/** 当前滑动位置 */
@property (nonatomic, assign, readonly) NSUInteger currentIndex;

@property (nonatomic, strong) YMIBGestureInteractionProfile *giProfile;

@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientationBefore;

/** 缓存数量限制，默认8 */
@property (nonatomic, assign) NSUInteger cacheCountLimit;

/** 是否预加载 */
@property (nonatomic, assign) BOOL shouldPreload;

- (id <YMImageBrowserCellDataProtocol>)currentData;

- (id <YMImageBrowserCellDataProtocol>)dataAtIndex:(NSUInteger)index;

- (void)preloadWithCurrentIndex:(NSInteger)index;

- (void)updateLayoutWithDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

- (void)scrollToPageWithIndex:(NSInteger)index;

- (void)ym_reloadData;


@end

NS_ASSUME_NONNULL_END
