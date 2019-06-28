//
//  FriendsTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/3/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsTableViewCell.h"
#import "NSString+Storage.h"

@implementation FriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.line];
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(15);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(15);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.name.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(1);
    }];
    
    [super layoutSubviews];
}

- (void)setModel:(FriendsModel *)model {
    _model = model;
    self.name.text = model.showName;

    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
 
    [TShionSingleCase loadingAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
}

- (void)setGroup:(GroupModel *)group {
    _group = group;
    self.name.text = group.name;
    self.icon.image = [UIImage imageNamed:@"Group_Deafult_Avatar"];
}

- (void)setMsg:(NSArray *)msg {
    _msg = msg;
    MessageModel *message = msg[0];
    FriendsModel *model = [FMDBManager selectFriendTableWithRoomId:message.roomId];
    if (model) {
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];

    }else {
        self.icon.image = [UIImage imageNamed:@"Group_Deafult_Avatar"];
    }
    
}

- (void)setMember:(MemberModel *)member {
    _member = member;
    self.name.text = [MemberModel getShowNameWithMember:member];
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:member.userId];
    [TShionSingleCase loadingAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:member.avatar] filePath:imagePath];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerRadius = 25;
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
//        _name.font = [UIFont ALBoldFontSize16];
        _name.font = [UIFont ALBoldFontSize17];
        _name.textColor = [UIColor ALTextDarkColor];
    }
    return _name;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor ALGrayBgColor];
    }
    return _line;
}


@end
