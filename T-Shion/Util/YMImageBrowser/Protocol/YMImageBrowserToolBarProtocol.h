//
//  YMImageBrowserToolBarProtocol.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/24.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMImageBrowserCellDataProtocol.h"
#import "YMIBLayoutDirectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YMImageBrowserToolBarProtocol <NSObject>

@optional

- (void)ym_browserUpdateLayoutWithDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize;

- (void)ym_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YMImageBrowserCellDataProtocol>)data;


@end

NS_ASSUME_NONNULL_END
