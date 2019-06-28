//
//  ALCameraRecordViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/14.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALCameraRecordViewController.h"
#import "ALCamera.h"
#import "ALCameraSnapButton.h"
#import "TSImageHandler.h"

static CGFloat kVideoMaxTime = 10.0;      //视频最大时长 (单位/秒)
static CGFloat kVideoMinTime = 0.5;       //视频最小时长 (单位/秒)
static CGFloat kTimerInterval = 0.01;     //定时器记录视频间隔
static CGFloat kStarVideoDuration = 0.2;  //录制视频前的动画时间


@interface ALCameraRecordViewController ()<ALCameraDelegate>

@property (nonatomic, strong) ALCamera *camera;
@property (nonatomic, strong) ALCameraSnapButton *snapButton;

@property (nonatomic, strong) UIButton *dissMissBtn;
@property (nonatomic, strong) UIButton *switchButton;

@property (nonatomic, strong) UIButton *captureBackBtn;
@property (nonatomic, strong) UIButton *captureSendBtn;

@property (nonatomic, strong) UIImageView *imagePreview;
@property (nonatomic, strong) UIView *photoPreviewContainerView;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat timeLength;
@property (nonatomic, assign) BOOL isShooting;

//视频展示相关
@property (nonatomic, strong) UIView *videoPreviewContainerView;  //视频预览View
@property (nonatomic, strong) AVPlayerLayer *videoPlayerLayer;
@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, copy) NSString *videoFilePath;
@property (nonatomic, copy) NSString *videoFoldPath;
@property (nonatomic, copy) NSString *videoFileName;
@property (nonatomic, copy) NSString *videoThumbIMGName;
@property (nonatomic, copy) NSString *duration;

@property (nonatomic, strong) UIImage *thumbnailVideoImage;

@end

@implementation ALCameraRecordViewController

- (instancetype)initWithVideoFoldPath:(NSString *)videoFoldPath {
    if (self = [super init]) {
        self.videoFoldPath = videoFoldPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setUpViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tipLabelAnimation];
}

- (void)setUpViews {
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.camera attachToViewController:self frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.snapButton];
    [self.view addSubview:self.dissMissBtn];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.captureBackBtn];
    [self.view addSubview:self.captureSendBtn];
    [self.view addSubview:self.tipLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.dissMissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_left).offset(((SCREEN_WIDTH - 75)/4));
        make.centerY.equalTo(self.snapButton);
    }];
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_right).offset(-((SCREEN_WIDTH - 75)/4));
        make.centerY.equalTo(self.snapButton);
    }];
    
    [self.captureBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(15);
        
        CGFloat bottom = is_iPhoneX ? 73 + 50 : 50;
        make.bottom.equalTo(self.view.mas_top).with.offset(bottom);
    }];
    
    [self.captureSendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.snapButton.mas_centerX);
        make.centerY.equalTo(self.snapButton.mas_centerY);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.snapButton.mas_centerX);
        make.bottom.equalTo(self.snapButton.mas_top).with.offset(-40);
    }];
}

