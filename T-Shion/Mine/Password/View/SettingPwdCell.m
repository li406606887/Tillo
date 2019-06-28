//
//  SettingPwdCell.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingPwdCell.h"

NSString *const SettingPwdCellReuseIdentifier = @"SettingPwdCell";

@interface SettingPwdCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *contentField;

@end


@implementation SettingPwdCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentField];
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(120);
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:nil
                                         font:[UIFont systemFontOfSize:15]
                                    textColor:[UIColor ALTextDarkColor]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UITextField *)contentField {
    if (!_contentField) {
        _contentField = [[UITextField alloc] init];
        _contentField.secureTextEntry = YES;
        _contentField.font = [UIFont systemFontOfSize:14];
        _contentField.clearButtonMode = UITextFieldViewModeWhileEditing;
        @weakify(self);
        [_contentField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(settingPwdCell:didContentChange:)]) {
                [self.delegate settingPwdCell:self didContentChange:x];
            }
        }];
    }
    return _contentField;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _contentField.placeholder = placeholder;
}

- (void)setContent:(NSString *)content {
    _content = content;
    _contentField.text = content;
}


@end
