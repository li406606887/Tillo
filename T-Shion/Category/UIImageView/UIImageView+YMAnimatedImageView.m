//
//  UIImageView+YMAnimatedImageView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/5/25.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "UIImageView+YMAnimatedImageView.h"

@implementation UIImageView (YMAnimatedImageView)

- (void)ym_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDInternalCompletionBlock)completedBlock {
    
    Class animatedImageClass = [SDAnimatedImage class];
    SDWebImageMutableContext *mutableContext;
    mutableContext = [NSMutableDictionary dictionary];
    mutableContext[SDWebImageContextAnimatedImageClass] = animatedImageClass;
    
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:nil
                            progress:progressBlock
                           completed:completedBlock];
}

@end
