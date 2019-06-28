//
//  InviteMemberView.m
//  T-Shion
//
//  Created by together on 2019/4/20.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "InviteMemberView.h"

@implementation InviteMemberView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addchildView];
    }
    return self;
}

- (void)addchildView {
    [self addSubview:self.icon];
    [self addSubview:self.name];
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(self.width, self.width));
        make.top.centerX.equalTo(self);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.size.mas_offset(CGSizeMake(self.width, 20));
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
        _icon.clipsToBounds = YES;
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textAlignment = NSTextAlignmentCenter;
    }
    return _name;
}
@end
