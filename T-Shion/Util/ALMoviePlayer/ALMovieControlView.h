//
//  ALMovieControlView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALMovieControlViewDelegate <NSObject>

@optional

//点击关闭按钮
- (void)al_movieControlViewDidCloseClick;

//点击开始或者暂停按钮
- (void)al_movieControlViewDidPlayOrPause:(BOOL)isPlay;

@end


@interface ALMovieControlView : UIView

@property (nonatomic, readonly) BOOL isShow;
@property (nonatomic) BOOL beReady;//视频是否准备好
@property (nonatomic, weak) id <ALMovieControlViewDelegate> delegate;

/// 显示控制层
- (void)showControlView;
/// 隐藏控制层
- (void)hideControlView;

- (void)setPlayTimeWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)playBtnSelectedState:(BOOL)selected;

@end

