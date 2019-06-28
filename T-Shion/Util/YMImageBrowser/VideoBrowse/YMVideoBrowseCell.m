//
//  YMVideoBrowseCell.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/21.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMVideoBrowseCell.h"
#import "YMVideoBrowseCellData.h"
#import "YMVideoBrowseCellData+Internal.h"
#import "YMIBLayoutDirectionManager.h"
#import "YMIBGestureInteractionProfile.h"
#import "YMVideoBrowseActionBar.h"
#import "YMVideoBrowseTopBar.h"
#import "YMImageBrowserProgressView.h"
#import "YMIBUtilities.h"

#import "YMImageBrowserCellProtocol.h"

#import "WebRTCHelper.h"

@interface YMVideoBrowseCell ()<YMImageBrowserCellProtocol, YMVideoBrowseTopBarDelegate, YMVideoBrowseActionBarDelegate,YMImageBrowserCellProtocol, UIGestureRecognizerDelegate> {
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
    AVPlayerItem *_playerItem;
    
    YMImageBrowserLayoutDirection _layoutDirection;
    
    CGSize _containerSize;
    BOOL _playing;
    BOOL _currentIndexIsSelf;
    BOOL _bodyInCenter;
    BOOL _active;
    BOOL _outTransitioning;
    
    CGPoint _gestureInteractionStartPoint;
    // Gestural interaction is in progress.
    BOOL _gestureInteracting;
    YMIBGestureInteractionProfile *_giProfile;
    
    UIInterfaceOrientation _statusBarOrientationBefore;
}

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIImageView *firstFrameImageView;//第一帧
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) YMVideoBrowseActionBar *actionBar;
@property (nonatomic, strong) YMVideoBrowseTopBar *topBar;
@property (nonatomic, strong) YMVideoBrowseCellData *cellData;


@end


@implementation YMVideoBrowseCell

@synthesize ym_browserScrollEnabledBlock = _ym_browserScrollEnabledBlock;
@synthesize ym_browserDismissBlock = _ym_browserDismissBlock;
@synthesize ym_browserChangeAlphaBlock = _ym_browserChangeAlphaBlock;
@synthesize ym_browserToolBarHiddenBlock = _ym_browserToolBarHiddenBlock;

#pragma mark - z生命周期

- (void)dealloc {
    [self removeObserverForDataState];
    [self removeObserverForSystem];
    [self cancelPlay];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVars];
        [self addGesture];
        [self addObserverForSystem];
        
        [self.contentView addSubview:self.baseView];
        [self.baseView addSubview:self.firstFrameImageView];
        [self.baseView addSubview:self.playButton];
    }
    return self;
}

- (void)prepareForReuse {
    [self initVars];
    [self removeObserverForDataState];
    [self cancelPlay];
    self.firstFrameImageView.image = nil;
    self.playButton.hidden = YES;
    [self.baseView ym_hideProgressView];
    [self.contentView ym_hideProgressView];
    [super prepareForReuse];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _outTransitioning = NO;
}

- (void)initVars {
    _layoutDirection = YMImageBrowserLayoutDirectionUnknown;
    _containerSize = CGSizeMake(1, 1);
    _playing = NO;
    _currentIndexIsSelf = NO;
    _bodyInCenter = YES;
    _gestureInteractionStartPoint = CGPointZero;
    _gestureInteracting = NO;
    _active = YES;
    _outTransitioning = NO;
    
    //允许录制和播放 rtc那边会引起关闭
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#pragma mark - <YMImageBrowserCellProtocol>

- (void)ym_initializeBrowserCellWithData:(id<YMImageBrowserCellDataProtocol>)data layoutDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    _containerSize = containerSize;
    _layoutDirection = layoutDirection;
    _currentIndexIsSelf = YES;
    
    if (![data isKindOfClass:YMVideoBrowseCellData.class]) return;
    self.cellData = data;
    
    [self addObserverForDataState];
    
    [self updateLayoutWithContainerSize:containerSize];
}

- (void)ym_browserLayoutDirectionChanged:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    _containerSize = containerSize;
    _layoutDirection = layoutDirection;
    
    if (_gestureInteracting) {
        [self restoreGestureInteractionWithDuration:0];
    }
    
    [self updateLayoutWithContainerSize:containerSize];
}

- (void)ym_browserPageIndexChanged:(NSUInteger)pageIndex ownIndex:(NSUInteger)ownIndex {
    if (pageIndex != ownIndex) {
        if (_playing) {
            [self.baseView ym_hideProgressView];
            [self cancelPlay];
            [self.cellData loadData];
        }
        [self restoreGestureInteractionWithDuration:0];
        _currentIndexIsSelf = NO;
    } else {
        _currentIndexIsSelf = YES;
        [self autoPlay];
    }
}

