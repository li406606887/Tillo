//
//  YMRTCBrowser.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/6/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMRTCDataItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMRTCBrowser : UIViewController

- (instancetype)initWithDataItem:(YMRTCDataItem *)dataItem;

- (void)show;
- (void)showFromController:(UIViewController *)fromController;
- (void)hide;


@end

NS_ASSUME_NONNULL_END
