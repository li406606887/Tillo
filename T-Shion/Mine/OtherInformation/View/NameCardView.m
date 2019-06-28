//
//  NameCardView.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/23.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "NameCardView.h"
#import "OtherInformationViewModel.h"

#import "YMImageBrowseCellData.h"
#import "YMImageBrowser.h"

@interface NameCardView ()

@property (strong , nonatomic) UIView *whiteBgView;

@property (strong , nonatomic) UILabel *phoneLabel;

@property (strong , nonatomic) UILabel *nameLabel;

@property (strong , nonatomic) UILabel *nickName;

@property (strong , nonatomic) UILabel *address;

@property (strong , nonatomic) UIImageView *avatarView;

@property (strong , nonatomic) UIImageView *sex;

@property (strong , nonatomic) UIButton *messageButton;

@property (strong , nonatomic) UIButton *videoButton;

@property (strong , nonatomic) UIButton *callButton;

@property (nonatomic, strong) UIView *segLine;

@property (strong , nonatomic) OtherInformationViewModel *viewModel;

@end

@implementation NameCardView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (OtherInformationViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

#pragma mark - private
- (void)setupViews {

    [self addSubview:self.avatarView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.nickName];
    [self addSubview:self.address];
    [self addSubview:self.phoneLabel];
    [self addSubview:self.messageButton];
    [self addSubview:self.videoButton];
    [self addSubview:self.callButton];
    [self addSubview:self.segLine];
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - system
- (void)layoutSubviews {

    [self.segLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15);
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.bottom.equalTo(self.mas_bottom).with.offset(-55);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.top.equalTo(self).with.offset(12.5);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.avatarView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).with.offset(15);
    }];
    
    [self.nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.nameLabel.mas_left);
    }];
    
    [self.address mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickName.mas_bottom).with.offset(10);
        make.left.equalTo(self.nameLabel.mas_left);
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.top.equalTo(self.segLine.mas_bottom);
        make.left.equalTo(self).with.offset(20.5);
    }];
    
    [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-20);
        make.centerY.equalTo(self.phoneLabel.mas_centerY);
    }];
    
    [self.callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoButton.mas_left).with.offset(-30);
        make.centerY.equalTo(self.phoneLabel.mas_centerY);
    }];
    
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.callButton.mas_left).with.offset(-30);
        make.centerY.equalTo(self.phoneLabel.mas_centerY);
    }];
    
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.refreshUISubject subscribeNext:^(id  _Nullable x) {
        FriendsModel *model = (FriendsModel *)x;
        @strongify(self)
        [self refreshUI:model];
    }];
}

- (void)refreshUI:(FriendsModel *)model {
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
    [TShionSingleCase loadingAvatarWithImageView:self.avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
    
    self.nameLabel.text = model.showName;
    NSString *dialCode = model.dialCode.length>0 ? [NSString stringWithFormat:@"+%@",model.dialCode]: @"";
    self.phoneLabel.text = [NSString stringWithFormat:@"%@  %@",dialCode,model.mobile];
    
    self.nickName.text = [NSString stringWithFormat:@"%@:%@",Localized(@"OthersInfo_NickName"),model.name];
    
    NSString *addressStr;
    
    NSString *region = model.region.length ? model.region : @"";
    NSString *country = model.country.length ? model.country : @"";
    
    if (!region.length && !country.length) {
        addressStr = [NSString stringWithFormat:@"%@:%@",Localized(@"UserInfo_Address"),Localized(@"UserInfo_Unknow")];
    } else {
        addressStr = [NSString stringWithFormat:@"%@:%@ %@",Localized(@"UserInfo_Address"),country,region];
    }
    
    _address.text = addressStr;
}

#pragma mark - 查看头像大图
- (void)showBigAvatar {
    YMImageBrowseCellData *browseCellData = [YMImageBrowseCellData new];
    
    NSString *originalAvatarPath = [TShionSingleCase originalAvatarImgPathWithUserId:self.viewModel.model.userId];
    
    NSString *thumAvatarPath = [TShionSingleCase thumbAvatarImgPathWithUserId:self.viewModel.model.userId];
    
    //先展示预览图
    if ([[NSFileManager defaultManager] fileExistsAtPath:originalAvatarPath]) {
        browseCellData.thumbImage = [UIImage imageWithContentsOfFile:originalAvatarPath];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:thumAvatarPath]) {
        browseCellData.thumbImage = [UIImage imageWithContentsOfFile:thumAvatarPath];
    }
    
    browseCellData.url = [NSURL URLWithString:self.viewModel.model.avatar];
    browseCellData.thumbUrl = [NSURL URLWithString:[NSString ym_thumbAvatarUrlStringWithOriginalString:self.viewModel.model.avatar]];
    browseCellData.sourceObject = self.avatarView;
    
    browseCellData.extraData = @{@"thumAvatarPath":thumAvatarPath,
                                 @"originalAvatarPath":originalAvatarPath,
                                 @"isGroup":@(NO)};
    
    YMImageBrowser *browser = [YMImageBrowser new];
    browser.dataSourceArray = @[browseCellData];
    [browser show];
}