#pragma mark - 拍照相关
- (void)takePhotos:(UITapGestureRecognizer *)tapGestureRecognizer {
    @weakify(self)
    [self.camera capturePhoto:^(ALCamera *camera, UIImage *image, UIDeviceOrientation shootingOrientation, NSError *error) {
        @strongify(self)
        if(!error) {
            [self previewPhotoWithImage:image shootingOrientation:shootingOrientation];
        } else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)previewPhotoWithImage:(UIImage *)image shootingOrientation:(UIDeviceOrientation)shootingOrientation {
    UIImage *finalImage = nil;
    self.imagePreview = [[UIImageView alloc] init];
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat height = is_iPhoneX ? SCREEN_HEIGHT - 146 : SCREEN_HEIGHT;
    [self.imagePreview setFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    UIImageOrientation orientation = UIImageOrientationRight;
    // lz 19.4.3 modify image rotating 
    // start
    switch (shootingOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIImageOrientationLeft;
            break;

        case UIDeviceOrientationPortrait:
            orientation = UIImageOrientationRight;
            break;
    
        case UIDeviceOrientationLandscapeRight:
            orientation = UIImageOrientationDown;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIImageOrientationUp;
            break;
            
        default:
            orientation = UIImageOrientationRight;
            break;
    }
    
    if (self.camera.position == ALCameraPositionFront) {
//        if (shootingOrientation == UIDeviceOrientationLandscapeLeft) {
//            orientation = UIImageOrientationDownMirrored;
//        }else if(shootingOrientation == UIDeviceOrientationLandscapeRight) {
//            orientation = UIImageOrientationUpMirrored;
//        }
        switch (shootingOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                orientation = UIImageOrientationDownMirrored;
                break;
            
            case UIDeviceOrientationLandscapeRight:
                orientation = UIImageOrientationUpMirrored;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                orientation = UIImageOrientationLeftMirrored;
                break;
                
            case UIDeviceOrientationPortrait:
                orientation = UIImageOrientationRightMirrored;
                break;
                
            default:
                break;
        }
    }
    UIImage *rotatingImage = [UIImage imageWithCGImage:image.CGImage
                                    scale:image.scale
                              orientation:orientation];
    finalImage = [rotatingImage al_fixOrientation];
    // end
    
    
//    float videoRatio = finalImage.size.width / finalImage.size.height; //得到的图片 高/宽
//    if (shootingOrientation == UIDeviceOrientationLandscapeRight || shootingOrientation == UIDeviceOrientationLandscapeLeft)
//    {
//        CGFloat height = SCREEN_WIDTH * videoRatio;
//        CGFloat y = (SCREEN_HEIGHT - height) / 2;
//        [self.imagePreview setFrame:CGRectMake(0, y, SCREEN_WIDTH, height)];
//    }
//    else
//    {
//        [self.imagePreview setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * videoRatio)];
//    }
    
    self.imagePreview.image = finalImage;

    self.photoPreviewContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.photoPreviewContainerView.backgroundColor = [UIColor blackColor];
    
    [self.photoPreviewContainerView addSubview:self.imagePreview];
    [self.view addSubview:self.photoPreviewContainerView];
    self.imagePreview.center = self.view.center;
    [self setUpViewsAfterPhotoCapture];
}

- (void)setUpViewsAfterPhotoCapture {
    [self.view bringSubviewToFront:self.photoPreviewContainerView];
    [self.view bringSubviewToFront:self.captureSendBtn];
    [self.view bringSubviewToFront:self.captureBackBtn];
    
    self.switchButton.hidden = YES;
    self.snapButton.hidden = YES;
    self.dissMissBtn.hidden = YES;
    
    self.captureSendBtn.hidden = NO;
    self.captureBackBtn.hidden = NO;
}

- (void)setupBtnAfterCancleCapture {
    [self.view bringSubviewToFront:self.switchButton];
    [self.view bringSubviewToFront:self.snapButton];
    [self.view bringSubviewToFront:self.dissMissBtn];
    
    self.switchButton.hidden = NO;
    self.snapButton.hidden = NO;
    self.dissMissBtn.hidden = NO;
    
    self.captureSendBtn.hidden = YES;
    self.captureBackBtn.hidden = YES;
    
    if (self.imagePreview) {
        [self.imagePreview removeFromSuperview];
        [self.photoPreviewContainerView removeFromSuperview];
        self.imagePreview = nil;
        self.photoPreviewContainerView = nil;
    }
    
    if (self.videoPreviewContainerView) {
        [self.videoPlayer pause];
        self.videoPlayer = nil;
        self.playerItem = nil;
        [self.videoPlayerLayer removeFromSuperlayer];
        self.videoPlayerLayer = nil;
        self.snapButton.progressPercentage = 0.0f;
        [self.videoPreviewContainerView removeFromSuperview];
        self.videoPreviewContainerView = nil;
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.videoFilePath] error:nil];
    }
    
    [self.camera startUpdateAccelerometer];
}

#pragma mark - 录制视频相关
- (void)longPressSnapButtonFunc:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self startVideoRecorder];
            break;
        case UIGestureRecognizerStateCancelled:
            [self stopVideoRecorder];
            break;
        case UIGestureRecognizerStateEnded:
            [self stopVideoRecorder];
            break;
        case UIGestureRecognizerStateFailed:
            [self stopVideoRecorder];
            break;
        default:
            break;
    }
}

