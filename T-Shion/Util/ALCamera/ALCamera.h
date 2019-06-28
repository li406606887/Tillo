//
//  ALCamera.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ALCamera;

//前后置
typedef enum : NSUInteger {
    ALCameraPositionRear,
    ALCameraPositionFront
} ALCameraPosition;

//闪光灯
typedef enum : NSUInteger {
    // 默认off
    ALCameraFlashOff,
    ALCameraFlashOn,
    ALCameraFlashAuto
} ALCameraFlash;

//镜像
typedef enum : NSUInteger {
    // 默认off
    ALCameraMirrorOff,
    ALCameraMirrorOn,
    ALCameraMirrorAuto
} ALCameraMirror;


extern NSString *const ALCameraErrorDomain;
typedef enum : NSUInteger {
    ALCameraErrorCodeCameraPermission = 10,
    ALCameraErrorCodeMicrophonePermission = 11,
    ALCameraErrorCodeSession = 12,
    ALCameraErrorCodeVideoNotEnabled = 13
} ALCameraErrorCode;


typedef void (^CapturePhotoBlock) (ALCamera *camera, UIImage *image, UIDeviceOrientation shootingOrientation, NSError *error);

typedef void (^RecordVideoCompletionBlock) (ALCamera *camera, NSURL *outputFileUrl, NSError *error);


@protocol ALCameraDelegate <NSObject>

@optional

/**
 小视频录制完成

 @param camera 相机
 @param videoFilePath 视频文件路径
 @param videoFileName 视频文件名
 @param shotImage 第一帧图片
 */
- (void)alCamera:(ALCamera *)camera didFinishVideoRecordWithFilePath:(NSString *)videoFilePath videoFileName:(NSString *)videoFileName shotImage:(UIImage *)shotImage;

@end

@interface ALCamera : UIViewController

@property (nonatomic, weak) id <ALCameraDelegate> delegate;

/**
 视频存放文件夹路径
 */
@property (nonatomic, copy) NSString *videoFoldPath;

/**
 视频文件名称
 */
@property (nonatomic, copy) NSString *videoFileName;

/**
 视频第一帧文件名
 */
@property (nonatomic, copy) NSString *videoThumbImgName;


/**
 拍照质量
 */
@property (nonatomic, copy) NSString *cameraQuality;

/**
 相机镜像模式
 */
@property (nonatomic) ALCameraMirror mirrorMode;

/**
 前后置
 */
@property (nonatomic) ALCameraPosition position;

/**
 闪光灯模式
 */
@property (nonatomic, readonly) ALCameraFlash flashMode;


/**
 白平衡:默认 AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
 */
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**
 是否允许录像
 */
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/**
 是否允许缩放
 */
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

/**
 是否处于录制中
 */
@property (nonatomic, getter=isRecording) BOOL recording;

/**
 缩放最大比例
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 点击聚焦：默认 YES
 */
@property (nonatomic) BOOL tapToFocus;



@property (nonatomic, copy) void (^onError)(ALCamera *camera, NSError *error);


#pragma mark - Public method

- (instancetype)initWithQuality:(NSString *)quality
                       position:(ALCameraPosition)position
                   videoEnabled:(BOOL)videoEnabled;

- (void)attachToViewController:(UIViewController *)viewController frame:(CGRect)frame;

- (void)start;

- (void)stop;

- (ALCameraPosition)togglePosition;

- (void)startVideoRecording;

- (void)stopVideoRecording ;

/**
 *  开始监听屏幕方向
 */
- (void)startUpdateAccelerometer;

/**
 *  停止监听屏幕方向
 */
- (void)stopUpdateAccelerometer;

/**
 拍摄照片

 @param onCapture 回调
 @param exactSeenImage 是否精确适配频幕尺寸
 */
- (void)capturePhoto:(CapturePhotoBlock)onCapture exactSeenImage:(BOOL)exactSeenImage;

#pragma mark - 类方法
/**
 获取相机权限

 @param completionBlock 权限回调
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**
 获取麦克风权限

 @param completionBlock 权限回调
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

@end

