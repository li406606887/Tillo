//
//  FriendsValidationTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/3/30.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsValidationTableViewCell.h"

@implementation FriendsValidationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViews {
//    [self setBackgroundColor:DEFAULT_COLOR];
    
//    [self.contentView addSubview:self.backView];
    [self addSubview:self.headIcon];
    [self addSubview:self.name];
    [self addSubview:self.validationInfo];
    [self addSubview:self.agree];
    [self addSubview:self.segline];
//    [self.backView addSubview:self.phoneImage];
//    [self.backView addSubview:self.phoneLabel];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
//    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.agree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(70, 30));
    }];

    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIcon.mas_right).with.offset(15);
        make.right.equalTo(self.agree.mas_left).with.offset(5);
        make.bottom.equalTo(self.mas_centerY).with.offset(-2);
        
    }];
    
//    [self.phoneImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.headIcon.mas_right).with.offset(3);
//        make.top.equalTo(self.name.mas_bottom).with.offset(5);
//        make.size.mas_offset(CGSizeMake(18, 20));
//    }];
    
//    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.phoneImage.mas_right).with.offset(3);
//        make.centerY.equalTo(self.phoneImage);
//        make.size.mas_offset(CGSizeMake(120, 26));
//    }];
    
    [self.validationInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY).with.offset(2);
        make.left.right.equalTo(self.name);
    }];
    
    [self.segline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(.5);
    }];
    
    [super updateConstraints];
}

- (void)setModel:(FriendsModel *)model {
    _model = model;
    self.headIcon.image = nil;
    [self.headIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"Avatar_Deafult"]];
    self.name.text = model.name;
    self.phoneLabel.text = model.mobile;
    self.validationInfo.text = model.remark;
    
    NSString *string ;
    if (model.status == 0) {
        string = Localized(@"Agree");
        self.agree.userInteractionEnabled = YES;
        self.agree.selected = NO;
    } else if (model.status == 1) {
        string = Localized(@"Agreed");
        self.agree.userInteractionEnabled = NO;
        self.agree.selected = YES;
    }
    
    [self.agree setTitle:string forState:UIControlStateNormal];
}

#pragma mark 懒加载
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        [_backView setBackgroundColor:[UIColor whiteColor]];
    }
    return _backView;
}

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
//        _headIcon.contentMode = UIViewContentModeScaleAspectFit;
        _headIcon.layer.masksToBounds = YES;
        _headIcon.layer.cornerRadius = 25;
        _headIcon.layer.borderWidth = 1;
        _headIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _headIcon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        [_name setFont:[UIFont ALBoldFontSize17]];
        _name.textColor = [UIColor ALTextDarkColor];
    }
    return _name;
}

- (UILabel *)validationInfo {
    if (!_validationInfo) {
        _validationInfo = [[UILabel alloc] init];
        [_validationInfo setFont:[UIFont ALFontSize15]];
        _validationInfo.textColor = [UIColor ALTextGrayColor];
    }
    return _validationInfo;
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
        [_phoneLabel setFont:[UIFont systemFontOfSize:15]];
        _phoneLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _phoneLabel;
}

- (UIButton *)agree {
    if (!_agree) {
        _agree = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agree setTitle:Localized(@"Agree") forState:UIControlStateNormal];
        
        [_agree setTitleColor:[UIColor ALTextLightColor] forState:UIControlStateSelected];
        [_agree setTitle:Localized(@"Agreed") forState:UIControlStateSelected];
        
        [_agree setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_agree setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
        
        [_agree.titleLabel setFont:[UIFont ALFontSize15]];
        
        _agree.layer.masksToBounds = YES;
        _agree.layer.cornerRadius = 15;
        _agree.userInteractionEnabled = NO;
        
        @weakify(self)
        [[_agree rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            self.buttonClickBlock(self.model);
        }];
    }
    return _agree;
}

- (UIView *)segline {
    if (!_segline) {
        _segline = [[UIView alloc] init];
        _segline.backgroundColor = [UIColor ALLineColor];
    }
    return _segline;
}

@end
