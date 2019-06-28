//
//  PhotoBrowseCell.h
//  BGH-family
//
//  Created by Sunny on 17/2/24.
//  Copyright © 2017年 Zontonec. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FLAnimatedImage/FLAnimatedImage.h>
@class PhotoBrowseView, PhotoBrowseModel;

@interface PhotoBrowseCell : UICollectionViewCell

@property (nonatomic, copy) void (^singleTapGestureBlock)(void);

@property (nonatomic, strong) PhotoBrowseView *browseView;

@property (nonatomic, strong) PhotoBrowseModel *model;

- (void)recoverSubviews;

@end


@interface PhotoBrowseView : UIView

@property (nonatomic, strong) SDAnimatedImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;

@property (nonatomic, strong) PhotoBrowseModel *model;

@property (nonatomic, copy) void (^singleTapGestureBlock)(void);

- (void)recoverSubviews;

@end
