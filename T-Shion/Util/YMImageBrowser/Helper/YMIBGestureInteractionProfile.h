//
//  YMIBGestureInteractionProfile.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMIBGestureInteractionProfile : NSObject

@property (nonatomic, assign) BOOL disable;

@property (nonatomic, assign) CGFloat dismissScale;

@property (nonatomic, assign) CGFloat dismissVelocityY;

@property (nonatomic, assign) CGFloat restoreDuration;

@property (nonatomic, assign) CGFloat triggerDistance;

@property (nonatomic, assign) BOOL isPreviewType;//取消单击消失

@end

NS_ASSUME_NONNULL_END
