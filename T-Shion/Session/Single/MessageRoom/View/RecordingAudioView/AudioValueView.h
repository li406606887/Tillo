//
//  AudioValueView.h
//  AilloTest
//
//  Created by together on 2019/4/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioValueView : UIView
@property (assign, nonatomic) BOOL style;//样式 1 正常显示 2 取消显示
@property (weak, nonatomic) NSArray *valueArray;
@property (strong, nonatomic) UILabel *timerLabel;
- (instancetype)initWithFrame:(CGRect)frame array:(NSArray*)array;
@end

NS_ASSUME_NONNULL_END
