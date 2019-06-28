//
//  ALMovieControlView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALMovieControlView.h"
#import "ALSliderView.h"
#import "UILabel+AL.h"
#import "UIView+ALFrame.h"

@interface ALMovieControlView ()

/// 底部工具栏
@property (nonatomic, strong) UIView *bottomToolView;

/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;

@property (nonatomic, strong) UIButton *closeBtn;

/// 播放或暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;

/// 播放的当前时间
@property (nonatomic, strong) UILabel *currentTimeLabel;

/// 滑杆
@property (nonatomic, strong) ALSliderView *slider;

/// 视频总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic) BOOL isShow;

@end


@implementation ALMovieControlView

@synthesize isShow = _isShow;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        // 添加子控件
        [self addSubview:self.topToolView];
        [self addSubview:self.bottomToolView];
        
        [self.topToolView addSubview:self.closeBtn];
        [self.bottomToolView addSubview:self.playOrPauseBtn];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.totalTimeLabel];

        [self resetControlView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - 添加子控件约束
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.al_width;
    CGFloat min_view_h = self.al_height;
    CGFloat min_margin = 9;
    
    min_x = 0;
    min_y = 0;
    min_w = min_view_w;
    min_h = is_iPhoneX ? 140 : 70;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    
    min_x = 15;
    min_y = 0;
    min_w = 40;
    min_h = 40;
    self.closeBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.closeBtn.al_bottom = self.topToolView.al_height - 5;
    
    min_h = 73;
    min_h = is_iPhoneX ? 100 : 73;
    min_x = 0;
    min_y = min_view_h - min_h;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 15;
    min_y = 32;
    min_w = 30;
    min_h = 30;
    self.playOrPauseBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.playOrPauseBtn.al_right + 4;
    min_y = 0;
    min_w = 62;
    min_h = 30;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.currentTimeLabel.al_centerY = self.playOrPauseBtn.al_centerY;
    
    min_w = 62;
    min_x = self.bottomToolView.al_width - min_w - min_margin;
    min_y = 0;
    min_h = 30;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.totalTimeLabel.al_centerY = self.playOrPauseBtn.al_centerY;
    
    min_x = self.currentTimeLabel.al_right + 4;
    min_y = 0;
    min_w = self.totalTimeLabel.al_left - min_x - 4;
    min_h = 30;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.slider.al_centerY = self.playOrPauseBtn.al_centerY;
    
    if (!self.isShow) {
        self.topToolView.al_y = -self.topToolView.al_height;
        self.bottomToolView.al_y = self.al_height;
    } else {
        self.topToolView.al_y = 0;
        self.bottomToolView.al_y = self.al_height - self.bottomToolView.al_height;
    }
}

#pragma mark - action
- (void)playPauseButtonClickAction:(UIButton *)sender {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.isSelected;
    BOOL isPlay = !self.playOrPauseBtn.isSelected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(al_movieControlViewDidPlayOrPause:)]) {
        [self.delegate al_movieControlViewDidPlayOrPause:isPlay];
    }
}

- (void)playBtnSelectedState:(BOOL)selected {
    self.playOrPauseBtn.selected = selected;
}

- (void)closeButtonClickAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(al_movieControlViewDidCloseClick)]) {
        [self.delegate al_movieControlViewDidCloseClick];
    }
}

#pragma mark - 控制层显示与隐藏
- (void)resetControlView {
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseBtn.selected     = YES;
    self.topToolView.alpha           = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = NO;
}

- (void)showControlView {
    self.isShow                      = YES;
    
    self.topToolView.al_y            = 0;
    self.topToolView.alpha           = 1;
    
    if (!self.beReady) return;
    self.bottomToolView.al_y         = self.al_height - self.bottomToolView.al_height;
    self.bottomToolView.alpha        = 1;
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.al_y            = -self.topToolView.al_height;
    self.bottomToolView.al_y         = self.al_height;
   
    self.topToolView.alpha           = 0;
    self.bottomToolView.alpha        = 0;
}

//重写hitTest用于按钮事件响应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL  pointAtTopTool = CGRectContainsPoint(self.topToolView.frame, point);
    BOOL  pointAtBottomTool = CGRectContainsPoint(self.bottomToolView.frame, point);
    
    if (pointAtTopTool || pointAtBottomTool) {
        return [super hitTest:point withEvent:event];
    } else {
        return nil;
    }
}

#pragma mark - public
- (void)setPlayTimeWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.slider.value = currentTime/totalTime;
    NSString *currentTimeString = [self convertTimeSecond:currentTime];
    self.currentTimeLabel.text = currentTimeString;
    NSString *totalTimeString = [self convertTimeSecond:totalTime];
    self.totalTimeLabel.text = totalTimeString;
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

#pragma mark - getter
- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
//        _topToolView.backgroundColor = [UIColor redColor];
    }
    return _topToolView;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
//        _bottomToolView.backgroundColor = [UIColor redColor];
    }
    return _bottomToolView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"video_control_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"video_control_pause"] forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"video_control_play"] forState:UIControlStateSelected];
        
        [_playOrPauseBtn addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [UILabel constructLabel:CGRectZero
                                               text:nil
                                               font:[UIFont ALFontSize11]
                                          textColor:[UIColor whiteColor]];
    }
    return _currentTimeLabel;
}

- (ALSliderView *)slider {
    if (!_slider) {
        _slider = [[ALSliderView alloc] init];
        _slider.maximumTrackTintColor = RGB(102, 102, 102);
        _slider.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        _slider.sliderHeight = 1.5;
        [_slider setThumbImage:[UIImage imageNamed:@"video_control_sliderDot"] forState:UIControlStateNormal];
    }
    return _slider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [UILabel constructLabel:CGRectZero
                                             text:nil
                                             font:[UIFont ALFontSize11]
                                        textColor:[UIColor whiteColor]];
    }
    return _totalTimeLabel;
}

@end
