//
//  MessageWithdrawView.m
//  T-Shion
//
//  Created by together on 2019/3/5.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageWithdrawView.h"

@implementation MessageWithdrawView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.contentLabel];
}

- (void)layoutSubviews {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.superview);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-60, 40));
    }];
}

- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
    if (message.sendType == SelfSender) {
        self.contentLabel.text = Localized(@"Self_Withdraw");
    }else {
        if (!message.member) {
            self.contentLabel.text = [NSString stringWithFormat:@"%@",Localized(@"friend_Withdraw")];
        }else {
            self.contentLabel.text = [NSString stringWithFormat:@"\"%@\"%@",[MemberModel getShowNameWithMember:message.member],Localized(@"other_Withdraw")];
        }
        
    }
}

- (CGSize)bubbleSize {
    return CGSizeMake(SCREEN_WIDTH-30, 40);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:14];
        _contentLabel.textColor = RGB(153, 153, 153);
        _contentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLabel;
}

@end
