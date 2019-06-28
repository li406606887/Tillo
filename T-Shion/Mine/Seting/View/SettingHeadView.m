//
//  SettingHeadView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SettingHeadView.h"
#import "UIView+BorderLine.h"
#import "NSString+Storage.h"

@interface SettingHeadView ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *sexFlagView;
@property (nonatomic, strong) UILabel *accountLabel;

@property (nonatomic, strong) UIView *infoBgView;

@property (nonatomic, strong) UIButton *codeBtn;

@property (strong, nonatomic) UIImage *defaultImage;




@end

@implementation SettingHeadView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.borderLineColor = [UIColor ALLineColor].CGColor;
    self.borderLineStyle = BorderLineStyleBottom;
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.infoBgView];
    [self.infoBgView addSubview:self.avatarView];
    [self.infoBgView addSubview:self.nameLabel];
    [self.infoBgView addSubview:self.sexFlagView];
    [self.infoBgView addSubview:self.accountLabel];
    
    [self addSubview:self.codeBtn];
    
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ModifyHeadIcon" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [TShionSingleCase loadingAvatarWithImageView:self.avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:[SocketViewModel shared].userModel.avatar] filePath:[TShionSingleCase myThumbAvatarImgPath]];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ModifySex" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSString *sexIcon = [SocketViewModel shared].userModel.sex == 0 ? @"setting_sex_man" : @"setting_sex_woman";
        self.sexFlagView.image = [UIImage imageNamed:sexIcon];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ModifyName" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.nameLabel.text = [SocketViewModel shared].userModel.name;
    }];
}

- (void)setupConstraints {
    
    [self.infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(100);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.infoBgView.mas_bottom).with.offset(-30);
        make.left.equalTo(self.infoBgView.mas_left).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.avatarView.mas_centerY).with.offset(-5);
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.right.lessThanOrEqualTo(self.infoBgView.mas_right).with.offset(-20);
    }];
    
    [self.sexFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        make.left.equalTo(self.nameLabel.mas_right).with.offset(2).with.priorityHigh();
    }];
    
    [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.lessThanOrEqualTo(self.infoBgView.mas_right).with.offset(-20);
        make.top.equalTo(self.avatarView.mas_centerY).with.offset(5);
    }];
    
    [self.codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-20);
        make.top.equalTo(self.mas_top).with.offset(is_iPhoneX ? 50 : 20);
    }];
}


- (void)gotoUserInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldGotoUserInfo)]) {
        [self.delegate shouldGotoUserInfo];
    }
}

#pragma mark - getter
- (UIView *)infoBgView {
    if (!_infoBgView) {
        _infoBgView = [[UIView alloc] init];
        _infoBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoUserInfo)];
        [_infoBgView addGestureRecognizer:tapGesture];
    }
    return _infoBgView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 30;
        _avatarView.backgroundColor = [UIColor ALLineColor];
        
        [TShionSingleCase loadingAvatarWithImageView:_avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:[SocketViewModel shared].userModel.avatar] filePath:[TShionSingleCase myThumbAvatarImgPath]];
    
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:[SocketViewModel shared].userModel.name
                                        font:[UIFont ALBoldFontSize20]
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

- (UILabel *)accountLabel {
    if (!_accountLabel) {
        _accountLabel = [UILabel constructLabel:CGRectZero
                                           text:[NSString stringWithFormat:@"%@:%@",Localized(@"UserInfo_Account"),[SocketViewModel shared].userModel.mobile]
                                           font:[UIFont ALFontSize14]
                                      textColor:[UIColor ALTextGrayColor]];
        _accountLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _accountLabel;
}

- (UIButton *)codeBtn {
    if (!_codeBtn) {
        _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_codeBtn setImage:[UIImage imageNamed:@"setting_QRCode"] forState:UIControlStateNormal];
        
        @weakify(self)
        [[_codeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(didQRCodeButtonClick)]) {
                [self.delegate didQRCodeButtonClick];
            }
        }];
    }
    return _codeBtn;
}


@end
