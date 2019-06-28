//
//  CryptGroupListTableViewCell.m
//  AilloTest
//
//  Created by mac on 2019/5/30.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "CryptGroupListTableViewCell.h"

@interface CryptGroupListTableViewCell ()

@property (nonatomic, strong) UIImageView *lockView;

@end

@implementation CryptGroupListTableViewCell

- (void)setGroupModel:(GroupModel *)groupModel {
    [super setGroupModel:groupModel];
    self.lockView.hidden = NO;
}

- (UIImageView*)lockView {
    if (!_lockView) {
        _lockView = [[UIImageView alloc] init];
        _lockView.image = [UIImage imageNamed:@"crypt_lock"];
        _lockView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_lockView];
    }
    return _lockView;
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [self.lockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.centerY.equalTo(self.name.mas_centerY);
        make.size.mas_offset(CGSizeMake(20, 15));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lockView.mas_right).with.offset(5);
        make.centerY.equalTo(self.icon);
        make.right.equalTo(self.contentView);
        make.height.offset(18);
    }];
    
    [self.segLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(.5);
    }];
}

@end
