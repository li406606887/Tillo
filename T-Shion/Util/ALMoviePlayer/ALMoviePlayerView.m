//
//  ALMoviePlayerView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/26.
//  Copyright © 2019年 With_Dream. All rights reserved.
//


static float const kTimeRefreshInterval          = 0.1;

#import "ALMoviePlayerView.h"
#import "ALMovieControlView.h"
#import "WebRTCHelper.h"

@interface ALMoviePlayerView ()<UIGestureRecognizerDelegate, ALMovieControlViewDelegate>

@property (nonatomic, strong) ALPlayerView *playerView;//用来手势关闭的

@property (nonatomic, strong) UIImageView *transitionView;//做专场动画

@property (nonatomic, strong) ALMovieProgressView *progressView;

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, copy) NSURL *playerURL;

@property (nonatomic, strong) ALMovieControlView *controlView;

@property (nonatomic, strong) UIButton *replayBtn;

@property (nonatomic, assign) BOOL isPlayToEnd;//是否已经播放完

@property (nonatomic, copy) NSString *messageId;


@end



@implementation ALMoviePlayerView

- (void)dealloc {
    if (_playerView) [_playerView.layer removeObserver:self forKeyPath:@"readyForDisplay"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

//展示
- (void)showWithMessageId:(NSString *)messageId isSoundOff:(BOOL)isSoundOff {
    self.messageId = messageId;
    [self dealWithDrawMessage];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self setupUI];
    [self addNotification];
    
    self.playerView.soundOff = isSoundOff;
    
    //允许录制和播放 rtc那边会引起关闭
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

//    UIViewController *aaa = [SocketViewModel getTopViewController];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIViewController *appRootViewController = window.rootViewController;
    UIViewController *topViewController = appRootViewController;
    
    if (topViewController.presentedViewController != nil) {
        [window addSubview:self];
    } else {
        [appRootViewController.view addSubview:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.transitionView.frame = self.bounds;
    } completion:^(BOOL finished) {
        [self prepareMovie];
    }];
}

- (void)setupUI {
    self.isPlayToEnd = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self addSubview:self.transitionView];
    [self addSubview:self.playerView];
    [self addSubview:self.controlView];
    [self.playerView addSubview:self.replayBtn];
}

//判断视频地址是本地的还是网络的
- (void)prepareMovie {
    if ([self.movieURL.scheme isEqualToString:@"file"]) {//本地视频
        self.playerURL = self.movieURL;
        self.playerView.URL = self.playerURL;
    } else {
        self.progressView = [[ALMovieProgressView alloc] init];
        self.progressView.frame = self.bounds;
        [self insertSubview:self.progressView aboveSubview:self.transitionView];
        [self loadData];
    }
}

//移动当前视频
- (void)movePanGestureRecognizer:(UIPanGestureRecognizer *)pgr {
    if (pgr.state == UIGestureRecognizerStateBegan) {
        [self.playerView pause];
        self.progressView.hidden = YES;
        [self.controlView hideControlView];
    } else if (pgr.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [pgr locationInView:pgr.view.superview];
        CGPoint point = [pgr translationInView:pgr.view];
        CGRect rect = pgr.view.frame;
        CGFloat height = rect.size.height - point.y;
        if (height <= 100) height = 100;
        CGFloat width = rect.size.width * height / rect.size.height;
        CGFloat y = rect.origin.y + 1.5 * point.y;
        CGFloat x = location.x * (rect.size.width - width) / pgr.view.superview.frame.size.width + point.x + rect.origin.x;
        if (rect.origin.y < 0) {
            height = pgr.view.superview.frame.size.height;
            width = pgr.view.superview.frame.size.width;
            y = rect.origin.y + point.y;
            x = rect.origin.x + point.x;
        }
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:(pgr.view.superview.frame.size.height / 1.5 - y) /  (pgr.view.superview.frame.size.height / 1.5)];
        pgr.view.frame = CGRectMake(x, y, width, height);
        self.transitionView.frame = pgr.view.frame;
        
        _replayBtn.width = 50 * (self.playerView.width / self.width);
        _replayBtn.height = _replayBtn.width;
        _replayBtn.centerX = self.playerView.width/2;
        _replayBtn.centerY = self.playerView.height/2;
        [pgr setTranslation:CGPointZero inView:pgr.view];
    } else if (pgr.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pgr velocityInView:pgr.view];
        if (velocity.y > 500 && pgr.view.frame.origin.y > 0) {
            [self closeMoviePlayerView];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.backgroundColor = [UIColor blackColor];
                pgr.view.frame = self.bounds;
                self.replayBtn.width = 50;
                self.replayBtn.height = 50;
                self.replayBtn.centerX = self.playerView.width/2;
                self.replayBtn.centerY = self.playerView.height/2;
                self.transitionView.frame = self.bounds;
            } completion:^(BOOL finished) {
                [self.playerView play];
                self.progressView.hidden = NO;
            }];
        }
    } else {
        [self closeMoviePlayerView];
    }
}

