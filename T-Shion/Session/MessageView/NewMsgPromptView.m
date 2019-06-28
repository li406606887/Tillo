//
//  NewMsgPromptView.m
//  AilloTest
//
//  Created by together on 2019/5/30.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "NewMsgPromptView.h"

@interface NewMsgPromptView ()
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIView *line;
@property (assign, nonatomic) CGFloat width;
@end

@implementation NewMsgPromptView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.line];
    [self addSubview:self.contentLabel];
}

- (void)layoutSubviews {
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.superview);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-40, 1));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.superview);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(self.width, 36));
    }];
}

- (CGSize)bubbleSize {
    return CGSizeMake(SCREEN_WIDTH-30, 36);
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:14];
        _contentLabel.textColor = RGB(153, 153, 153);
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.backgroundColor = RGB(246, 246, 246);
        NSString *string = Localized(@"new_msg_prompt");
        if ([string isEqualToString:@"以下是新消息"]) {
            self.width = 100;
        }else {
            self.width = 100;
        }
        _contentLabel.text = string;
    }
    return _contentLabel;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = RGB(222, 222, 222);
    }
    return _line;
}
@end
