//
//  YMImageBrowser.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/13.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMIBGestureInteractionProfile.h"
#import "YMImageBrowserCellDataProtocol.h"
#import "YMImageBrowserDataSource.h"
#import "YMImageBrowserDelegate.h"
#import "YMImageBrowserToolBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YMImageBrowserTransitionType) {
    YMImageBrowserTransitionTypeNone,
    YMImageBrowserTransitionTypeFade,
    YMImageBrowserTransitionTypeCoherent
};

typedef NS_ENUM(NSInteger, YMImageBrowserType) {
    YMImageBrowserTypeDefault,//默认
    YMImageBrowserTypePreview//相册预览
};


@interface YMImageBrowser : UIViewController

- (instancetype)initWithType:(YMImageBrowserType)type;

- (void)show;

- (void)showFromController:(UIViewController *)fromController;

- (void)hide;

- (void)reloadData;

- (id<YMImageBrowserCellDataProtocol>)currentData;

@property (nonatomic, copy) NSArray<id<YMImageBrowserCellDataProtocol>> *dataSourceArray;

@property (nonatomic, weak) id<YMImageBrowserDataSource> dataSource;

@property (nonatomic, weak) id<YMImageBrowserDelegate> delegate;


/** 当前位置 */
@property (nonatomic, assign) NSUInteger currentIndex;

/** 是否预加载，默认YES */
@property (nonatomic, assign) BOOL shouldPreload;

/** 默认 UIInterfaceOrientationMaskAllButUpsideDown */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

/** 分页间的边距，默认20 */
@property (nonatomic, assign) CGFloat distanceBetweenPages;

/** 背景色 ， 默认黑色 */
@property (nonatomic, strong) UIColor *backgroundColor;

/** 自动隐藏文件 */
@property (nonatomic, assign) BOOL autoHideSourceObject;

/** 弹起动画，默认YMImageBrowserTransitionTypeCoherent */
@property (nonatomic, assign) YMImageBrowserTransitionType enterTransitionType;

/** 收起动画，默认YMImageBrowserTransitionTypeCoherent */
@property (nonatomic, assign) YMImageBrowserTransitionType outTransitionType;

/** 转场动画默认 0.25. */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

/** 是否在转场中 */
@property (nonatomic, assign, readonly) BOOL transitioning;

/** 手势交互动画参数 */
@property (nonatomic, strong) YMIBGestureInteractionProfile *giProfile;

/** 是否隐藏状态栏,默认YES */
@property (nonatomic, assign) BOOL shouldHideStatusBar;

@property (nonatomic, assign) NSUInteger dataCacheCountLimit;

@property (nonatomic, copy) NSArray<__kindof UIView<YMImageBrowserToolBarProtocol> *> *toolBars;

@end

NS_ASSUME_NONNULL_END
