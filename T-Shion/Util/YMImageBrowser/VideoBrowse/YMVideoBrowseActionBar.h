//
//  YMVideoBrowseActionBar.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/20.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YMVideoBrowseActionBar;

@protocol YMVideoBrowseActionBarDelegate <NSObject>

- (void)ym_videoBrowseActionBar:(YMVideoBrowseActionBar *)actionBar clickPlayButton:(UIButton *)playButton;
- (void)ym_videoBrowseActionBar:(YMVideoBrowseActionBar *)actionBar clickPauseButton:(UIButton *)pauseButton;
- (void)ym_videoBrowseActionBar:(YMVideoBrowseActionBar *)actionBar changeValue:(float)value;

@end

@interface YMVideoBrowseActionBar : UIView

@property (nonatomic, weak) id<YMVideoBrowseActionBarDelegate> delegate;

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize;

- (void)pause;
- (void)play;

- (void)setMaxValue:(float)value;
- (void)setCurrentValue:(float)value;

@end

NS_ASSUME_NONNULL_END
