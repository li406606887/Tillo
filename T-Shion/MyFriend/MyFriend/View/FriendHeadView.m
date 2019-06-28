//
//  FriendHeadView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "FriendHeadView.h"
#import "UIView+BorderLine.h"

@interface FriendHeadView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UILabel *addLabel;

@property (nonatomic, strong) UIButton *groupBtn;
@property (nonatomic, strong) UILabel *groupLabel;

@property (nonatomic, strong) UIButton *inviteBtn;
@property (nonatomic, strong) UILabel *inviteLabel;

@property (nonatomic, strong) UIView *redDotView;

@end


@implementation FriendHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
//    self.borderLineColor = [UIColor ALLineColor].CGColor;
//    self.borderLineStyle = BorderLineStyleBottom;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.addBtn];
    [self.addBtn addSubview:self.redDotView];
    [self addSubview:self.addLabel];
    [self addSubview:self.groupBtn];
    [self addSubview:self.groupLabel];
    [self addSubview:self.inviteBtn];
    [self addSubview:self.inviteLabel];
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"NewFirendPrompt" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
            NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            self.redDotView.hidden = [count intValue]  > 0 ? NO: YES;
        });        
    }];

}

- (void)setupConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15);
        make.top.equalTo(self.mas_top);
        make.height.mas_offset(50);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(25);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(16);
    }];
    
    [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addBtn.mas_right);
        make.top.equalTo(self.addBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    [self.groupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addBtn.mas_right).with.offset(40);
        make.top.equalTo(self.addBtn.mas_top);
    }];
    
    [self.inviteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.groupBtn.mas_right).with.offset(40);
        make.top.equalTo(self.addBtn.mas_top);
    }];
    
    [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addBtn.mas_bottom).with.offset(6);
        make.centerX.equalTo(self.addBtn.mas_centerX);
    }];
    
    [self.groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupBtn.mas_bottom).with.offset(6);
        make.centerX.equalTo(self.groupBtn.mas_centerX);
    }];
    
    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inviteBtn.mas_bottom).with.offset(6);
        make.centerX.equalTo(self.inviteBtn.mas_centerX);
    }];
}


#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:Localized(@"friend_navigation_title")
                                         font:[UIFont ALBoldFontSize30]
                                    textColor:[UIColor ALTextDarkColor]];
    }
    return _titleLabel;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"friend_btn_add"] forState:UIControlStateNormal];
        
        @weakify(self);
        [[_addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOperateButtonWithIndex:)]) {
                [self.delegate didClickOperateButtonWithIndex:0];
            }
        }];
    }
    return _addBtn;
}

- (UILabel *)addLabel {
    if (!_addLabel) {
        _addLabel = [UILabel constructLabel:CGRectZero
                                       text:Localized(@"friend_add_friend_title")
                                       font:[UIFont ALFontSize12]
                                  textColor:[UIColor ALTextGrayColor]];
    }
    return _addLabel;
}

- (UIButton *)groupBtn {
    if (!_groupBtn) {
        _groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_groupBtn setImage:[UIImage imageNamed:@"friend_btn_group"] forState:UIControlStateNormal];
        
        @weakify(self);
        [[_groupBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOperateButtonWithIndex:)]) {
                [self.delegate didClickOperateButtonWithIndex:1];
            }
        }];
    }
    return _groupBtn;
}

- (UILabel *)groupLabel {
    if (!_groupLabel) {
        _groupLabel = [UILabel constructLabel:CGRectZero
                                         text:Localized(@"friend_group_chat_title")
                                         font:[UIFont ALFontSize12]
                                    textColor:[UIColor ALTextGrayColor]];
    }
    return _groupLabel;
}

- (UIButton *)inviteBtn {
    if (!_inviteBtn) {
        _inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inviteBtn setImage:[UIImage imageNamed:@"friend_btn_invite"] forState:UIControlStateNormal];
        
        @weakify(self);
        [[_inviteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOperateButtonWithIndex:)]) {
                [self.delegate didClickOperateButtonWithIndex:2];
            }
        }];
    }
    return _inviteBtn;
}

- (UILabel *)inviteLabel {
    if (!_inviteLabel) {
        _inviteLabel = [UILabel constructLabel:CGRectZero
                                         text:Localized(@"Invite_friends")
                                         font:[UIFont ALFontSize12]
                                    textColor:[UIColor ALTextGrayColor]];
    }
    return _inviteLabel;
}

- (UIView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[UIView alloc] init];
        _redDotView.backgroundColor = [UIColor redColor];
        _redDotView.layer.masksToBounds = YES;
        _redDotView.layer.cornerRadius = 6;
        NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
        NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        _redDotView.hidden = [count intValue]  > 0 ? NO: YES;
    }
    return _redDotView;
}

- (void)setScrollOffset:(CGFloat)scrollOffset {
    
    if (scrollOffset >= 50) {
        self.titleLabel.alpha = 0;
    } else {
        self.titleLabel.alpha = (50 - scrollOffset)/50;
    }
    
}

@end
