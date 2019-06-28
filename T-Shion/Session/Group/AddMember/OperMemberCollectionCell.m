//
//  OperMemberCollectionCell.m
//  T-Shion
//
//  Created by together on 2019/1/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "OperMemberCollectionCell.h"

@implementation OperMemberCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headIcon];
        [self addSubview:self.setBtn];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self);
        make.size.mas_offset(CGSizeMake(45, 45));
    }];
  
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.headIcon.mas_bottom).with.offset(7);
        make.size.mas_offset(CGSizeMake(self.width-10, 13));
    }];
    
    [self.setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headIcon.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.size.mas_offset(CGSizeMake(30, 30));
    }];
    
    [super layoutSubviews];
}

- (void)setModel:(FriendsModel *)model {
    _model = model;
    self.headIcon.image = nil;
    if (model) {
        self.nameLabel.text = model.showName;
        
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.headIcon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
        
    } else {
        self.nameLabel.text = @"";
        self.headIcon.hidden = YES;
    }
}

- (void)setMember:(MemberModel *)member {
    _member = member;
    self.headIcon.image = nil;
    if (member) {
        self.nameLabel.text = [MemberModel getShowNameWithMember:member];
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:member.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.headIcon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:member.avatar] filePath:imagePath];
    }
}

#pragma mark - getter
- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Avatar_Deafult"]];
        _headIcon.layer.masksToBounds = YES;
        _headIcon.layer.cornerRadius = 22.5;
    }
    return _headIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:11];
        _nameLabel.textColor = HEXCOLOR(0x666666);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLabel;
}

- (UIButton *)setBtn {
    if(!_setBtn) {
        _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setBtn setImage:[UIImage imageNamed:@"operMember_subtract"] forState:UIControlStateNormal];
        @weakify(self)
        [[_setBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.modifyBlock) {
                self.modifyBlock();
            }
        }];
    }
    return _setBtn;
}
@end