- (void)startVideoRecorder {
    self.timeLength = 0;
    self.switchButton.hidden = YES;
    self.dissMissBtn.hidden = YES;
    _isShooting = YES;
    [self.snapButton startShootAnimationWithDuration:kStarVideoDuration];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kStarVideoDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.camera startVideoRecording];
        [weakSelf timerFired];
    });
}

- (void)stopVideoRecorder {
    if (!_isShooting) return;
    
    _isShooting = NO;
    self.snapButton.progressPercentage = 0.0f;
    [self.snapButton stopShootAnimation];
    [self timerStop];
    self.switchButton.hidden = NO;
    self.dissMissBtn.hidden = NO;
    self.camera.recording = NO;
    [self.camera stopVideoRecording];
}

- (void)timerFired {
    self.timeLength = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timerRecord) userInfo:nil repeats:YES];
}

- (void)timerRecord {
    if (!_isShooting) {
        [self timerStop];
        return ;
    }
    
    // 时间大于kVideoMaxTime则停止录制
    if (self.timeLength >= kVideoMaxTime) {
        [self stopVideoRecorder];
        return;
    }
    
    self.timeLength += 0.01;
    self.snapButton.progressPercentage = self.timeLength / 10;
    
}

- (void)timerStop {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)previewVideoAfterShootWithUrl:(NSString *)url {
    self.videoFilePath = url;
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:url]];
    
    //获取视频总时长
    float duration = CMTimeGetSeconds(asset.duration);
    self.duration = [NSString stringWithFormat:@"%d",(int)duration];
    // 初始化AVPlayer
    self.videoPreviewContainerView = [[UIView alloc] init];
    self.videoPreviewContainerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.videoPreviewContainerView.backgroundColor = [UIColor blackColor];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    self.videoPlayerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.videoPreviewContainerView.layer addSublayer:self.videoPlayerLayer];
    
    [self.view addSubview:self.videoPreviewContainerView];
    [self.view bringSubviewToFront:self.videoPreviewContainerView];
    [self.view bringSubviewToFront:self.captureBackBtn];
    [self.view bringSubviewToFront:self.captureSendBtn];
    
    // 重复播放预览视频
    [self addNotificationWithPlayerItem];
    
    [self setUpViewsAfterPhotoCapture];
    [self.videoPlayer play];
}

- (NSString *)createVideoShotImageFileName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    
    NSString *imageName = [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg",destDateString];
    return imageName;
}

- (NSString *)createVideoShotImageFilePath {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    destDateString = [destDateString stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/VideoShot_%@.jpg",self.videoFoldPath,destDateString];
    
    return imageFilePath;
}

#pragma mark - 预览视频通知
- (void)addNotificationWithPlayerItem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)removePlayerItemNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playVideoFinished:(NSNotification *)notification {
    //    NSLog(@"视频播放完成.");
    
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [self.videoPlayer seekToTime:CMTimeMake(0, 1)];
    [self.videoPlayer play];
}


#pragma mark - 发送
- (void)sendBtnClick {
    
    if (self.imagePreview.image) {
        [TSImageHandler saveImageToAlbum:self.imagePreview.image];
        if (self.sendPhotoBlock) {
            self.sendPhotoBlock(self.imagePreview.image);
        }
    }
    
    if (self.videoPreviewContainerView) {
        NSData *imageData = UIImageJPEGRepresentation(self.thumbnailVideoImage, 0.5);
        self.videoThumbIMGName = [self createVideoShotImageFileName];
        NSString *thumbImgFilePath = [self.videoFoldPath stringByAppendingPathComponent:self.videoThumbIMGName];
        [imageData writeToFile:thumbImgFilePath atomically:YES];
        
        NSMutableDictionary *measureInfo = [NSMutableDictionary dictionary];
        [measureInfo setObject:@(self.thumbnailVideoImage.size.width) forKey:@"width"];
        [measureInfo setObject:@(self.thumbnailVideoImage.size.height) forKey:@"height"];
        [TSImageHandler saveVideoToSystemAlbum:self.videoFilePath showTip:NO];
        if (self.sendVideoBlock) {
            self.sendVideoBlock(self.videoFilePath, self.videoFileName, thumbImgFilePath, self.videoThumbIMGName,measureInfo,self.duration);
        }

    }
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ALCameraDelegate
- (void)alCamera:(ALCamera *)camera didFinishVideoRecordWithFilePath:(NSString *)videoFilePath videoFileName:(NSString *)videoFileName shotImage:(UIImage *)shotImage {
    if (self.timeLength < kVideoMinTime) {
        //录制时间过短删除本地文件
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:videoFilePath] error:nil];
        NSLog(@"录制时间过短%f",self.timeLength);
        [self.camera startUpdateAccelerometer];
        return;
    }
    
    self.videoFileName = videoFileName;
    self.thumbnailVideoImage = [shotImage al_scaleToHeight:500];
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf previewVideoAfterShootWithUrl:videoFilePath];
    });
    
}