#pragma mark - getter and setter
- (UIView *)whiteBgView {
    if (!_whiteBgView) {
        _whiteBgView = [[UIView alloc] init];
        _whiteBgView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteBgView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 25;
        _avatarView.layer.masksToBounds = YES;
        
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:self.viewModel.model.userId];
        [TShionSingleCase loadingAvatarWithImageView:_avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:self.viewModel.model.avatar] filePath:imagePath];
        
        [_avatarView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            [self showBigAvatar];
//            [self.viewModel.clickAvatarSubject sendNext:self.avatarView.image];
        }];
        [_avatarView addGestureRecognizer:tap];
    }
    
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont ALBoldFontSize17];
        _nameLabel.textColor = [UIColor ALTextDarkColor];
        _nameLabel.text = self.viewModel.model.showName;
       if(self.viewModel.model.name.length<1) {
            _nameLabel.text = self.viewModel.model.mobile;
        }
    }
    return _nameLabel;
}

- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.font = [UIFont ALFontSize16];
        _phoneLabel.text = [NSString stringWithFormat:@"+%@  %@",self.viewModel.model.dialCode,self.viewModel.model.mobile];
        _phoneLabel.userInteractionEnabled = YES;
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.viewModel.model.mobile;
            ShowWinMessage(Localized(@"Tips_Copy"));
        }];
        [_phoneLabel addGestureRecognizer:tap];
    }
    return _phoneLabel;
}

- (UIButton *)videoButton {
    if (!_videoButton) {
        _videoButton = [self creatButtonWithImage:@"NameCard_Video" tag:2];
    }
    return _videoButton;
}

- (UIButton *)callButton {
    if (!_callButton) {
        _callButton = [self creatButtonWithImage:@"NameCard_Call" tag:1];
    }
    return _callButton;
}

- (UIButton *)messageButton {
    if (!_messageButton) {
        _messageButton = [self creatButtonWithImage:@"NameCard_Message" tag:0];
    }
    return _messageButton;
}

- (UIButton *)creatButtonWithImage:(NSString *)image tag:(int)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setTag:tag];
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        int index = (int)x.tag;
        if (self.buttonClickBlock) {
            self.buttonClickBlock(index);
        }
    }];
    return button;
}

- (UILabel *)nickName {
    if (!_nickName) {
        _nickName = [UILabel constructLabel:CGRectZero
                                       text:[NSString stringWithFormat:@"%@:%@",Localized(@"OthersInfo_NickName"),self.viewModel.model.name]
                                       font:[UIFont ALFontSize14]
                                  textColor:[UIColor ALTextGrayColor]];
        _nickName.textAlignment = NSTextAlignmentLeft;
    }
    return _nickName;
}

- (UILabel *)address {
    if (!_address) {
        NSString *addressStr;
        NSString *region = self.viewModel.model.region.length ? self.viewModel.model.region : @"";
        NSString *country = self.viewModel.model.country.length ? self.viewModel.model.country : @"";
        
        if (!region && !country) {
            addressStr = [NSString stringWithFormat:@"%@:%@",Localized(@"UserInfo_Address"),Localized(@"UserInfo_Unknow")];
        } else {
            addressStr = [NSString stringWithFormat:@"%@:%@ %@",Localized(@"UserInfo_Address"),country,region];
        }
        _address = [UILabel constructLabel:CGRectZero
                                       text:addressStr
                                       font:[UIFont ALFontSize14]
                                  textColor:[UIColor ALTextGrayColor]];
        _address.textAlignment = NSTextAlignmentLeft;
        
    }
    return _address;
}

- (UIView *)segLine {
    if (!_segLine) {
        _segLine = [[UIView alloc] init];
        _segLine.backgroundColor = [UIColor ALLineColor];
    }
    return _segLine;
}

@end
