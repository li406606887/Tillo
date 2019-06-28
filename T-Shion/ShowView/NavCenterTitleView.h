//
//  NavCenterTitleView.h
//  T-Shion
//
//  Created by together on 2018/12/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NavCenterTitleView : UIView
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title;
@property (copy, nonatomic) NSString *title;
- (void)isHiddenLogo:(BOOL)state;
@end

