//
//  GroupMessageTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/7/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupListTableViewCell.h"

@implementation GroupListTableViewCell

- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.segLine];
}

- (void)setGroupModel:(GroupModel *)groupModel {
    _groupModel = groupModel;
        
    NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:groupModel.roomId];
    [TShionSingleCase loadingGroupAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:groupModel.avatar] filePath:imagePath];
    
    self.name.text = groupModel.name;
    [self.groupModel addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"name"]) {
        self.name.text = self.groupModel.name;
    }
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.centerY.equalTo(self.icon);
        make.right.equalTo(self.contentView);
        make.height.offset(18);
    }];
    
    [self.segLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(.5);
    }];
    [super layoutSubviews];
}

#pragma mark 懒加载
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 20;
        _icon.clipsToBounds = YES;
//        _icon.image = [UIImage imageNamed:@"Group_Deafult_Avatar"];
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.text = @"呱呱";
        _name.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _name.textColor = [UIColor blackColor];
    }
    return _name;
}

- (UIView *)segLine {
    if (!_segLine) {
        _segLine = [[UIView alloc] init];
        _segLine.backgroundColor = [UIColor ALLineColor];
    }
    return _segLine;
}

- (void)dealloc {
    [self.groupModel removeObserver:self forKeyPath:@"name"];
}
@end
