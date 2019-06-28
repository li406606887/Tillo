//
//  YMVideoBrowseTopBar.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/20.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YMVideoBrowseTopBar;

@protocol YMVideoBrowseTopBarDelegate <NSObject>

- (void)ym_videoBrowseTopBar:(YMVideoBrowseTopBar *)topBar clickCancelButton:(UIButton *)button;

@end

@interface YMVideoBrowseTopBar : UIView

@property (nonatomic, weak) id<YMVideoBrowseTopBarDelegate> delegate;

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize;

@end

NS_ASSUME_NONNULL_END
