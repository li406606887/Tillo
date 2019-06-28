//
//  QueryMessageTableViewCell.m
//  T-Shion
//
//  Created by together on 2019/3/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "QueryMessageTableViewCell.h"
#import "NSString+Storage.h"

@interface QueryMessageTableViewCell()
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *avatar;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *describe;
@end

@implementation QueryMessageTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.describe];
    [self.contentView addSubview:self.timeLabel];
}

- (void)layoutSubviews {
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
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.top.equalTo(self.avatar.mas_top);
        make.size.mas_offset(CGSizeMake(100, 20));
    }];
    
    [self.describe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).with.offset(5);
        make.left.equalTo(self.avatar.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(15);
        make.height.mas_offset(20);
    }];
    [super layoutSubviews];
}

- (void)setMessage:(MessageModel *)message {
    _message = message;
    self.title.text = message.senderInfo.name;
    self.describe.text = message.content;
    self.timeLabel.text = message.times;
    if (self.type == 1) {
        self.title.text = message.senderInfo.showName;
    }else {
        self.title.text = [MemberModel getShowNameWithMember:message.member];
    }
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:message.sender];
    [TShionSingleCase loadingAvatarWithImageView:self.avatar url:[NSString ym_thumbAvatarUrlStringWithOriginalString:message.senderInfo.avatar] filePath:imagePath];
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

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        _timeLabel.textColor = RGB(102, 102, 102);
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}


@end
