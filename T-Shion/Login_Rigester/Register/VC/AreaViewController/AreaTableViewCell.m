//
//  AreaTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/4/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AreaTableViewCell.h"

@implementation AreaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setupViews {
    [self addSubview:self.countryName];
    [self addSubview:self.countryCode];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints {
    [self.countryName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(200, 20));
    }];
    
    [self.countryCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(100, 20));
    }];
    [super updateConstraints];
}

- (UILabel *)countryName {
    if (!_countryName) {
        _countryName = [[UILabel alloc] init];
        _countryName.font = [UIFont ALFontSize15];
        _countryName.textColor = [UIColor ALTextDarkColor];
    }
    return _countryName;
}

- (UILabel *)countryCode {
    if (!_countryCode) {
        _countryCode = [[UILabel alloc] init];
        _countryCode.font = [UIFont ALFontSize15];
        _countryCode.textColor = [UIColor ALTextDarkColor];
        _countryCode.textAlignment = NSTextAlignmentRight;
    }
    return _countryCode;
}
@end
