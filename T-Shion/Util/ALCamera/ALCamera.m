//
//  ALCamera.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALCamera.h"
#import "ALCamera+Helper.h"
#import <ImageIO/CGImageProperties.h>
#import <CoreMotion/CoreMotion.h>

@interface ALCamera ()<UIGestureRecognizerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *videoCaptureDevice;
@property (nonatomic, strong) AVCaptureDevice *audioCaptureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

//视频录制相关
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) NSDictionary *videoCompressionSettings;//视频属性
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;//音频属性

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;//视频输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;//音频输出

@property (nonatomic, assign) BOOL canWrite;
@property (nonatomic, copy) NSString *videoFilePath;//视频存放路径


//聚焦和捏合手势相关
@property (nonatomic, strong) UIImageView *focusBoxView;
@property (nonatomic, assign) BOOL isFocusing;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;//捏合动作
@property (nonatomic, assign) CGFloat beginGestureScale;//记录开始的缩放比例
@property (nonatomic, assign) CGFloat effectiveScale;//最后的缩放比例

@property (nonatomic, assign) UIDeviceOrientation shootingOrientation;//拍摄中的手机方向
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

NSString *const ALCameraErrorDomain = @"ALCameraErrorDomain";

@implementation ALCamera

#pragma mark - 初始化
- (instancetype)init {
    return [self initWithVideoEnabled:NO];
}

- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled {
    return [self initWithQuality:AVCaptureSessionPresetHigh
                        position:ALCameraPositionRear
                    videoEnabled:videoEnabled];
}

- (instancetype)initWithQuality:(NSString *)quality
                       position:(ALCameraPosition)position
                   videoEnabled:(BOOL)videoEnabled {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setupWithQuality:quality
                      position:position
                  videoEnabled:videoEnabled];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupWithQuality:AVCaptureSessionPresetHigh
                      position:ALCameraPositionRear
                  videoEnabled:YES];
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.preview];
    [self.view addSubview:self.focusBoxView];
}

- (void)viewWillLayoutSubviews {
    CGRect bounds = self.preview.bounds;
    self.captureVideoPreviewLayer.bounds = bounds;
    self.captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [super viewWillLayoutSubviews];
}

- (void)dealloc {
    [self stop];
}

#pragma mark - public method
- (void)start {
    [ALCamera requestCameraPermission:^(BOOL granted) {
        if (!granted) {
            NSError *error = [NSError errorWithDomain:ALCameraErrorDomain
                                                 code:ALCameraErrorCodeCameraPermission
                                             userInfo:nil];
            [self passError:error];
            return;
        }
    
        if (self.videoEnabled) {
            [ALCamera requestMicrophonePermission:^(BOOL granted) {
                if (granted) {
                    [self initialize];
                } else {
                    NSError *error = [NSError errorWithDomain:ALCameraErrorDomain
                                                         code:ALCameraErrorCodeMicrophonePermission
                                                     userInfo:nil];
                    [self passError:error];
                }
            }];
            
        } else {
            [self initialize];
        }
    }];
}

- (void)stop {
    [self.session stopRunning];
    self.session = nil;
}

- (void)capturePhoto:(CapturePhotoBlock)onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock {
    [self stopUpdateAccelerometer];
    if (!_session) {
        NSError *error = [NSError errorWithDomain:ALCameraErrorDomain
                                             code:ALCameraErrorCodeSession
                                         userInfo:nil];
        onCapture(self, nil, self.shootingOrientation, error);
        return;
    }
    
    AVCaptureConnection *pictureConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    BOOL flashActive = self.videoCaptureDevice.flashActive;
    if (!flashActive && animationBlock) {
        animationBlock(self.captureVideoPreviewLayer);
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:pictureConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        UIImage *image = nil;
        NSDictionary *metadata = nil;
        
        if (imageDataSampleBuffer != NULL) {
            CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
            if (exifAttachments) {
                metadata = (__bridge NSDictionary*)exifAttachments;
            }
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            image = [[UIImage alloc] initWithData:imageData];
            
            if(exactSeenImage) {
                image = [self al_cropImage:image usingPreviewLayer:self.captureVideoPreviewLayer];
            }
        }
        
        if(onCapture) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onCapture(self, image, self.shootingOrientation, error);
            });
        }
    }];
}