//点击关闭
- (void)closeTgrGestureRecognizer:(UITapGestureRecognizer *)tgr {
    if (self.controlView.isShow) {
        [self.controlView hideControlView];
    } else {
        [self.controlView showControlView];
    }
}

//监听视频是否已经准备好
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self.playerView play];
    [self.controlView playBtnSelectedState:NO];
    self.transitionView.hidden = YES;
    self.controlView.beReady = YES;
}

//关闭视频播放
- (void)closeMoviePlayerView {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.task cancel];
    [self.playerView stop];
    self.transitionView.hidden = NO;
    self.playerView.hidden = YES;
    self.progressView.hidden = YES;
    self.controlView.hidden = YES;
    self.messageId = nil;
    
    UIImage *image = [self getMovieCurrentImage];
    if (image) {
        self.transitionView.image = image;
        self.transitionView.frame = [self convertRect:((AVPlayerLayer *)self.playerView.layer).videoRect fromView:self.playerView];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transitionView.frame =  [self.coverView convertRect:self.coverView.bounds toView:nil];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        self.transitionView.hidden = YES;
        [self removeFromSuperview];
    }];
}

//播放结束之后
- (void)setUpViewsAfterPlayToEndTime {
    self.isPlayToEnd = YES;
    self.replayBtn.hidden = NO;
    [self.controlView playBtnSelectedState:YES];
}

- (void)replayBtnClick {
    self.replayBtn.hidden = YES;
    [self.controlView playBtnSelectedState:NO];
    if (self.isPlayToEnd) {
        self.isPlayToEnd = NO;
        [self.playerView playerItemDidPlayToEnd];
    } else {
        [self.playerView play];
    }
}

#pragma mark - 消息撤回
- (void)dealWithDrawMessage {
    @weakify(self)
    [[[SocketViewModel shared].sendMessageSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(MessageModel *model) {
        @strongify(self)
        if (model.msgType != MESSAGE_Withdraw) {
            return;
        }
        if (model && [model.messageId isEqualToString:self.messageId]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self showWithDrawnAlert];
                [self.task cancel];
                [self.playerView stop];
            });
        }
    }];
}

