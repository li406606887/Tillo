//
//  YMImageBrowserDataSource.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class YMImageBrowserView;

@protocol YMImageBrowserDataSource <NSObject>

@required
- (NSUInteger)ym_numberOfCellForImageBrowserView:(YMImageBrowserView *)imageBrowserView;

- (id<YMImageBrowserCellDataProtocol>)ym_imageBrowserView:(YMImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index;


@end

NS_ASSUME_NONNULL_END
