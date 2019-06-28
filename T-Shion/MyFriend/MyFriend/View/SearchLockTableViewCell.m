//
//  SearchLockTableViewCell.m
//  T-Shion
//
//  Created by together on 2019/5/8.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SearchLockTableViewCell.h"

@implementation SearchLockTableViewCell

- (void)setupViews {
    [self addSubview:self.avatar];
    [self addSubview:self.title];
    [self addSubview:self.lockIcon];
    [self addSubview:self.centerTitle];
    [self addSubview:self.describe];
    [self addSubview:self.line];
}

- (void)layoutSubviews {
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.lockIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(75);
        make.top.equalTo(self.avatar).with.offset(5);
        make.size.mas_offset(CGSizeMake(15, 18));
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lockIcon.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.top.equalTo(self.avatar).with.offset(5);
        make.height.mas_offset(20);
    }];
    
    [self.centerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.centerY.equalTo(self.avatar);
        make.height.mas_offset(20);
    }];
    
    [self.describe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).with.offset(5);
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.height.mas_offset(20);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-1);
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right);
        make.height.mas_offset(0.6);
    }];
    [super layoutSubviews];
}

- (void)setMsgArray:(NSArray *)msgArray {
    [super setMsgArray:msgArray];
}

- (UIImageView *)lockIcon {
    if (!_lockIcon) {
        _lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crypt_lock"]];
        _lockIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _lockIcon;
}
@end
