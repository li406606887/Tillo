//
//  QRCodeViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "QRCodeViewController.h"
#import "ZXingObjC.h"

@interface QRCodeViewController ()

@property (nonatomic, strong) UIView *whiteBgView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *sexFlagView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIImageView *codeView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *saveBtn;


@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"UserInfo_QRCode_Title");
    [self setRightNavigation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.saveBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}

- (void)addChildView {
    [self.view addSubview:self.whiteBgView];
    [self.whiteBgView addSubview:self.avatarView];
    [self.whiteBgView addSubview:self.nameLabel];
    [self.whiteBgView addSubview:self.sexFlagView];
    [self.whiteBgView addSubview:self.addressLabel];
    [self.whiteBgView addSubview:self.codeView];
    [self.whiteBgView addSubview:self.tipLabel];
    [self initQRCodeImage];
}

- (void)viewDidLayoutSubviews {
    [self.whiteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(15);
        make.top.equalTo(self.view.mas_top).with.offset(15);
        make.right.equalTo(self.view.mas_right).with.offset(-15);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whiteBgView.mas_left).with.offset(20);
        make.top.equalTo(self.whiteBgView.mas_top).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.avatarView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.right.lessThanOrEqualTo(self.whiteBgView.mas_right).with.offset(-20);
    }];
    
    [self.sexFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        make.left.equalTo(self.nameLabel.mas_right).with.offset(2).with.priorityHigh();
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.right.lessThanOrEqualTo(self.whiteBgView.mas_right).with.offset(-20);
    }];
    
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.whiteBgView.mas_centerX);
        make.top.equalTo(self.avatarView.mas_bottom).with.offset(35);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 110, SCREEN_WIDTH - 110));
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whiteBgView.mas_left);
        make.right.equalTo(self.whiteBgView.mas_right);
        make.top.equalTo(self.codeView.mas_bottom);
        make.height.mas_equalTo(70);
        make.bottom.equalTo(self.whiteBgView.mas_bottom);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)initQRCodeImage {
    NSString *data = [SocketViewModel shared].userModel.ID;
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.margin = @(0);
    ZXBitMatrix *result = [writer encode:data
                                  format:kBarcodeFormatQRCode
                                   width:SCREEN_WIDTH
                                  height:SCREEN_WIDTH
                                   hints:hints
                                   error:nil];
    
    if (result) {
        ZXImage *image = [ZXImage imageWithMatrix:result];
        self.codeView.image = [UIImage imageWithCGImage:image.cgimage];
    }
}

- (void)saveImage {
 UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.whiteBgView.frame.size.width,self.whiteBgView.frame.size.height ), NO, 0.0);
    [self.whiteBgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    ShowWinMessage(Localized(@"UserInfo_QRCode_Success"));
}

#pragma mark - getter
- (UIView *)whiteBgView {
    if (!_whiteBgView) {
        _whiteBgView = [[UIView alloc] init];
        _whiteBgView.backgroundColor = [UIColor whiteColor];
        _whiteBgView.layer.masksToBounds = YES;
        _whiteBgView.layer.cornerRadius = 5;
    }
    return _whiteBgView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 30;
        
        NSString *imagePath = [TShionSingleCase myThumbAvatarImgPath];
        
        [TShionSingleCase loadingAvatarWithImageView:_avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:[SocketViewModel shared].userModel.avatar] filePath:imagePath];
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:[SocketViewModel shared].userModel.name
                                        font:[UIFont ALBoldFontSize18]
                                   textColor:[UIColor ALTextDarkColor]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UIImageView *)sexFlagView {
    if (!_sexFlagView) {
        NSString *sexIcon = [SocketViewModel shared].userModel.sex == 0 ? @"setting_sex_man" : @"setting_sex_woman";
        _sexFlagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:sexIcon]];
    }
    return _sexFlagView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [UILabel constructLabel:CGRectZero
                                           text:nil
                                           font:[UIFont ALFontSize12]
                                      textColor:[UIColor ALTextGrayColor]];
        _addressLabel.textAlignment = NSTextAlignmentLeft;
        
        UserInfoModel *model = [SocketViewModel shared].userModel;
        
        NSString *addressStr;
        
        NSString *region = model.region.length ? model.region : @"";
        
        if (!region.length) {
            addressStr = [NSString stringWithFormat:@"%@:%@",Localized(@"UserInfo_Address"),Localized(@"UserInfo_Unknow")];
        } else {
            addressStr = [NSString stringWithFormat:@"%@: %@",Localized(@"UserInfo_Address"),region];
        }
        _addressLabel.text = addressStr;
        
    }
    return _addressLabel;
}

- (UIImageView *)codeView {
    if (!_codeView) {
        _codeView = [[UIImageView alloc] init];
        _codeView.backgroundColor = [UIColor ALGrayBgColor];
    }
    return _codeView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel constructLabel:CGRectZero
                                       text:Localized(@"UserInfo_QRCode_Tip")
                                       font:[UIFont ALFontSize12]
                                  textColor:[UIColor ALTextGrayColor]];
    }
    return _tipLabel;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveBtn.frame = CGRectMake(0, 0, 80, 28);
        _saveBtn.layer.masksToBounds = YES;
        _saveBtn.layer.cornerRadius = 14;
        
        [_saveBtn setTitle:Localized(@"UserInfo_QRCode_Save") forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont ALFontSize15];
        
        [_saveBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_saveBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_saveBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        @weakify(self)
        [[_saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            
            [self saveImage];
            
        }];
    }
    return _saveBtn;
}

@end