- (void)showWithDrawnAlert {
    @weakify(self)
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Localized(@"Msg_Been_Withdrawn")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self closeMoviePlayerView];
    }];
    [alertController addAction:cancel];
    [[MBProgressHUD getCurrentUIVC] presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 监听应用进入前台 和 退到后台
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

- (void)applicationWillResignActiveNotification {
    if (!self.replayBtn.hidden) return;//如果已暂停不需要操作
    if (!self.controlView.beReady) return; //如果视频还没加载完成
    self.replayBtn.hidden = NO;
    [self.controlView playBtnSelectedState: YES];
    [self.playerView pause];
    
    if ([WebRTCHelper sharedInstance].inCalling) return;
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //强制设置为扬声器播放
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    
    [session setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    [session setActive:YES error:nil];
}

- (void)applicationDidBecomeActiveNotification {
    [self.controlView playBtnSelectedState: YES];
    if ([WebRTCHelper sharedInstance].inCalling) return;
    //注意，这边不调用的话，无法继续播放
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark UIGestureRecognizerDelegate
//下拉才能出发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint point = [pgr translationInView:pgr.view];
    if (point.y > 0) return YES;
    return NO;
}

//获取当前帧画面
- (UIImage *)getMovieCurrentImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.playerURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime now = [self.playerView currentCMTime];
    [gen setRequestedTimeToleranceAfter:kCMTimeZero];
    [gen setRequestedTimeToleranceBefore:kCMTimeZero];
    CGImageRef image = [gen copyCGImageAtTime:now actualTime:NULL error:NULL];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    if (image) CFRelease(image);
    return thumb;
}

#pragma mark loadData
- (void)loadData {
    self.task = [[ALMovieDownLoadManager shareManager] downloadMovieWithURL:self.movieURL filePath:self.filePath progressBlock:^(CGFloat progress) {
        self.progressView.progress = progress;
    } success:^(NSURL *URL) {
        [self.progressView removeFromSuperview];
        if (self.decryptData) {
            NSData *data = [NSData dataWithContentsOfURL:URL];
            data = self.decryptData(data);
            [data writeToURL:URL atomically:YES];
        }
        self.playerURL = URL;
        self.playerView.URL = self.playerURL;
    } fail:^(NSString *message) {
        [self.progressView removeFromSuperview];
    }];
}

#pragma mark - ALMovieControlViewDelegate
- (void)al_movieControlViewDidCloseClick {
    [self closeMoviePlayerView];
}

- (void)al_movieControlViewDidPlayOrPause:(BOOL)isPlay {
    if (isPlay) {
        if (self.isPlayToEnd) {
            self.isPlayToEnd = NO;
            [self.playerView playerItemDidPlayToEnd];
        } else {
            [self.playerView play];
        }
        self.replayBtn.hidden = YES;
    } else {
        [self.playerView pause];
        self.replayBtn.hidden = NO;
    }
}


#pragma mark - getter
- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[ALPlayerView alloc] initWithFrame:self.bounds];
        _playerView.backgroundColor = [UIColor clearColor];
        [_playerView.layer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanGestureRecognizer:)];
        pgr.delegate = self;
        [_playerView addGestureRecognizer:pgr];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTgrGestureRecognizer:)];
        [_playerView addGestureRecognizer:tgr];
        
        @weakify(self);
        _playerView.playerPlayTimeChanged = ^(NSTimeInterval currentTime, NSTimeInterval duration) {
            @strongify(self);
            [self.controlView setPlayTimeWithCurrentTime:currentTime totalTime:duration];
        };
        
        _playerView.playerDidPlayToEndTime = ^{
            @strongify(self);
            [self setUpViewsAfterPlayToEndTime];
        };
    }
    return _playerView;
}

- (UIImageView *)transitionView {
    if (!_transitionView) {
        _transitionView = [[UIImageView alloc] init];
        _transitionView.frame = [self.coverView convertRect:self.coverView.bounds toView:nil];
        _transitionView.contentMode = UIViewContentModeScaleAspectFit;
        if ([self.coverView isKindOfClass:[UIImageView class]]) {
            _transitionView.image = ((UIImageView *)self.coverView).image;
        }
    }
    return _transitionView;
}

- (ALMovieControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ALMovieControlView alloc] initWithFrame:self.bounds];
        _controlView.delegate = self;
    }
    return _controlView;
}

- (UIButton *)replayBtn {
    if (!_replayBtn) {
        _replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replayBtn setImage:[UIImage imageNamed:@"video_control_replay"] forState:UIControlStateNormal];
        _replayBtn.hidden = YES;
        _replayBtn.frame = CGRectMake(0, 0, 50, 50);
        _replayBtn.centerX = self.playerView.width/2;
        _replayBtn.centerY = self.playerView.height/2;
        [_replayBtn addTarget:self action:@selector(replayBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _replayBtn;
}

@end

//===================================================================================


@interface ALPlayerView () {
    id _timeObserver;
    id _itemEndObserver;
}

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;

@end


@implementation ALPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)setURL:(NSURL *)URL {
    if (_URL != URL) {
        _URL = URL;
        AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
        _playerItem = [AVPlayerItem playerItemWithAsset:asset];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        if (self.soundOff) {
            _player.volume = 0;
        }
        [self enableAudioTracks:YES inPlayerItem:_playerItem];
        ((AVPlayerLayer *)self.layer).player = self.player;
        [self itemObserving];
    }
}

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem *)playerItem {
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            track.enabled = enable;
        }
    }
}