- (void)capturePhoto:(CapturePhotoBlock)onCapture exactSeenImage:(BOOL)exactSeenImage {
    [self capturePhoto:onCapture exactSeenImage:exactSeenImage animationBlock:^(AVCaptureVideoPreviewLayer *layer) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = 0.1;
        animation.autoreverses = YES;
        animation.repeatCount = 0.0;
        animation.fromValue = [NSNumber numberWithFloat:1.0];
        animation.toValue = [NSNumber numberWithFloat:0.1];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [layer addAnimation:animation forKey:@"animateOpacity"];
    }];
}

- (void)capturePhoto:(CapturePhotoBlock)onCapture {
    [self capturePhoto:onCapture exactSeenImage:NO];
}

- (ALCameraPosition)togglePosition {
    if (!_session) {
        return self.position;
    }
    
    if (self.position == ALCameraPositionRear) {
        self.cameraPosition = ALCameraPositionFront;
    } else {
        self.cameraPosition = ALCameraPositionRear;
    }
    
    return self.position;
}

- (void)attachToViewController:(UIViewController *)viewController frame:(CGRect)frame {
    [viewController addChildViewController:self];
    self.view.frame = frame;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
}

#pragma mark - 视频录制
- (void)startVideoRecording {
    [self stopUpdateAccelerometer];
    if (!_videoEnabled) {
        NSError *error = [NSError errorWithDomain:ALCameraErrorDomain
                                             code:ALCameraErrorCodeVideoNotEnabled
                                         userInfo:nil];
        [self passError:error];
        
        return;
    }
    self.assetWriter = nil;
    
    self.videoFilePath = [self createVideoFilePath];
    
    if ([self.assetWriter canAddInput:self.assetWriterVideoInput])
    {
        [_assetWriter addInput:self.assetWriterVideoInput];
    }
    
    if ([self.assetWriter canAddInput:self.assetWriterAudioInput])
    {
        [_assetWriter addInput:self.assetWriterAudioInput];
    }
    
    _canWrite = NO;
    _recording = YES;
}

- (void)stopVideoRecording {

    if (!self.videoEnabled) {
        return;
    }
    
    self.recording = NO;
    __weak __typeof(self)weakSelf = self;
    if(_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting)
    {
        [_assetWriter finishWritingWithCompletionHandler:^{
            weakSelf.canWrite = NO;
            weakSelf.assetWriter = nil;
            weakSelf.assetWriterAudioInput = nil;
            weakSelf.assetWriterVideoInput = nil;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(alCamera:didFinishVideoRecordWithFilePath:videoFileName:shotImage:)]) {
                
                UIImage *thumbnailImg = [weakSelf thumbnailImageRequestWithVideoUrl:weakSelf.videoFilePath andTime:0.01];
                
                [weakSelf.delegate alCamera:weakSelf didFinishVideoRecordWithFilePath:weakSelf.videoFilePath videoFileName:self.videoFileName shotImage:thumbnailImg];
            }
        }];
    } else {
        
    }
}

- (UIImage *)thumbnailImageRequestWithVideoUrl:(NSString *)videoUrl andTime:(CGFloat)timeBySecond {
    if (!videoUrl) return nil;
    
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoUrl]];
    
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error = nil;
    CMTime requestTime = CMTimeMakeWithSeconds(timeBySecond, 10); //CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:requestTime actualTime:&actualTime error:&error];
    if(error)
    {
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@", error.localizedDescription);
        return nil;
    }
    
    CMTimeShow(actualTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    UIImage *finalImage = nil;
    
    BOOL isBack = self.position == ALCameraPositionRear;
    
    if (self.shootingOrientation == UIDeviceOrientationLandscapeRight)
    {
        finalImage = [image al_fixOrientation:isBack ? UIImageOrientationDown : UIImageOrientationUp];
    }
    else if (self.shootingOrientation == UIDeviceOrientationLandscapeLeft)
    {
        finalImage = [image al_fixOrientation:isBack ? UIImageOrientationUp : UIImageOrientationDown];
    }
    else if (self.shootingOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        
        finalImage = [image al_fixOrientation:isBack ? UIImageOrientationLeft : UIImageOrientationRight];
    }
    else
    {
        finalImage = [image al_fixOrientation:isBack ? UIImageOrientationRight : UIImageOrientationLeft];
    }
    
    return finalImage;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate and AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {
    
    @autoreleasepool {
        
        if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
            @synchronized(self)
            {
                if (self.isRecording)
                {
                    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
                }
            }
        }
        
        //音频
        if (connection == [self.audioOutput connectionWithMediaType:AVMediaTypeAudio])
        {
            @synchronized(self)
            {
                if (self.isRecording)
                {
                    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
                }
            }
        }
    };
}

