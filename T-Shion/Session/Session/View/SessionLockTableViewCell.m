//
//  SessionLockTableViewCell.m
//  AilloTest
//
//  Created by together on 2019/4/29.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SessionLockTableViewCell.h"
#import "YYText.h"

@implementation SessionLockTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.messageNumber];
    [self.contentView addSubview:self.receivingTime];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.detailsMessage];
    [self.contentView addSubview:self.disturbView];
    [self.contentView addSubview:self.lockView];
    [self setupConstraints];
}


- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.lockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.centerY.equalTo(self.name.mas_centerY);
        make.size.mas_offset(CGSizeMake(20, 15));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lockView.mas_right).with.offset(5);
        make.bottom.equalTo(self.contentView.mas_centerY).with.offset(-2);
        make.right.equalTo(self.receivingTime.mas_left).with.offset(-5);
    }];
    
    [self.detailsMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).with.offset(8);
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.right.equalTo(self.disturbView.mas_left).with.offset(-10);
    }];
    
    [self.receivingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(self.name);
        make.width.mas_equalTo(72);
    }];
    
    [self.messageNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(self.detailsMessage);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    
    [self.disturbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.messageNumber.mas_left).with.offset(-5);
        make.centerY.equalTo(self.detailsMessage);
        make.size.mas_equalTo(CGSizeMake(10, 12));
    }];
    
   
}

- (void)setModel:(SessionModel *)model {
    [super setModel:model];
    if (model.isCrypt) {
        self.lockView.image = [UIImage imageNamed:@"crypt_lock"];
    }else {
        self.lockView.image = [UIImage imageNamed:@"Group_mark"];
    }
}

- (UIImageView *)lockView {
    if (!_lockView) {
        _lockView = [[UIImageView alloc] init];
        _lockView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _lockView;
}
@end