//监听视频播放时间和视频播放结束事件
- (void)itemObserving {
    CMTime interval = CMTimeMakeWithSeconds(kTimeRefreshInterval, NSEC_PER_SEC);
    @weakify(self)
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self)
        if (!self) return;
        NSArray *loadedRanges = self.playerItem.seekableTimeRanges;
        /// 大于0才把状态改为可以播放，解决黑屏问题
        if (loadedRanges.count > 0) {
            if (self.playerPlayTimeChanged) self.playerPlayTimeChanged([self currentTime], [self totalTime]);
        }
    }];
    
    _itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self)
        if (!self) return;
        if (self.playerDidPlayToEndTime) self.playerDidPlayToEndTime();
    }];
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    if (self.player.rate != 0) [self.player pause];
    
    [self.player removeTimeObserver:_timeObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    _itemEndObserver = nil;

    _player = nil;
    _playerItem = nil;
}

- (NSTimeInterval)totalTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.currentTime);
    if (isnan(sec) || sec < 0) {
        return 0;
    }
    return sec;
}

- (CMTime)currentCMTime {
    return self.player.currentItem.currentTime;
}

//播放结束 执行重复播放
- (void)playerItemDidPlayToEnd {
    [((AVPlayerLayer *)self.layer).player seekToTime:kCMTimeZero];
    [((AVPlayerLayer *)self.layer).player play];
}

- (void)setSoundOff:(BOOL)soundOff {
    _soundOff = soundOff;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//===================================================================================

//===================================================================================
//下载管理 只支持单个视频下载

@interface ALMovieDownLoadManager()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, copy) void(^success)(NSURL *URL);

@property (nonatomic, copy) void(^fail)(NSString *message);

@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);

@property (nonatomic, copy) NSString *filePath;

@end

@implementation ALMovieDownLoadManager

+ (instancetype)shareManager {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
    }
    return self;
}

- (NSURLSessionDownloadTask *)downloadMovieWithURL:(NSURL *)URL
                                          filePath:(NSString *)filePath
                                     progressBlock:(void(^)(CGFloat progress))progressBlock
                                           success:(void(^)(NSURL *URL))success
                                              fail:(void(^)(NSString *message))fail {
    self.progressBlock = progressBlock;
    self.success = success;
    self.fail = fail;
    self.filePath = filePath;

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        if (self.success) self.success([NSURL fileURLWithPath:filePath]);
        [self clearAllBlock];
        return nil;
    }
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:URL];
    [task resume];
    return task;
}

- (void)clearAllBlock {
    self.success = nil;
    self.fail = nil;
    self.filePath = nil;
    self.progressBlock = nil;
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.filePath error:nil];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBlock) self.progressBlock(totalBytesWritten * 1.0 / totalBytesExpectedToWrite);
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {

    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isExists) {
            if (self.success) self.success([NSURL fileURLWithPath:self.filePath]);
        } else {
            if (error.code != NSURLErrorCancelled && self.fail) self.fail(@"下载失败");
        }
        [self clearAllBlock];
    });
}

@end
//===================================================================================




//===================================================================================
//加载进度条
@implementation ALMovieProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.radius = 20;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithWhite:0 alpha:0.1] set];
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:self.radius startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2  clockwise:YES];
    [bgPath fill];
    
    [[UIColor colorWithWhite:1 alpha:0.9] set];
    [bgPath addArcWithCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:self.radius startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2  clockwise:YES];
    [bgPath stroke];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0) radius:self.radius - 2 startAngle:-M_PI_2 endAngle:self.progress * 2 * M_PI - M_PI_2  clockwise:YES];
    [path addLineToPoint:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
    [path fill];
}

@end

//===================================================================================


