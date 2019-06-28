//
//  TSButton.m
//  T-Shion
//
//  Created by together on 2018/9/18.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSButton.h"

@implementation TSButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.icon];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect rect = self.frame;
    CGFloat height = rect.size.height-30 ;
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(height, height));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.height.offset(25);
        make.right.equalTo(self.mas_right);
    }];
    [super layoutSubviews];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.masksToBounds = YES;
    }
    return _icon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}
@end