/**
 *  写入数据
 */
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType {
    if (sampleBuffer == NULL) {
        NSLog(@"empty sampleBuffer");
        return;
    }
    
    @autoreleasepool {
        if (!self.canWrite && mediaType == AVMediaTypeVideo)
        {
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            self.canWrite = YES;
        }
        
        //写入视频数据
        if (mediaType == AVMediaTypeVideo)
        {
            if (self.assetWriterVideoInput.readyForMoreMediaData)
            {
                BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                if (!success)
                {
                    @synchronized (self)
                    {
                        [self stopVideoRecording];
                    }
                }
            }
        }
        
        //写入音频数据
        if (mediaType == AVMediaTypeAudio)
        {
            if (self.assetWriterAudioInput.readyForMoreMediaData)
            {
                BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                if (!success)
                {
                    @synchronized (self)
                    {
                        [self stopVideoRecording];
                    }
                }
            }
        }
    };
    
}

#pragma mark - private method

/**
 初始化相机参数

 @param quality 相片质量
 @param position 前后置
 @param videoEnabled 是否允许录制视频
 */
- (void)setupWithQuality:(NSString *)quality
                position:(ALCameraPosition)position
            videoEnabled:(BOOL)videoEnabled {
    _cameraQuality = quality;
    _position = position;
    _videoEnabled = videoEnabled;
    
    _tapToFocus = YES;
    
    _flashMode = ALCameraFlashOff;
    _mirrorMode = ALCameraMirrorOn;
    
    _recording = NO;
    _zoomingEnabled = YES;
    _effectiveScale = 1.0f;
}

- (void)initialize {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = self.cameraQuality;
        
        // preview layer
        CGRect bounds = self.preview.layer.bounds;
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _captureVideoPreviewLayer.bounds = bounds;
        _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        [self.preview.layer addSublayer:_captureVideoPreviewLayer];
        
        AVCaptureDevicePosition devicePosition;
        
        switch (self.position) {
            case ALCameraPositionRear:
                if([self.class isRearCameraAvailable]) {
                    devicePosition = AVCaptureDevicePositionBack;
                } else {
                    devicePosition = AVCaptureDevicePositionFront;
                    _position = ALCameraPositionRear;
                }
                break;
                
            case ALCameraPositionFront:
                if( [self.class isFrontCameraAvailable] ) {
                    devicePosition = AVCaptureDevicePositionFront;
                } else {
                    devicePosition = AVCaptureDevicePositionBack;
                    _position = ALCameraPositionRear;
                }
                break;
                
            default:
                devicePosition = AVCaptureDevicePositionUnspecified;
                break;
        }
        
        if (devicePosition == AVCaptureDevicePositionUnspecified) {
            self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        } else {
            self.videoCaptureDevice = [self cameraWithPosition:devicePosition];
        }
        
        NSError *error = nil;
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoCaptureDevice error:&error];
        
        if (!_videoDeviceInput) {
            [self passError:error];
            return;
        }
        
        if ([self.session canAddInput:_videoDeviceInput]) {
            [self.session  addInput:_videoDeviceInput];
        }
        
        //如果允许录制视频
        if (self.videoEnabled) {
            _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioCaptureDevice error:&error];
            if (!_audioDeviceInput) {
                [self passError:error];
            }
            
            if ([self.session canAddInput:_audioDeviceInput]) {
                [self.session addInput:_audioDeviceInput];
            }
            
            if ([self.session canAddOutput:self.videoOutput]) {
                [self.session addOutput:self.videoOutput];
            }
            
            if ([self.session canAddOutput:self.audioOutput]) {
                [self.session addOutput:self.audioOutput];
            }
            
        }
        
        self.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        [self.session addOutput:self.stillImageOutput];
    }
    
    if (![self.captureVideoPreviewLayer.connection isEnabled]) {
        [self.captureVideoPreviewLayer.connection setEnabled:YES];
    }
    
    [self.session startRunning];
    [self startUpdateAccelerometer];
}

