//
//  MyInfoTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MyInfoTableViewCell.h"

@implementation MyInfoTableViewCell

- (void)setupViews {
    [self addSubview:self.title];
    [self addSubview:self.field];
}

- (void)layoutSubviews {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(100, 20));
    }];
    
    [self.field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-31);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(200, 20));
    }];
  
    [super layoutSubviews];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont ALBoldFontSize16];
        _title.textColor = [UIColor ALTextDarkColor];
    }
    return _title;
}

- (UILabel *)field {
    if (!_field) {
        _field = [[UILabel alloc] init];
        _field.font = [UIFont ALFontSize15];
        _field.textColor = [UIColor ALTextLightColor];
        _field.textAlignment = NSTextAlignmentRight;
    }
    return _field;
}

@end

@implementation MyInfoHeadViewCell

- (void)setupViews {
    [self addSubview:self.title];
    [self addSubview:self.headBack];
    [self.headBack addSubview:self.headIcon];
}

- (void)layoutSubviews {
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(100, 20));
    }];

    [self.headBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-31);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headBack);
    }];
    
    [super layoutSubviews];
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont ALBoldFontSize16];
        _title.textColor = [UIColor blackColor];
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
            [self chooseSendImage];
        }];
        [_headBack addGestureRecognizer:tap];
    }
    return _headBack;
}

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
        [_headIcon sd_setImageWithURL:[NSURL fileURLWithPath:[TShionSingleCase myThumbAvatarImgPath]] placeholderImage:nil options:SDWebImageRefreshCached];
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
