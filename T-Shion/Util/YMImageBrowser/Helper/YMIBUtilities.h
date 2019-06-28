//
//  YMIBUtilities.h
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define YMIB_STATUSBAR_ORIENTATION    [UIApplication sharedApplication].statusBarOrientation

#define YMIMAGEBROWSER_HEIGHT       ((YMIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortrait || YMIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

#define YMIMAGEBROWSER_WIDTH        ((YMIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortrait || YMIB_STATUSBAR_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)

#define YMIB_GET_QUEUE_ASYNC(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_async(queue, block);\
}

#define YMIB_GET_QUEUE_MAIN_ASYNC(block) YMIB_GET_QUEUE_ASYNC(dispatch_get_main_queue(), block)

#define YMIB_IS_IPHONEX           [YMIBUtilities isIphoneX]
#define YMIB_HEIGHT_EXTRABOTTOM   (YMIB_IS_IPHONEX ? 34.0 : 0)
#define YMIB_HEIGHT_STATUSBAR     (YMIB_IS_IPHONEX ? 44.0 : 20.0)

BOOL YMIBLowMemory(void);

UIWindow * _Nonnull YMIBGetNormalWindow(void);

UIViewController * _Nullable YMIBGetTopController(void);


NS_ASSUME_NONNULL_BEGIN

@interface YMIBUtilities : NSObject

+ (BOOL)isIphoneX;

@end

NS_ASSUME_NONNULL_END
