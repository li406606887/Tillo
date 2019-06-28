//
//  UIImageView+YMAnimatedImageView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/5/25.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (YMAnimatedImageView)

- (void)ym_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDInternalCompletionBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
