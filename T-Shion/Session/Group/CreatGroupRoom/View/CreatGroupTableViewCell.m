//
//  CreatGroupTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "CreatGroupTableViewCell.h"

@implementation CreatGroupTableViewCell

- (void)setupViews {
    [self addSubview:self.icon];
    [self addSubview:self.name];
    [self addSubview:self.selectedBtn];
    [self addSubview:self.line];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.size.mas_offset(CGSizeMake(30, 30));
        make.centerY.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)setModel:(FriendsModel *)model {
    [super setModel:model];
}

- (void)setMember:(MemberModel *)member {
    self.selectedBtn.selected = member.selected;
    [super setMember:member];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setImage:[UIImage imageNamed:@"Friend_choose_normal"] forState:UIControlStateNormal];
        [_selectedBtn setImage:[UIImage imageNamed:@"Friend_choose_selected"] forState:UIControlStateSelected];
        [_selectedBtn setImage:[UIImage imageNamed:@"Friend_disable_selected"] forState:UIControlStateDisabled];
        _selectedBtn.userInteractionEnabled = NO;
        
    }
    return _selectedBtn;
}
@end
