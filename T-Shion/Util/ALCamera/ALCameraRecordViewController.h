//
//  ALCameraRecordViewController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/14.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^ALCameraSendPhotoBlock) (UIImage *image);


/**
 发送视频回调

 @param videoFilePath 视频文件本地路径
 @param videoFileName 视频文件本地名
 @param thumbImgFilePath 视频第一帧本地文件路径
 @param thumbImgFileName 视频第一帧本地文件名
 @param measureInfo 视频宽高值
 */
typedef void (^ALCameraSendVideoBlock) (NSString *videoFilePath,NSString *videoFileName,NSString *thumbImgFilePath,NSString *thumbImgFileName,NSDictionary *measureInfo,NSString *duration);

@interface ALCameraRecordViewController : UIViewController

- (instancetype)initWithVideoFoldPath:(NSString *)videoFoldPath;

@property (nonatomic, copy) ALCameraSendPhotoBlock sendPhotoBlock;
@property (nonatomic, copy) ALCameraSendVideoBlock sendVideoBlock;

@end

