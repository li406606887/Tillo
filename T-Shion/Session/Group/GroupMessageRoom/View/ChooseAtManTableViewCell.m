//
//  ChooseAtManTableViewCell.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ChooseAtManTableViewCell.h"

NSString *const ChooseAtManTableViewCellReuseIdentifier = @"ChooseAtManTableViewCell";

@interface ChooseAtManTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *segLine;

@end

@implementation ChooseAtManTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.segLine];
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
    }];
    
    [self.segLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}


#pragma mark - getter
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 22;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:nil
                                        font:[UIFont ALBoldFontSize16]
                                   textColor:[UIColor ALTextNormalColor]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UIView *)segLine {
    if (!_segLine) {
        _segLine = [[UIView alloc] init];
        _segLine.backgroundColor = [UIColor ALLineColor];
    }
    return _segLine;
}

- (void)setModel:(MemberModel *)model {
    _model = model;
    self.avatarView.image = nil;
    FriendsModel *friend = [FMDBManager selectFriendTableWithUid:model.userId];
    self.nameLabel.text = friend ? friend.showName : model.name;
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
    [TShionSingleCase loadingAvatarWithImageView:self.avatarView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
}

@end
