//
//  MemberCollectionCell.m
//  T-Shion
//
//  Created by together on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MemberTableViewCell.h"


@interface MemberTableViewCell ()
@property (strong, nonatomic) UIImageView *headIcon;

@property (strong, nonatomic) UILabel *nameLabel;

@property (strong , nonatomic) UIButton *messageButton;

@property (strong , nonatomic) UIButton *videoButton;

@property (strong , nonatomic) UIButton *callButton;

@property (strong , nonatomic) UIButton *addButton;
@end

@implementation MemberTableViewCell
- (void)setupViews {
    [self addSubview:self.headIcon];
    [self addSubview:self.nameLabel];
    [self addSubview:self.messageButton];
    [self addSubview:self.videoButton];
    [self addSubview:self.callButton];
    [self addSubview:self.addButton];
}

- (void)layoutSubviews {
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(35, 35));
        make.left.equalTo(self).with.offset(20);
    }];
  
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIcon.mas_right).with.offset(11);
        make.centerY.equalTo(self.headIcon);
        make.height.mas_offset(20);
        make.right.equalTo(self.messageButton.mas_left);
    }];
    
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.callButton.mas_left).with.offset(-10);
        make.centerY.equalTo(self.headIcon);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoButton.mas_left).with.offset(-10);
        make.centerY.equalTo(self.headIcon);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.centerY.equalTo(self.headIcon);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headIcon);
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(120, 30));
    }];
    
    [super layoutSubviews];
}

- (void)setModel:(MemberModel *)model {
    _model = model;
    self.headIcon.image = nil;
    FriendsModel *friend = [FMDBManager selectFriendTableWithUid:model.userId];
    if (model) {
        self.headIcon.hidden = NO;
        self.nameLabel.text = friend ? friend.showName : model.name;
        if (model.isHad==2) {
            self.addButton.hidden = self.callButton.hidden = self.messageButton.hidden = self.videoButton.hidden = YES;
        }else {
            self.callButton.hidden = self.messageButton.hidden = self.videoButton.hidden = (BOOL)model.isHad;
            self.addButton.hidden = !(BOOL)model.isHad;
        }
    }else {
        self.nameLabel.text = @"";
        self.addButton.hidden = self.callButton.hidden = self.messageButton.hidden = self.videoButton.hidden = self.headIcon.hidden = YES;
    }
    if ([model.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:[TShionSingleCase myThumbAvatarImgPath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headIcon setImage:image];
            });
        });
    } else {
        
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.headIcon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
    }
}

#pragma mark - getter
- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Avatar_Deafult"]];
        _headIcon.layer.masksToBounds = YES;
        _headIcon.layer.cornerRadius = 17.5;
    }
    return _headIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:15];
        _nameLabel.textColor = HEXCOLOR(0x666666);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLabel;
}

- (UIButton *)messageButton {
    if (!_messageButton) {
        _messageButton = [self creatButtonWithImage:@"NameCard_Message" tag:0];
    }
    return _messageButton;
}

- (UIButton *)videoButton {
    if (!_videoButton) {
        _videoButton = [self creatButtonWithImage:@"NameCard_Video" tag:1];
    }
    return _videoButton;
}

- (UIButton *)callButton {
    if (!_callButton) {
        _callButton = [self creatButtonWithImage:@"NameCard_Call" tag:2];
    }
    return _callButton;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [self creatButtonWithImage:nil tag:3];
        [_addButton setTitle:Localized(@"Add_Into_Contact") forState:UIControlStateNormal];
        [_addButton.titleLabel setFont:[UIFont fontWithName:@"PingFang-SC-Medium" size:14]];
        [_addButton setTitleColor:RGB(80, 138, 255) forState:UIControlStateNormal];
    }
    return _addButton;
}

- (UIButton *)creatButtonWithImage:(NSString *)image tag:(int)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setTag:tag];
//    button.backgroundColor = HEXACOLOR(0x518FFF,0.1);
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = 17.5;
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        int index = (int)x.tag;
        if (self.menuClickBlock) {
            self.menuClickBlock(index);
        }
    }];
    return button;
}
@end
