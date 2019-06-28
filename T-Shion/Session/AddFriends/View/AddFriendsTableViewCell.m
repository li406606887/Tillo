
//
//  AddFriendsTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/4/13.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddFriendsTableViewCell.h"

@implementation AddFriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViews {
    [self setBackgroundColor:DEFAULT_COLOR];
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.iconBack];
    [self.backView addSubview:self.headIcon];
    [self.backView addSubview:self.name];
    [self.backView addSubview:self.phoneImage];
    [self.backView addSubview:self.phoneLabel];
    [self.backView addSubview:self.agree];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(10, 15, 0, 15));
    }];
    [self.iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).with.offset(10);
        make.centerY.equalTo(self.backView);
        make.size.mas_offset(CGSizeMake(60, 60));
    }];
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).with.offset(10);
        make.centerY.equalTo(self.backView);
        make.size.mas_offset(CGSizeMake(60, 60));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIcon.mas_right).with.offset(5);
        make.top.equalTo(self.headIcon).with.offset(4);
        make.size.mas_offset(CGSizeMake(300, 22));
    }];
    
    [self.phoneImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIcon.mas_right).with.offset(3);
        make.top.equalTo(self.name.mas_bottom).with.offset(5);
        make.size.mas_offset(CGSizeMake(18, 20));
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.phoneImage.mas_right).with.offset(3);
        make.centerY.equalTo(self.phoneImage);
        make.size.mas_offset(CGSizeMake(120, 26));
    }];
    
    [self.agree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView.mas_right).with.offset(-5);
        make.centerY.equalTo(self.backView).with.offset(-5);
        make.size.mas_offset(CGSizeMake(60, 44));
    }];
    
    [super updateConstraints];
}

- (void)setModel:(AddFriendsModel *)model {
    _model = model;
    self.headIcon.image = nil;
    [self.headIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"Avatar_Deafult"]];
    self.name.text = model.name;
    if (model.roomId.length>1) {
        self.agree.hidden = YES;
    }else {
        self.agree.hidden = NO;
    }
    self.phoneLabel.text = model.mobile;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        _backView.layer.cornerRadius = 5;
        _backView.layer.shadowColor = RGB(65, 119, 255).CGColor;
        _backView.layer.shadowOffset = CGSizeMake(0, 0);
        _backView.layer.shadowOpacity = 0.1f;
        _backView.layer.shadowRadius = 5.0f;
    }
    return _backView;
}

- (UIView *)iconBack {
    if (!_iconBack) {
        _iconBack = [[UIView alloc] init];
        _iconBack.layer.borderWidth = 1;
        _iconBack.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconBack.layer.shadowColor = RGB(65, 119, 255).CGColor;
        _iconBack.layer.shadowOffset = CGSizeMake(0, 0);
        _iconBack.layer.shadowOpacity = 0.4f;
        _iconBack.layer.shadowRadius = 5.0f;
        _iconBack.layer.cornerRadius = 30;
    }
    return _iconBack;
}

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
        _headIcon.layer.borderWidth = 1;
        _headIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        _headIcon.layer.cornerRadius = 30;
        _headIcon.layer.masksToBounds = YES;
//        _headIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headIcon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        [_name setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    }
    return _name;
}

- (UIImageView *)phoneImage {
    if (!_phoneImage) {
        _phoneImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login_Phone"]];
        _phoneImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _phoneImage;
}

- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
        [_phoneLabel setTextColor:[UIColor lightGrayColor]];
        [_phoneLabel setFont:[UIFont systemFontOfSize:14]];
        _phoneLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _phoneLabel;
}

- (UIButton *)agree {
    if (!_agree) {
        _agree = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agree setTitle:@"添加" forState:UIControlStateNormal];
        [_agree setTitleColor:RGB(65,119,255) forState:UIControlStateNormal];
        [_agree.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [[_agree rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [FMDBManager creatMessageTableWithRoomId:self.model.roomId];
            self.buttonClickBlock(self.model);
        }];
    }
    return _agree;
}
@end