- (void)ym_browserInitializeFirst:(BOOL)isFirst {
    if (isFirst) {
        [self autoPlay];
    }
}

- (void)ym_browserBodyIsInTheCenter:(BOOL)isIn {
    _bodyInCenter = isIn;
    if (!isIn) {
        _gestureInteractionStartPoint = CGPointZero;
    }
}

- (UIView *)ym_browserCurrentForegroundView {
    [self restorePlay];
    if (self.cellData.firstFrame) {
        self.playButton.hidden = YES;
        return self.firstFrameImageView;
    }
    return self.baseView;
}

- (void)ym_browserSetGestureInteractionProfile:(YMIBGestureInteractionProfile *)giProfile {
    _giProfile = giProfile;
}

- (void)ym_browserStatusBarOrientationBefore:(UIInterfaceOrientation)orientation {
    _statusBarOrientationBefore = orientation;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - <YMVideoBrowseActionBarDelegate>

- (void)ym_videoBrowseActionBar:(YMVideoBrowseActionBar *)actionBar clickPlayButton:(UIButton *)playButton {
    if (_player) {
        [_player play];
        [self.actionBar play];
    }
}

- (void)ym_videoBrowseActionBar:(YMVideoBrowseActionBar *)actionBar clickPauseButton:(UIButton *)pauseButton {
    if (_player) {
        [_player pause];
        [self.actionBar pause];
    }
}

- (void)ym_videoBrowseActionBar:(YMVideoBrowseActionBar *)actionBar changeValue:(float)value {
    [self videoJumpWithScale:value];
}

#pragma mark - <YBVideoBrowseTopBarDelegate>

- (void)ym_videoBrowseTopBar:(YMVideoBrowseTopBar *)topBar clickCancelButton:(UIButton *)button {
    [self browserDismiss];
}

#pragma mark - private

- (void)browserDismiss {
    _outTransitioning = YES;
    [self.contentView ym_hideProgressView];
    [self ym_hideProgressView];
    self.ym_browserDismissBlock();
    _gestureInteracting = NO;
}

- (void)updateLayoutWithContainerSize:(CGSize)containerSize {
    self.baseView.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    self.firstFrameImageView.frame = [self.cellData.class getImageViewFrameWithImageSize:self.cellData.firstFrame.size];
    self.playButton.center = self.baseView.center;
    if (_playerLayer) {
        _playerLayer.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    }
    self.actionBar.frame = [self.actionBar getFrameWithContainerSize:containerSize];
    self.topBar.frame = [self.topBar getFrameWithContainerSize:containerSize];
}

- (void)startPlay {
    if (!self.cellData.avAsset || _playing) return;
    
    if ([self.cellData isMessageData] && ![self.cellData hadLocalVideoFile]) {
        //如果视频还没加载，点击播放按钮则下载
        self.playButton.hidden = YES;
        [self.cellData downLoadData];
        return;
    }

    [self cancelPlay];
    
    _playing = YES;
    
    _playerItem = [AVPlayerItem playerItemWithAsset:self.cellData.avAsset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 0, _containerSize.width, _containerSize.height);
    [self.baseView.layer addSublayer:_playerLayer];
    
    [self addObserverForPlayer];
    
    self.playButton.hidden = YES;
    
    if (self.cellData.playSoundOff) {
        _player.volume = 0;
    }
    
    if (![self.cellData isMessageData]) {
        //如果是aillo消息类型不显示转圈，直接播放
        [self.baseView ym_showProgressViewLoading];
    }
}

- (void)cancelPlay {
    [self restoreTooBar];
    [self restorePlay];
    [self restoreAsset];
}

- (void)restorePlay {
    if (_actionBar) self.actionBar.hidden = YES;
    if (_topBar) self.topBar.hidden = YES;
    
    [self removeObserverForPlayer];
    
    if (_player) {
        [_player pause];
        _player = nil;
    }
    if (_playerLayer) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    _playerItem = nil;
    
    _playing = NO;
}

- (void)restoreAsset {
    AVAsset *asset = self.cellData.avAsset;
    if ([asset isKindOfClass:AVURLAsset.class]) {
        self.cellData.avAsset = [AVURLAsset assetWithURL:((AVURLAsset *)asset).URL];
    }
}

- (void)restoreTooBar {
    if (!_giProfile.isPreviewType) {
        if (self.ym_browserToolBarHiddenBlock) {
            self.ym_browserToolBarHiddenBlock(0);
        }
    }
}

- (void)autoPlay {
    YMVideoBrowseCellData *data = self.cellData;
    if (data.autoPlayCount > 0) {
        --data.autoPlayCount;
        [self startPlay];
    }
}

- (void)videoJumpWithScale:(float)scale {
    CMTime startTime = CMTimeMakeWithSeconds(scale, _player.currentTime.timescale);
    AVPlayer *tmpPlayer = _player;
    [_player seekToTime:startTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
        if (finished && tmpPlayer == self->_player) {
            [self->_player play];
            [self.actionBar play];
        }
    }];
}

