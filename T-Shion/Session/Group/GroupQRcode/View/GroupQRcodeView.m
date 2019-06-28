//
//  GroupQRcodeView.m
//  AilloTest
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "GroupQRcodeView.h"

@implementation GroupQRcodeView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (GroupQRcodeViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.backView];
    [self addSubview:self.icon];
    [self addSubview:self.name];
    [self addSubview:self.qrcode];
    [self addSubview:self.details];
}

- (void)layoutSubviews {
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top).with.offset(15);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-30, 450));
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(60, 60));
        make.left.top.equalTo(self.backView).with.offset(20);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.centerY.equalTo(self.icon);
        make.height.offset(20);
        make.right.equalTo(self.backView.mas_right).with.offset(-10);
    }];
    
    [self.qrcode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView);
        make.top.equalTo(self.icon.mas_bottom).with.offset(35);
        make.size.mas_offset(CGSizeMake(265, 265));
    }];
    
    [self.details mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-50, 30));
        make.top.equalTo(self.qrcode.mas_bottom).with.offset(25);
        make.centerX.equalTo(self.backView);
    }];
    
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.getQrcodeCommand execute:@{@"roomId":self.viewModel.group.roomId}];
    [self.viewModel.refreshQrcodeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        UIImage *image = (UIImage *)x;
        if (image) {
            self.qrcode.image = image;
        }
    }];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 5;
        _backView.layer.masksToBounds = YES;
    }
    return _backView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.backgroundColor = RGB(238, 238, 238);
        _icon.clipsToBounds = YES;
        _icon.layer.cornerRadius = 30;
        _icon.image = [UIImage imageNamed:@"Group_Deafult_Avatar"];
        
        NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:self.viewModel.group.roomId];
        
        [TShionSingleCase loadingGroupAvatarWithImageView:_icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:self.viewModel.group.avatar] filePath:imagePath];
        
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        [_name setFont:[UIFont fontWithName:@"PingFang-SC-Bold" size:18]];
        _name.text = self.viewModel.group.name;
    }
    return _name;
}

- (UIImageView *)qrcode {
    if (!_qrcode) {
        _qrcode = [[UIImageView alloc] init];
        _qrcode.backgroundColor = [UIColor whiteColor];
    }
    return _qrcode;
}

- (UILabel *)details {
    if (!_details) {
        _details = [[UILabel alloc] init];
        _details.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
        _details.textAlignment = NSTextAlignmentCenter;
        _details.text = Localized(@"group_qrcode_tips");
    }
    return _details;
}
@end