#pragma mark - 提示语动画
- (void)tipLabelAnimation {
    [self.view bringSubviewToFront:self.tipLabel];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:1.0f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [weakSelf.tipLabel setAlpha:1];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f delay:3.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [weakSelf.tipLabel setAlpha:0];
        } completion:nil];
    }];
}

#pragma mark - getter
- (ALCamera *)camera {
    if (!_camera) {
        _camera = [[ALCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                           position:ALCameraPositionRear
                                       videoEnabled:YES];
        _camera.videoFoldPath = self.videoFoldPath;
        _camera.delegate = self;
    }
    return _camera;
}

- (UIButton *)dissMissBtn {
    if (!_dissMissBtn) {
        _dissMissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dissMissBtn setImage:[UIImage imageNamed:@"close_camera"] forState:UIControlStateNormal];
        @weakify(self)
        [[_dissMissBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        }];

    }
    return _dissMissBtn;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:[UIImage imageNamed:@"camera_conversion"] forState:UIControlStateNormal];
        @weakify(self)
        [[_switchButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.camera togglePosition];
        }];
    }
    return _switchButton;;
}


- (UIButton *)captureSendBtn {
    if (!_captureSendBtn) {
        _captureSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _captureSendBtn.hidden = YES;
        [_captureSendBtn setImage:[UIImage imageNamed:@"camera_send"] forState:UIControlStateNormal];
        [_captureSendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureSendBtn;
}

- (UIButton *)captureBackBtn {
    if (!_captureBackBtn) {
        _captureBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureBackBtn setImage:[UIImage imageNamed:@"close_camera"] forState:UIControlStateNormal];
        _captureBackBtn.hidden = YES;
        @weakify(self)
        [[_captureBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self setupBtnAfterCancleCapture];
        }];

    }
    return _captureBackBtn;
}

- (ALCameraSnapButton *)snapButton {
    if (!_snapButton) {
        ALCameraSnapButton *snapButton = [ALCameraSnapButton defaultSnapButton];
        CGFloat cameraBtnX = (SCREEN_WIDTH - snapButton.bounds.size.width) / 2;
        
        CGFloat bottomHeight = is_iPhoneX ? 73 : 0;
        
        CGFloat cameraBtnY = SCREEN_HEIGHT - snapButton.bounds.size.height - 35 - bottomHeight;    //距离底部60
        snapButton.frame = CGRectMake(cameraBtnX, cameraBtnY, snapButton.bounds.size.width, snapButton.bounds.size.height);
        snapButton.progressPercentage = 0;
        
        // 设置拍照按钮点击事件
        __weak typeof(self) weakSelf = self;
        // 配置拍照方法
        [snapButton configureTapSnapButtonEventWithBlock:^(UITapGestureRecognizer *tapGesture) {
            [weakSelf takePhotos:tapGesture];
        }];
        
        // 配置拍摄方法
        [snapButton configureLongPressSnapButtonEventWithBlock:^(UILongPressGestureRecognizer *longPressGesture) {
            [weakSelf longPressSnapButtonFunc:longPressGesture];
        }];
        
        _snapButton = snapButton;
    }
    return _snapButton;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel constructLabel:CGRectZero
                                       text:@"点击拍照  按住摄像"
                                       font:[UIFont ALFontSize13]
                                  textColor:[UIColor whiteColor]];
        _tipLabel.alpha = 0;
    }
    return _tipLabel;
}

@end
