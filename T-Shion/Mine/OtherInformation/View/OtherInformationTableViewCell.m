//
//  OhterInformationTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "OtherInformationTableViewCell.h"

@implementation OtherInformationFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupViews {
    [self addSubview:self.title];
    [self addSubview:self.nickName];
    [self addSubview:self.line];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(200, 20));
    }];
    
    [self.nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).with.offset(-30);
        make.size.mas_offset(CGSizeMake(200, 20));
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 0.5));
    }];
    [super updateConstraints];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont ALFontSize16];
        _title.textColor = [UIColor ALTextDarkColor];;
    }
    return _title;
}

- (UITextField *)nickName {
    if (!_nickName) {
        _nickName = [[UITextField alloc] init];
        _nickName.textAlignment = NSTextAlignmentRight;
        _nickName.font = [UIFont ALFontSize14];
        _nickName.textColor = [UIColor ALTextGrayColor];
    }
    return _nickName;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [_line setBackgroundColor:[UIColor ALLineColor]];
    }
    return _line;
}
@end

@implementation OtherInformationNormalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViews {
    [self addSubview:self.title];
    [self addSubview:self.line];
//    self.backgroundColor = DEFAULT_COLOR;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(200, 20));
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 0.5));
    }];
    [super updateConstraints];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont ALFontSize16];
        _title.textColor = HEXCOLOR(0xFF6379);
    }
    return _title;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [_line setBackgroundColor:[UIColor ALLineColor]];
    }
    return _line;
}
@end


@implementation OtherInformationSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupViews {
//    self.backgroundColor = DEFAULT_COLOR;
    [self addSubview:self.title];
    [self addSubview:self.switchBtn];
    [self addSubview:self.line];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(200, 20));
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.size.mas_offset(CGSizeMake(49.0f, 31.0f));
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 0.5));
    }];
    [super updateConstraints];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont ALFontSize16];
        _title.textColor = [UIColor ALTextDarkColor];
    }
    return _title;
}

- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc] init];
        _switchBtn.onTintColor = RGB(84, 208, 172);
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        _switchBtn.tintColor =  HEXCOLOR(0xDDDDDD);
        _switchBtn.layer.masksToBounds = YES;
        _switchBtn.layer.cornerRadius = 15.5;
        _switchBtn.backgroundColor = HEXCOLOR(0xDDDDDD);
        @weakify(self)
        [[_switchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.switchBlock) {
                self.switchBlock(self.switchBtn.on);
            }
        }];
    }
    return _switchBtn;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [_line setBackgroundColor:[UIColor ALLineColor]];
    }
    return _line;
}
@end


@implementation OtherInformationHeadTableViewCell

- (void)setupViews {
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.headBack];
    [self.contentView addSubview:self.line];
    [self.contentView addSubview:self.headIcon];
}

- (void)layoutSubviews {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(100, 20));
    }];
    
    [self.headBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView).with.offset(15);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 0.5));
    }];
    
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-5);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(18, 18));
    }];
    
    [super layoutSubviews];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont ALFontSize16];
        _title.textColor = [UIColor ALTextDarkColor];
    }
    return _title;
}

- (UIImageView *)headBack {
    if (!_headBack) {
        _headBack = [[UIImageView alloc] init];
        _headBack.layer.cornerRadius = 20;
        _headBack.layer.masksToBounds = YES;
        _headBack.image = [UIImage imageNamed:@"Avatar_Deafult"];
        _headBack.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.isGroupOwner) {
                [self chooseSendImage];
            } else {
                if (self.clickHeadBlock) {
                    self.clickHeadBlock(self.headBack.image);
                }
            }
        }];
        [_headBack addGestureRecognizer:tap];
    }
    return _headBack;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        [_line setBackgroundColor:[UIColor ALLineColor]];
    }
    return _line;
}

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
    }
    return _headIcon;
}


#pragma mark - 选择头像
- (void)chooseSendImage {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancle setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    
    UIAlertAction * camera = [UIAlertAction actionWithTitle:Localized(@"PhotoPicker_Camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseType:1];
    }];
    [camera setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    
    UIAlertAction * picture = [UIAlertAction actionWithTitle:Localized(@"PhotoPicker_Library") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseType:0];
    }];
    [picture setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    
    [alert addAction:cancle];
    [alert addAction:picture];
    [alert addAction:camera];
    [[MBProgressHUD getCurrentWindowVC] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 相机代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(info[UIImagePickerControllerOriginalImage], self, nil, nil);
    }
    [[MBProgressHUD getCurrentWindowVC] dismissViewControllerAnimated:YES completion:nil];
    self.headBack.image = image;
    if (self.headBlock) {
        self.headBlock(image);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)chooseType:(int)index {
    UIImagePickerController * pickerImage = [[UIImagePickerController alloc]init];
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    if (index == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    [[MBProgressHUD getCurrentWindowVC] presentViewController:pickerImage animated:YES completion:nil];
}


@end
