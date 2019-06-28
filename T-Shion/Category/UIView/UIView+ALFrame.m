//
//  UIView+ALFrame.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "UIView+ALFrame.h"

@implementation UIView (ALFrame)

- (CGFloat)al_x {
    return self.frame.origin.x;
}

- (void)setAl_x:(CGFloat)al_x {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = al_x;
    self.frame        = newFrame;
}

- (CGFloat)al_y {
    return self.frame.origin.y;
}

- (void)setAl_y:(CGFloat)al_y {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = al_y;
    self.frame        = newFrame;
}

- (CGFloat)al_width {
    return CGRectGetWidth(self.bounds);
}

- (void)setAl_width:(CGFloat)al_width {
    CGRect newFrame     = self.frame;
    newFrame.size.width = al_width;
    self.frame          = newFrame;
}

- (CGFloat)al_height {
    return CGRectGetHeight(self.bounds);
}

- (void)setAl_height:(CGFloat)al_height {
    CGRect newFrame      = self.frame;
    newFrame.size.height = al_height;
    self.frame           = newFrame;
}

- (CGFloat)al_top {
    return self.frame.origin.y;
}

- (void)setAl_top:(CGFloat)al_top {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = al_top;
    self.frame        = newFrame;
}

- (CGFloat)al_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setAl_bottom:(CGFloat)al_bottom {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = al_bottom - self.frame.size.height;
    self.frame        = newFrame;
}

- (CGFloat)al_left {
    return self.frame.origin.x;
}

- (void)setAl_left:(CGFloat)al_left {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = al_left;
    self.frame        = newFrame;
}

- (CGFloat)al_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setAl_right:(CGFloat)al_right {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = al_right - self.frame.size.width;
    self.frame        = newFrame;
}

- (CGFloat)al_centerX {
    return self.center.x;
}

- (void)setAl_centerX:(CGFloat)al_centerX {
    CGPoint newCenter = self.center;
    newCenter.x       = al_centerX;
    self.center       = newCenter;
}

- (CGFloat)al_centerY {
    return self.center.y;
}

- (void)setAl_centerY:(CGFloat)al_centerY {
    CGPoint newCenter = self.center;
    newCenter.y       = al_centerY;
    self.center       = newCenter;
}

- (CGPoint)al_origin {
    return self.frame.origin;
}

- (void)setAl_origin:(CGPoint)al_origin {
    CGRect newFrame = self.frame;
    newFrame.origin = al_origin;
    self.frame      = newFrame;
}

- (CGSize)al_size {
    return self.frame.size;
}

- (void)setAl_size:(CGSize)al_size {
    CGRect newFrame = self.frame;
    newFrame.size   = al_size;
    self.frame      = newFrame;
}


@end
