//
//  UIView+ALFrame.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (ALFrame)

@property (nonatomic) CGFloat al_x;
@property (nonatomic) CGFloat al_y;
@property (nonatomic) CGFloat al_width;
@property (nonatomic) CGFloat al_height;

@property (nonatomic) CGFloat al_top;
@property (nonatomic) CGFloat al_bottom;
@property (nonatomic) CGFloat al_left;
@property (nonatomic) CGFloat al_right;

@property (nonatomic) CGFloat al_centerX;
@property (nonatomic) CGFloat al_centerY;

@property (nonatomic) CGPoint al_origin;
@property (nonatomic) CGSize  al_size;

@end

