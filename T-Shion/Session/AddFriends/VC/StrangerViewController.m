//
//  StrangerViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "StrangerViewController.h"
#import "SendInviteMsgController.h"

@interface StrangerViewController ()

@property (nonatomic, strong) UIView *infoBgView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *sexFlagView;
@property (nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) UIButton *addBtn;


@end

@implementation StrangerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"UserInfo_Stranger");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.infoBgView];
    [self.infoBgView addSubview:self.avatarView];
    [self.infoBgView addSubview:self.nameLabel];
    [self.infoBgView addSubview:self.sexFlagView];
    [self.infoBgView addSubview:self.accountLabel];
    [self.infoBgView addSubview:self.addressLabel];
    [self.view addSubview:self.addBtn];
}

- (void)viewDidLayoutSubviews {
    [self.infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoBgView.mas_left).with.offset(15);
        make.top.equalTo(self.infoBgView.mas_top).with.offset(12);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(15);
        make.bottom.equalTo(self.avatarView.mas_centerY);
        make.right.lessThanOrEqualTo(self.view.mas_right).with.offset(-30);
    }];
    
    [self.sexFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).with.offset(2);
        make.centerY.equalTo(self.nameLabel.mas_centerY);
    }];
    
    [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(10);
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.top.equalTo(self.accountLabel.mas_bottom).with.offset(8);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoBgView.mas_bottom).with.offset(15);
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
        make.height.mas_equalTo(50);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)gotoSendMsg {
    SendInviteMsgController *sendVC = [[SendInviteMsgController alloc] init];
    sendVC.viewModel.model = self.model;
    sendVC.isNavPop = self.isNavPop;
    [self.navigationController pushViewController:sendVC animated:YES];
}

- (void)passValidation {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.model.requestId forKey:@"id"];
    [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
    [param setObject:self.model.uid forKey:@"receiver"];
    [self.viewModel.agreeCommand execute:param];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.agreeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}


#pragma mark - getter
- (UIView *)infoBgView {
    if (!_infoBgView) {
        _infoBgView = [[UIView alloc] init];
        _infoBgView.backgroundColor = [UIColor whiteColor];
    }
    return _infoBgView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 25;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:nil
                                        font:[UIFont ALBoldFontSize17]
                                   textColor:[UIColor ALTextDarkColor]];
    }
    return _nameLabel;
}

- (UIImageView *)sexFlagView {
    if (!_sexFlagView) {
        _sexFlagView = [[UIImageView alloc] init];
    }
    return _sexFlagView;
}

- (UILabel *)accountLabel {
    if (!_accountLabel) {
        _accountLabel = [UILabel constructLabel:CGRectZero
                                           text:nil
                                           font:[UIFont ALFontSize14]
                                      textColor:[UIColor ALTextGrayColor]];
    }
    return _accountLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [UILabel constructLabel:CGRectZero
                                           text:nil
                                           font:[UIFont ALFontSize14]
                                      textColor:[UIColor ALTextGrayColor]];
    }
    return _addressLabel;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        
        [_addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateHighlighted];
        
        [_addBtn setTitle:Localized(@"friend_add_friend_title") forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor ALBlueColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont ALFontSize15];
        _addBtn.layer.masksToBounds = YES;
        _addBtn.layer.cornerRadius = 25;
        
        @weakify(self)
        [[_addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.isFromValidation) {
                [self passValidation];
            } else {
                [self gotoSendMsg];
            }
        }];
    }
    return _addBtn;
}

- (void)setModel:(AddFriendsModel *)model {
    _model = model;
    self.nameLabel.text = model.name;
    NSString *sexIcon = [model.sex integerValue] == 0 ? @"setting_sex_man" : @"setting_sex_woman";
    self.sexFlagView.image = [UIImage imageNamed:sexIcon];
    self.accountLabel.text = [NSString stringWithFormat:@"%@:%@",Localized(@"UserInfo_Account"),model.mobile];
    
    
    NSString *addressStr;
    
    NSString *region = model.region.length ? model.region : @"";
    
    if (!region.length) {
        addressStr = [NSString stringWithFormat:@"%@:%@",Localized(@"UserInfo_Address"),Localized(@"UserInfo_Unknow")];
    } else {
        addressStr = [NSString stringWithFormat:@"%@: %@",Localized(@"UserInfo_Address"),region];
    }
    
    self.addressLabel.text = addressStr;
    
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"Avatar_Deafult"]];
    
    self.addBtn.hidden = model.roomId.length > 0 || [[SocketViewModel shared].userModel.ID isEqualToString:model.uid];
}

- (void)setIsFromValidation:(BOOL)isFromValidation {
    _isFromValidation = isFromValidation;
    if (isFromValidation) {
        [_addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        [_addBtn setTitle:Localized(@"Agree") forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        [_addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        
        [_addBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateHighlighted];
        
        [_addBtn setTitle:Localized(@"friend_add_friend_title") forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor ALBlueColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont ALFontSize15];
    }
}

- (FriendsValidationViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[FriendsValidationViewModel alloc] init];
    }
    return _viewModel;
}


@end
