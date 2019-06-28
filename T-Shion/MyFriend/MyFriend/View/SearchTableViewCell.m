//
//  SearchTableViewCell.m
//  T-Shion
//
//  Created by together on 2019/3/20.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupViews {
    [self addSubview:self.avatar];
    [self addSubview:self.title];
    [self addSubview:self.centerTitle];
    [self addSubview:self.describe];
    [self addSubview:self.line];
    [self setlayoutSubviews];
}

- (void)setlayoutSubviews {
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.top.equalTo(self.avatar).with.offset(5);
        make.height.mas_offset(20);
    }];
    
    [self.centerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.centerY.equalTo(self.avatar);
        make.height.mas_offset(20);
    }];
    
    [self.describe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).with.offset(5);
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.height.mas_offset(20);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-1);
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right);
        make.height.mas_offset(0.6);
    }];
    [super layoutSubviews];
}

- (void)setFriendModel:(FriendsModel *)friendModel {
    self.describe.hidden = YES;
    self.title.hidden = YES;
    self.centerTitle.hidden = NO;
    friendModel = friendModel;
    self.centerTitle.text = friendModel.showName;
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:friendModel.userId];
    [TShionSingleCase loadingAvatarWithImageView:self.avatar url:[NSString ym_thumbAvatarUrlStringWithOriginalString:friendModel.avatar] filePath:imagePath];
    
    self.title.textColor = RGB(21, 21, 21);
}

- (void)setGroupModel:(GroupModel *)groupModel {
    self.describe.hidden = YES;
    self.title.hidden = YES;
    self.centerTitle.hidden = NO;
    _groupModel = groupModel;
    self.centerTitle.text = groupModel.name;
    NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:groupModel.roomId];
    
    [TShionSingleCase loadingGroupAvatarWithImageView:self.avatar url:[NSString ym_thumbAvatarUrlStringWithOriginalString:groupModel.avatar] filePath:imagePath];

    self.title.textColor = RGB(21, 21, 21);

}

- (void)setMsgArray:(NSArray *)msgArray {
    self.describe.hidden = NO;
    self.title.hidden = NO;
    self.centerTitle.hidden = YES;
    _msgArray = msgArray;
    MessageModel *message = msgArray[0];
    if (message.cryptoType >0) {
        self.title.textColor = [UIColor ALLockColor];
    }else {
        _title.textColor = RGB(21, 21, 21);
    }
    FriendsModel *model = [FMDBManager selectFriendTableWithRoomId:message.roomId];
    if (model) {
        
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.avatar url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
        self.title.text = model.showName;
    }else {
        GroupModel *group = [FMDBManager selectGroupModelWithRoomId:message.roomId];
        
        NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:group.roomId];
        
         [TShionSingleCase loadingGroupAvatarWithImageView:self.avatar url:[NSString ym_thumbAvatarUrlStringWithOriginalString:group.avatar] filePath:imagePath];
        
        self.title.text = group.name;
    }
    self.describe.text = [NSString stringWithFormat:@"%@%ld%@",Localized(@"find"),msgArray.count,Localized(@"relevant_records")];
}

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.masksToBounds = YES;
        _avatar.layer.cornerRadius = 25;
    }
    return _avatar;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont fontWithName:@"Adobe Heiti Std R" size:16];
        _title.textColor = RGB(21, 21, 21);
    }
    return _title;
}

- (UILabel *)describe {
    if (!_describe) {
        _describe = [[UILabel alloc] init];
        _describe.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        _describe.textColor = RGB(102, 102, 102);
    }
    return _describe;
}

- (UILabel *)centerTitle {
    if (!_centerTitle) {
        _centerTitle = [[UILabel alloc] init];
        _centerTitle.font = [UIFont fontWithName:@"Adobe Heiti Std R" size:16];
        _centerTitle.textColor = RGB(21, 21, 21);
    }
    return _centerTitle;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = RGB(221, 221, 221);
    }
    return _line;
}
@end
