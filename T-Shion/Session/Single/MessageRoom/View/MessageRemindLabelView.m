//
//  MessageRemindLabelView.m
//  T-Shion
//
//  Created by together on 2019/5/16.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "MessageRemindLabelView.h"

@implementation MessageRemindLabelView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addChildView];
        self.backgroundColor = [UIColor clearColor];
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[[tap rac_gestureSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.readFirstMsgBlock) {
                self.readFirstMsgBlock();
            }
        }];
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)addChildView {
    [self addSubview:self.icon];
    [self addSubview:self.content];
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(12, 12));
    }];
    
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.icon.mas_right).with.offset(3);
        make.size.mas_offset(CGSizeMake(100, 30));
    }];
    [super layoutSubviews];
}

- (void)setUnreadCount:(int)unreadCount {
    _unreadCount = unreadCount;
    if (unreadCount>99) {
        self.content.text = [NSString stringWithFormat:@"%d+%@",unreadCount,Localized(@"unread_messages")];
    }else {
        self.content.text = [NSString stringWithFormat:@"%d%@",unreadCount,Localized(@"unread_messages")];
    }
    if (unreadCount<4) {
        self.hidden = YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Message_remind_icon"]];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _icon;
}

- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = RGB(84, 208, 172);
        _content.font = [UIFont ALFontSize13];
    }
    return _content;
}

- (void)drawRect:(CGRect)rect {
    // 创建path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(15 , 15)];
    [path addLineToPoint:CGPointMake(130, 15)];
    path.lineWidth = 30;
    [[UIColor whiteColor] setStroke];
    [path stroke];
        [path addArcWithCenter:CGPointMake(15, 15) radius:7.5 startAngle:M_PI_2 endAngle:M_PI*1.5 clockwise:YES];
        // 将path绘制出来
        path.lineWidth = 15;
        [[UIColor whiteColor] setStroke];
        [path stroke];
}
@end
