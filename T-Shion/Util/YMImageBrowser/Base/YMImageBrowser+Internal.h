//
//  YMImageBrowser+Internal.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/21.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowser.h"
#import "YMImageBrowserView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMImageBrowser ()

@property (nonatomic, strong) YMImageBrowserView *browserView;

@property (nonatomic, weak, nullable) id hiddenSourceObject;

@end

NS_ASSUME_NONNULL_END