- (void)passError:(NSError *)error {
    if (self.onError) {
        __weak typeof(self) weakSelf = self;
        self.onError(weakSelf, error);
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) return device;
    }
    return nil;
}

//设置手电筒
- (void)enableTorch:(BOOL)enabled {
    if( [self isTorchAvailable] ) {
        AVCaptureTorchMode torchMode = enabled ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        NSError *error;
        if ([self.videoCaptureDevice lockForConfiguration:&error]) {
            [self.videoCaptureDevice setTorchMode:torchMode];
            [self.videoCaptureDevice unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

//手电筒是否可用
- (BOOL)isTorchAvailable {
    return self.videoCaptureDevice.hasTorch && self.videoCaptureDevice.isTorchAvailable;
}


#pragma mark - 重力感应相关
/**
 *  开始监听屏幕方向
 */
- (void)startUpdateAccelerometer {
    if (![self.motionManager isAccelerometerAvailable]) return;
    
    //回调会一直调用,建议获取到就调用下面的停止方法，需要再重新开始，当然如果需求是实时不间断的话可以等离开页面之后再stop
    [self.motionManager setAccelerometerUpdateInterval:1.0];
    __weak typeof(self) weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        double x = accelerometerData.acceleration.x;
        double y = accelerometerData.acceleration.y;
        if ((fabs(y) + 0.1f) >= fabs(x))
        {

            if (y >= 0.1f)
            {
                NSLog(@"Down");
                weakSelf.shootingOrientation = UIDeviceOrientationPortraitUpsideDown;
            }
            else
            {
                // Portrait
                NSLog(@"Portrait");
                weakSelf.shootingOrientation = UIDeviceOrientationPortrait;
            }
        }
        else
        {
            if (x >= 0.1f)
            {
                NSLog(@"Right");
                weakSelf.shootingOrientation = UIDeviceOrientationLandscapeRight;
            }
            else if (x <= 0.1f)
            {
                NSLog(@"Left");
                weakSelf.shootingOrientation = UIDeviceOrientationLandscapeLeft;
            }
            else
            {
                NSLog(@"Portrait");
                weakSelf.shootingOrientation = UIDeviceOrientationPortrait;
            }
        }
    }];
}

/**
 *  停止监听屏幕方向
 */
- (void)stopUpdateAccelerometer {
    if ([self.motionManager isAccelerometerActive] == YES)
    {
        [self.motionManager stopAccelerometerUpdates];
        _motionManager = nil;
    }
}

#pragma mark - 聚焦
- (void)previewTapped:(UIGestureRecognizer *)gestureRecognizer {
    if (!_tapToFocus) return;
    
//    if (self.recording) return;
    
    CGPoint touchedPoint = [gestureRecognizer locationInView:self.preview];
    
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:touchedPoint
                                                                   previewLayer:self.captureVideoPreviewLayer
                                                                          ports:self.videoDeviceInput.ports];
    [self focusAtPoint:pointOfInterest];
    [self showFocusBox:touchedPoint];
}

//聚焦
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = self.videoCaptureDevice;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

//显示聚焦框
- (void)showFocusBox:(CGPoint)point {
    self.isFocusing = YES;
    self.focusBoxView.center = point;
    self.focusBoxView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusBoxView.alpha = 1;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.focusBoxView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        weakSelf.focusBoxView.alpha = 0;
        weakSelf.isFocusing = NO;
    }];
}

