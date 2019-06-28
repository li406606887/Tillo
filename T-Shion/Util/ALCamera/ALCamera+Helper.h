//
//  ALCamera+Helper.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALCamera.h"

@interface ALCamera (Helper)

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports;

- (UIImage *)al_cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;


- (NSString *)createVideoFilePath;

- (NSString *)createFileNamePrefix;


@end
