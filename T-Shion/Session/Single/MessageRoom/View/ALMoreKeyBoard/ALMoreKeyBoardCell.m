//
//  ALMoreKeyBoardCell.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALMoreKeyBoardCell.h"
#import "ALMoreKeyboardItem.h"

@interface ALMoreKeyBoardCell ()

@property (nonatomic, strong) UIButton *iconButton;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ALMoreKeyBoardCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.iconButton];
        [self.contentView addSubview:self.titleLabel];
        [self setupMasonry];
    }
    return self;
}

- (void)setupMasonry {
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.iconButton.mas_width);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Event Response
- (void)iconButtonDown:(UIButton *)sender {
    self.clickBlock(self.item);
}

#pragma mark - getter
- (UIButton *)iconButton {
    if (!_iconButton) {
        _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconButton addTarget:self action:@selector(iconButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:nil
                                         font:[UIFont ALFontSize13]
                                    textColor:[UIColor ALTextNormalColor]];
    }
    return _titleLabel;
}

#pragma mark - setter
- (void)setItem:(ALMoreKeyboardItem *)item {
    _item = item;
    if (item == nil) {
        [self.titleLabel setHidden:YES];
        [self.iconButton setHidden:YES];
        [self setUserInteractionEnabled:NO];
        return;
    }
    [self setUserInteractionEnabled:YES];
    [self.titleLabel setHidden:NO];
    [self.iconButton setHidden:NO];
    [self.titleLabel setText:item.title];
    [self.iconButton setImage:[UIImage imageNamed:item.imagePath] forState:UIControlStateNormal];
}

@end
