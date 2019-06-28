//
//  MessageImageView.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"
//#import <FLAnimatedImage/FLAnimatedImage.h>

@interface MessageImageView : MessageBaseView

@property (nonatomic) SDAnimatedImageView *imageView;
@property (nonatomic) UIActivityIndicatorView *downloadIndicatorView;
@property (nonatomic) UIActivityIndicatorView *uploadIndicatorView;
@property (copy, nonatomic) void (^lookBigImageBlock) (MessageModel *model, UIImageView *coverView);
@property (copy, nonatomic) void (^updateHeightBlock) (void);
@end
