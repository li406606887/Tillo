//
//  NavCenterTitleView.m
//  T-Shion
//
//  Created by together on 2018/12/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "NavCenterTitleView.h"

@interface NavCenterTitleView() 
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *arrowImageView;
@end

@implementation NavCenterTitleView
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        [self addSubview:self.titleLabel];
        [self addSubview:self.arrowImageView];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    CGSize size = [self getNavgationTitleSizeWithName:title];
    self.titleLabel.size = size;
    self.titleLabel.center = self.center;
    self.arrowImageView.x = self.titleLabel.x + size.width +5;
    self.arrowImageView.centerY = self.titleLabel.centerY;
}

- (void)isHiddenLogo:(BOOL)state {
    self.arrowImageView.hidden = YES;
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

- (CGSize )getNavgationTitleSizeWithName:(NSString *)name {
    CGSize size = [NSString getStringSizeWithString:name maxSize:CGSizeMake(MAXFLOAT, 18) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    if (size.width>140) {
        size.width = 140;
    }else {
        size.width += 10;
    }
    size.height = 30;
    return size;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        CGSize size = [self getNavgationTitleSizeWithName:self.title];
        _titleLabel.size = CGSizeMake(size.width+10, 30);
        _titleLabel.center = self.center;
        _titleLabel.text = self.title;
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Name_title_arrow"]];
        _arrowImageView.size = CGSizeMake(6, 7);
        _arrowImageView.x = self.titleLabel.x + self.titleLabel.width;
        _arrowImageView.centerY = self.titleLabel.centerY;
    }
    return _arrowImageView;
}

@end