#pragma mark - 捏合手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.preview];
        CGPoint convertedLocation = [self.preview.layer convertPoint:location fromLayer:self.view.layer];
        if ( ![self.preview.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        if (_effectiveScale < 1.0f)
            _effectiveScale = 1.0f;
        if (_effectiveScale > self.videoCaptureDevice.activeFormat.videoMaxZoomFactor)
            _effectiveScale = self.videoCaptureDevice.activeFormat.videoMaxZoomFactor;
        NSError *error = nil;
        if ([self.videoCaptureDevice lockForConfiguration:&error]) {
            [self.videoCaptureDevice rampToVideoZoomFactor:_effectiveScale withRate:100];
            [self.videoCaptureDevice unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
//        if (self.isRecording) {
//            return NO;
//        }
    }
    return YES;
}

#pragma mark - 类方法
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock {
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    } else {
        completionBlock(YES);
    }
}

+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock {
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    }
}

+ (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL)isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

#pragma mark - getter
- (UIView *)preview {
    if (!_preview) {
        
        CGFloat height = is_iPhoneX ? SCREEN_HEIGHT - 146 : SCREEN_HEIGHT;
        _preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
        _preview.centerY = self.view.centerY;
        _preview.backgroundColor = [UIColor clearColor];
        [_preview addGestureRecognizer:self.tapGesture];
        if (_zoomingEnabled) {
            [_preview addGestureRecognizer:self.pinchGesture];
        }
    }
    return _preview;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
        _tapGesture.numberOfTouchesRequired = 1;
        [_tapGesture setDelaysTouchesEnded:NO];
    }
    return _tapGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        _pinchGesture.delegate = self;
    }
    return _pinchGesture;
}

- (AVCaptureStillImageOutput *)stillImageOutput {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
    }
    return _stillImageOutput;
}

- (UIImageView *)focusBoxView {
    if (!_focusBoxView) {
        _focusBoxView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_focus"]];
        _focusBoxView.alpha = 0;
    }
    return _focusBoxView;
}

- (dispatch_queue_t)videoQueue {
    if (!_videoQueue) {
        _videoQueue = dispatch_queue_create("com.ALCamera.video", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueue;
}

- (AVAssetWriter *)assetWriter {
    if (!_assetWriter) {
        _assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:self.videoFilePath] fileType:AVFileTypeMPEG4 error:nil];
    }
    return _assetWriter;
}

- (NSDictionary *)videoCompressionSettings {
    if (!_videoCompressionSettings) {
        //写入视频大小
        NSInteger numPixels = SCREEN_WIDTH * SCREEN_HEIGHT;
        
        //每像素比特
        CGFloat bitsPerPixel = 8;
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        
        // 码率和帧率设置
        NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                                 AVVideoExpectedSourceFrameRateKey : @(15),
                                                 AVVideoMaxKeyFrameIntervalKey : @(15),
                                                 AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
        
        
        //注意视频的尺寸是手机横屏
        CGFloat width = SCREEN_HEIGHT;
        CGFloat height = SCREEN_WIDTH;
        
        if (is_iPhoneX){
            width = SCREEN_HEIGHT - 146;
        }
        
        _videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                       AVVideoWidthKey : @(width *2),
                                      AVVideoHeightKey : @(height *2),
                                 AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                       AVVideoCompressionPropertiesKey : compressionProperties };
        
        
    }
    return _videoCompressionSettings;
}

- (AVAssetWriterInput *)assetWriterVideoInput {
    if (!_assetWriterVideoInput) {
        _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
        
        //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
        _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        CGAffineTransform transform;
        BOOL isFront = _position == ALCameraPositionFront;
        switch (self.shootingOrientation) {
            case UIDeviceOrientationLandscapeRight:
                NSLog(@"--------右");
                transform = CGAffineTransformMakeRotation(isFront ? 0 : M_PI);
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                NSLog(@"--------左");
                transform = CGAffineTransformMakeRotation(isFront ? M_PI : 0);
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                NSLog(@"--------下");
                transform = CGAffineTransformMakeRotation(isFront ? (M_PI / 2.0) : M_PI + (M_PI / 2.0));
                break;
        
                
            default:
                NSLog(@"--------上");
                transform = CGAffineTransformMakeRotation(isFront ? M_PI + (M_PI / 2.0) : M_PI / 2.0);
                
                break;
        }
        
        _assetWriterVideoInput.transform = transform;
        
    }
    return _assetWriterVideoInput;
}

