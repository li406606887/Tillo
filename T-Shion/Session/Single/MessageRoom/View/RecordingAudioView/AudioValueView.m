//
//  AudioValueView.m
//  AilloTest
//
//  Created by together on 2019/4/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "AudioValueView.h"

#define MaxHeight 30
#define MinHeight 2

@interface AudioValueView()

@end

@implementation AudioValueView
- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.valueArray = array;
        self.style = YES;
        [self addSubview:self.timerLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).with.offset(-25);
        make.size.mas_offset(CGSizeMake(100, 20));
    }];
    [super layoutSubviews];
}

- (void)setStyle:(BOOL)style {
    _style = style;
    self.backgroundColor = style == YES ? [UIColor whiteColor]:RGB(255, 99, 121);
    self.timerLabel.textColor = style == YES ? RGB(84, 208, 172):[UIColor whiteColor];
    [self setNeedsDisplay];
}

- (void)setValueArray:(NSArray *)valueArray {
    _valueArray = valueArray;
    [self setNeedsDisplay];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

*/

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.textColor = RGB(84, 208, 172);
        _timerLabel.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:15];
        _timerLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timerLabel;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIColor *color = self.style == YES ? RGB(84, 208, 172):[UIColor whiteColor];
    [color set];
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    bezier.lineWidth = 4.0;
    bezier.lineCapStyle = kCGLineCapRound; //线条拐角
    bezier.lineJoinStyle = kCGLineJoinRound; //终点处理
    for (int i= 0 ; i<22; i++) {
        int value = [self.valueArray[i] intValue];
        int x = 25+i*7;
        [bezier moveToPoint:CGPointMake(x, 25-value)];
        [bezier addLineToPoint:CGPointMake(x , 25+value)];
    }
    [bezier stroke];
}
@end