- (void)cellDataDownloadStateChanged {
    YMVideoBrowseCellData *data = self.cellData;
    YMVideoBrowseCellDataDownloadState dataDownloadState = data.dataDownloadState;
    switch (dataDownloadState) {
        case YMVideoBrowseCellDataDownloadStateIsDownloading: {
            self.playButton.hidden = YES;
            
            if (!_gestureInteracting) {
                [self.contentView ym_showProgressViewWithValue:self.cellData.downloadingVideoProgress];
            }
        }
            break;
        case YMVideoBrowseCellDataDownloadStateComplete: {
            [self.contentView ym_hideProgressView];
            if (_currentIndexIsSelf) {
                [self startPlay];
            }
        }
            break;
            
        case YMVideoBrowseCellDataDownloadStateFailed: {
                [self.contentView ym_hideProgressView];
                [self.contentView ym_showProgressViewWithText:@"视频加载失败" click:nil];
            }
            break;
        default:
            break;
    }
}

- (void)cellDataStateChanged {
    YMVideoBrowseCellData *data = self.cellData;
    YMVideoBrowseCellDataState dataState = data.dataState;
    switch (dataState) {
        case YMVideoBrowseCellDataStateInvalid: {
            NSLog(@"视频无效");
        }
            break;
        case YMVideoBrowseCellDataStateFirstFrameReady: {
            if (self.firstFrameImageView.image != data.firstFrame) {
                self.firstFrameImageView.image = data.firstFrame;
                self.firstFrameImageView.frame = [self.cellData.class getImageViewFrameWithImageSize:self.cellData.firstFrame.size];
                
                if ([self.cellData hadLocalVideoFile]) {
                    //如果视频已经加载完毕且是第一个就播放
                    if (self.cellData.isShowIndex) {
                        self.playButton.hidden = YES;
                        [self startPlay];
                    } else {
                        self.playButton.hidden = NO;
                    }
                    
                } else {
                    if (self.cellData.dataDownloadState == YMVideoBrowseCellDataDownloadStateIsDownloading) {
                        if (!_gestureInteracting) {
                            [self.contentView ym_showProgressViewWithValue:self.cellData.downloadingVideoProgress];
                        }
                        
                        self.playButton.hidden = YES;
                    } else {
                        self.playButton.hidden = NO;
                    }
                }
            }
        }
            break;
        case YMVideoBrowseCellDataStateIsLoadingPHAsset: {
            [self.baseView ym_showProgressViewLoading];
        }
            break;
        case YMVideoBrowseCellDataStateLoadPHAssetSuccess: {
            [self.baseView ym_hideProgressView];
        }
            break;
        case YMVideoBrowseCellDataStateLoadPHAssetFailed: {
            NSLog(@"视频无效");
        }
            break;
        case YMVideoBrowseCellDataStateIsLoadingFirstFrame: {
            [self.baseView ym_showProgressViewLoading];
        }
            break;
        case YMVideoBrowseCellDataStateLoadFirstFrameSuccess: {
            [self.baseView ym_hideProgressView];
        }
            break;
        case YMVideoBrowseCellDataStateLoadFirstFrameFailed: {
            // 视频第一帧加载失败一样要显示播放按钮.
            [self.baseView ym_hideProgressView];
            self.playButton.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)avPlayerItemStatusChanged {
    if (!_active) return;
    
    self.playButton.hidden = YES;
    switch (_playerItem.status) {
        case AVPlayerItemStatusReadyToPlay: {
            self.ym_browserToolBarHiddenBlock(1);
            
            [_player play];
            
            if (!_giProfile.isPreviewType) {
                [self.baseView addSubview:self.actionBar];
                [self.baseView addSubview:self.topBar];
                self.actionBar.hidden = NO;
                self.topBar.hidden = NO;
                
                [self.actionBar play];
                double max = CMTimeGetSeconds(_playerItem.duration);
                [self.actionBar setMaxValue:isnan(max) || isinf(max) ? 0 : max];
            }
        
            [self.baseView ym_hideProgressView];
        }
            break;
        case AVPlayerItemStatusUnknown: {
            NSLog(@"视频错误");
            [self cancelPlay];
        }
            break;
        case AVPlayerItemStatusFailed: {
            NSLog(@"视频错误");
            [self cancelPlay];
        }
            break;
    }
}

#pragma mark - observe

- (void)addObserverForPlayer {
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) wSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(0.05, NSEC_PER_SEC);
    [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        float currentTime = time.value * 1.0 / time.timescale;
        NSLog(@"-----%f",currentTime);
        [sSelf.actionBar setCurrentValue:currentTime];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)removeObserverForPlayer {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)addObserverForDataState {
    [self.cellData addObserver:self forKeyPath:@"dataState" options:NSKeyValueObservingOptionNew context:nil];
    [self.cellData addObserver:self forKeyPath:@"dataDownloadState" options:NSKeyValueObservingOptionNew context:nil];
    [self.cellData loadData];
}

- (void)removeObserverForDataState {
    [self.cellData removeObserver:self forKeyPath:@"dataState"];
    [self.cellData removeObserver:self forKeyPath:@"dataDownloadState"];
}

- (void)videoPlayFinish:(NSNotification *)noti {
    if (noti.object == _playerItem) {
        YMVideoBrowseCellData *data = self.cellData;
        if (data.repeatPlayCount > 0) {
            --data.repeatPlayCount;
            [self videoJumpWithScale:0];
            [_player play];
        } else {
            self.playButton.hidden = NO;
            [self cancelPlay];
            [self.cellData loadData];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (!_outTransitioning) {
        if (object == _playerItem) {
            if ([keyPath isEqualToString:@"status"]) {
                [self avPlayerItemStatusChanged];
            }
        } else if (object == self.cellData) {
            if ([keyPath isEqualToString:@"dataState"]) {
                [self cellDataStateChanged];
            } else if ([keyPath isEqualToString:@"dataDownloadState"]) {
                [self cellDataDownloadStateChanged];
            }
        }
    }
}

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    _active = NO;
    if (_player && _playing) {
        [_player pause];
        [self.actionBar pause];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    _active = YES;
    //注意，这边不调用的话，无法继续播放
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > YMIB_HEIGHT_STATUSBAR) {
        if (_player && _playing) {
            [_player pause];
            [self.actionBar pause];
        }
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            if (_player && _playing) {
                [_player pause];
                [self.actionBar pause];
            }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

#pragma mark - 手势相关
- (void)addGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapGesture:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPanGesture:)];
    panGesture.cancelsTouchesInView = NO;
    panGesture.delegate = self;
    
    [tapGesture requireGestureRecognizerToFail:panGesture];
    
    [self.baseView addGestureRecognizer:tapGesture];
    [self.baseView addGestureRecognizer:panGesture];
}

- (void)respondsToTapGesture:(UITapGestureRecognizer *)tap {
    
    if (_giProfile.isPreviewType) {
        self.ym_browserToolBarHiddenBlock(2);
    } else {
        if (_playing) {
            self.actionBar.hidden = !self.actionBar.isHidden;
            self.topBar.hidden = !self.topBar.isHidden;
        } else {
            [self browserDismiss];
        }
    }
}

- (void)respondsToPanGesture:(UIPanGestureRecognizer *)pan {
    if ((!self.firstFrameImageView.image && !_playing) || _giProfile.disable) return;
    
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        _gestureInteractionStartPoint = point;
        
    } else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateRecognized || pan.state == UIGestureRecognizerStateFailed) {
        
        // END
        if (_gestureInteracting) {
            CGPoint velocity = [pan velocityInView:self.baseView];
            
            BOOL velocityArrive = ABS(velocity.y) > _giProfile.dismissVelocityY;
            BOOL distanceArrive = ABS(point.y - _gestureInteractionStartPoint.y) > _containerSize.height * _giProfile.dismissScale;
            
            BOOL shouldDismiss = distanceArrive || velocityArrive;
            if (shouldDismiss) {
                [self browserDismiss];
            } else {
                [self restoreGestureInteractionWithDuration:_giProfile.restoreDuration];
            }
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocityPoint = [pan velocityInView:self.baseView];
        CGFloat triggerDistance = _giProfile.triggerDistance;
        
        BOOL distanceArrive = ABS(point.y - _gestureInteractionStartPoint.y) > triggerDistance && (ABS(point.x - _gestureInteractionStartPoint.x) < triggerDistance && ABS(velocityPoint.x) < 500);
        
        BOOL shouldStart = !_gestureInteracting && distanceArrive && _currentIndexIsSelf && _bodyInCenter;
        
        [self.contentView ym_hideProgressView];
        // START
        if (shouldStart) {
            if (_actionBar) self.actionBar.hidden = YES;
            if (_topBar) self.topBar.hidden = YES;
            
            if ([UIApplication sharedApplication].statusBarOrientation != _statusBarOrientationBefore) {
                [self browserDismiss];
            } else {
                _gestureInteractionStartPoint = point;
                
                CGRect startFrame = self.baseView.bounds;
                CGFloat anchorX = (point.x - startFrame.origin.x) / startFrame.size.width,
                anchorY = (point.y - startFrame.origin.y) / startFrame.size.height;
                self.baseView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
                self.baseView.userInteractionEnabled = NO;
                
                self.ym_browserScrollEnabledBlock(NO);
                self.ym_browserToolBarHiddenBlock(1);
                
                _gestureInteracting = YES;
            }
        }
        
        // CHANGE
        if (_gestureInteracting) {
            self.baseView.center = point;
            CGFloat scale = 1 - ABS(point.y - _gestureInteractionStartPoint.y) / (_containerSize.height * 1.2);
            if (scale > 1) scale = 1;
            if (scale < 0.35) scale = 0.35;
            self.baseView.transform = CGAffineTransformMakeScale(scale, scale);
            
            CGFloat alpha = 1 - ABS(point.y - _gestureInteractionStartPoint.y) / (_containerSize.height * 1.1);
            if (alpha > 1) alpha = 1;
            if (alpha < 0) alpha = 0;
            self.ym_browserChangeAlphaBlock(alpha, 0);
        }
    }
}

- (void)restoreGestureInteractionWithDuration:(NSTimeInterval)duration {
//    if (_actionBar) self.actionBar.hidden = NO;
//    if (_topBar) self.topBar.hidden = NO;
    
    if (self.cellData.isShowIndex) {
        //这边注意，没设置的话如果有本地视频就会马上播放
        self.cellData.isShowIndex = NO;
    }
    
    if (self.cellData.playSoundOff) {
        //这边注意，没设置的话视频播放会一直是静音
        self.cellData.playSoundOff = NO;
    }
    
    self.ym_browserChangeAlphaBlock(1, duration);
    
    void (^animations)(void) = ^{
        self.baseView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.baseView.center = CGPointMake(self->_containerSize.width / 2, self->_containerSize.height / 2);
        self.baseView.transform = CGAffineTransformIdentity;
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.ym_browserScrollEnabledBlock(YES);
        if (!self->_giProfile.isPreviewType) {
            if (!self->_playing) self.ym_browserToolBarHiddenBlock(0);
        }
        
        self.baseView.userInteractionEnabled = YES;
        
        self->_gestureInteractionStartPoint = CGPointZero;
        self->_gestureInteracting = NO;
    };
    if (duration <= 0) {
        animations();
        completion(NO);
    } else {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
}

#pragma mark - touch event

- (void)clickPlayButton:(UIButton *)button {
    [self startPlay];
}

#pragma mark - getter

- (UIView *)baseView {
    if (!_baseView) {
        _baseView = [UIView new];
        _baseView.backgroundColor = [UIColor clearColor];
    }
    return _baseView;
}

- (UIImageView *)firstFrameImageView {
    if (!_firstFrameImageView) {
        _firstFrameImageView = [UIImageView new];
        _firstFrameImageView.contentMode = UIViewContentModeScaleAspectFit;
        _firstFrameImageView.layer.masksToBounds = YES;
    }
    return _firstFrameImageView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *playImg = [UIImage imageNamed:@"ymib_bigPlay"];
        _playButton.bounds = CGRectMake(0, 0, 80, 80);
        [_playButton setImage:playImg forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.hidden = YES;
    }
    return _playButton;
}

- (YMVideoBrowseActionBar *)actionBar {
    if (!_actionBar) {
        _actionBar = [YMVideoBrowseActionBar new];
        _actionBar.delegate = self;
    }
    return _actionBar;
}

- (YMVideoBrowseTopBar *)topBar {
    if (!_topBar) {
        _topBar = [YMVideoBrowseTopBar new];
        _topBar.delegate = self;
    }
    return _topBar;
}

@end