- (NSDictionary *)audioCompressionSettings {
    if (!_audioCompressionSettings) {
        _audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                       AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                       AVNumberOfChannelsKey : @(1),
                                       AVSampleRateKey : @(22050) };
    }
    return _audioCompressionSettings;
}

- (AVAssetWriterInput *)assetWriterAudioInput {
    if (!_assetWriterAudioInput) {
        _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    }
    return _assetWriterAudioInput;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        //立即丢弃旧帧，节省内存，默认YES
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
    }
    return _videoOutput;
}

- (AVCaptureAudioDataOutput *)audioOutput {
    if (!_audioOutput) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.videoQueue];
    }
    return _audioOutput;
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

#pragma mark - setter
- (void)setCameraPosition:(ALCameraPosition)cameraPosition {
    if(_position == cameraPosition || !self.session) {
        return;
    }
    
    if(cameraPosition == ALCameraPositionRear && ![self.class isRearCameraAvailable]) {
        return;
    }
    
    if(cameraPosition == ALCameraPositionFront && ![self.class isFrontCameraAvailable]) {
        return;
    }
    
    [self.session beginConfiguration];
    
    // remove existing input
    [self.session removeInput:self.videoDeviceInput];
    
    // get new input
    AVCaptureDevice *device = nil;
    if(self.videoDeviceInput.device.position == AVCaptureDevicePositionBack) {
        device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    } else {
        device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    
    if(!device) {
        return;
    }
    
    // add input to session
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if(error) {
        [self passError:error];
        [self.session commitConfiguration];
        return;
    }
    
    _position = cameraPosition;
    
    [self.session addInput:videoInput];
    [self.session commitConfiguration];
    
    self.videoCaptureDevice = device;
    self.videoDeviceInput = videoInput;
    
    [self setMirrorMode:_mirrorMode];
}

- (void)setMirrorMode:(ALCameraMirror)mirrorMode {
    _mirrorMode = mirrorMode;
    
    if(!self.session) {
        return;
    }
    
    AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureConnection *pictureConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([videoConnection isVideoMirroringSupported]) {
        if (_position == ALCameraPositionRear) {
            [videoConnection setVideoMirrored:NO];
        } else {
            [videoConnection setVideoMirrored:YES];
        }
    }
    
    if ([pictureConnection isVideoMirroringSupported]) {
        if (_position == ALCameraPositionRear) {
            pictureConnection.videoMirrored = NO;
        } else {
            [pictureConnection setVideoMirrored:YES];
        }
    }
    
//    switch (mirrorMode) {
//        case ALCameraMirrorOff: {
//            if ([videoConnection isVideoMirroringSupported]) {
//                [videoConnection setVideoMirrored:NO];
//            }
//
//            if ([pictureConnection isVideoMirroringSupported]) {
//                [pictureConnection setVideoMirrored:NO];
//            }
//            break;
//        }
//
//            //这边注意处理镜像问题
//        case ALCameraMirrorOn: {
//            if ([videoConnection isVideoMirroringSupported]) {
//                if (_position == ALCameraPositionRear) {
//                    [videoConnection setVideoMirrored:NO];
//                } else {
//                    [videoConnection setVideoMirrored:YES];
//                }
//            }
//
//            if ([pictureConnection isVideoMirroringSupported]) {
//                if (_position == ALCameraPositionRear) {
//                    [pictureConnection setVideoMirrored:NO];
//                } else {
//                    [pictureConnection setVideoMirrored:YES];
//                }
//            }
//            break;
//        }
//
//        case ALCameraMirrorAuto: {
//            BOOL shouldMirror = (_position == ALCameraPositionFront);
//            if ([videoConnection isVideoMirroringSupported]) {
//                [videoConnection setVideoMirrored:shouldMirror];
//            }
//
//            if ([pictureConnection isVideoMirroringSupported]) {
//                [pictureConnection setVideoMirrored:shouldMirror];
//            }
//            break;
//        }
//    }

}


@end
