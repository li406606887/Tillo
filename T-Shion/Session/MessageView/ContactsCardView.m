//
//  ContactsCardView.m
//  AilloTest
//
//  Created by together on 2019/6/12.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "ContactsCardView.h"

@interface ContactsCardView ()
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *phone;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIButton *add;
@property (nonatomic, strong) UIButton *send;
@property (copy, nonatomic) NSString *uid;
@end


@implementation ContactsCardView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        [self addSubview:self.icon];
        [self addSubview:self.title];
        [self addSubview:self.phone];
        [self addSubview:self.name];
        [self addSubview:self.add];
        [self addSubview:self.send];
    }
    return self;
}

- (void)layoutSubviews {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.top.equalTo(self).with.offset(30);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(100, 20));
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.top.equalTo(self);
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(37);
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.height.offset(17);
    }];
    
    [self.phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).with.offset(8);
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.height.offset(14);
    }];
    
    [self.add mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-10);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(85, 25));
    }];
    
    [self.send mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-10);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(85, 25));
    }];
    [super layoutSubviews];
}
#pragma mark - getter
- (CGSize)bubbleSize {
    return CGSizeMake(250, 135);
}

- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
    self.add.hidden = NO;
    self.send.hidden = NO;
    NSDictionary *dic = [NSString dictionaryWithJsonString:message.content];
    NSString *friendId = [dic objectForKey:@"friendId"];
    self.uid = friendId;
    FriendsModel *friend = [FMDBManager selectFriendTableWithUid:friendId];
    if ([friendId isEqualToString:[SocketViewModel shared].userModel.ID]) {
        self.add.hidden = YES;
        self.send.hidden = YES;
    }
    if (friend) {
        self.add.hidden = YES;
    }else {
        self.send.hidden = YES;
    }
    self.name.text = [dic objectForKey:@"name"];
    self.phone.text = [dic objectForKey:@"mobile"];
    [self.icon sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"avatar"]]];
    UIImage *avatar;
    NSString *path = [TShionSingleCase thumbAvatarImgPathWithUserId:friendId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        avatar = image;
    }else {
        avatar = [UIImage imageNamed:@"Avatar_Deafult"];
    }
    [self.icon sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"avatar"]] placeholderImage:avatar options:SDWebImageLowPriority completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image != nil ) {
            NSData *data = UIImageJPEGRepresentation(image, 1);
            BOOL result = [data writeToFile:path atomically:YES];
            if (!result) {
                NSLog(@"好友头像更新失败保存到本地");
            }
        }
    }];
}
#pragma mark - lazyloading
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerRadius = 25;
        _icon.backgroundColor = [UIColor lightGrayColor];
    }
    return _icon;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:11];
        _title.textColor = RGB(153, 153, 153);
        _title.textAlignment = NSTextAlignmentRight;
        _title.text = Localized(@"Contact_card");
    }
    return _title;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:16];
        _name.text = @"葫芦天地小丸子三生石水素水";
    }
    return _name;
}

- (UILabel *)phone {
    if (!_phone) {
        _phone = [[UILabel alloc] init];
        _phone.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:13];
        _phone.text = @"+86 13621213241";
    }
    return _phone;
}

- (UIButton *)add {
    if (!_add) {
        _add = [UIButton buttonWithType:UIButtonTypeCustom];
        [_add setBackgroundColor:[UIColor ALBtnNormalColor]];
        [_add.titleLabel setFont:[UIFont fontWithName:@"PingFang-SC-Medium" size:13]];
        _add.layer.cornerRadius = 12.5;
        _add.layer.masksToBounds = YES;
        [_add setTitle:@"加好友" forState:UIControlStateNormal];
        @weakify(self)
        [[_add rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.clickBlcok) {
                self.clickBlcok(self.message.content,2);
            }
        }];
    }
    return _add;
}

- (UIButton *)send {
    if (!_send) {
        _send = [UIButton buttonWithType:UIButtonTypeCustom];
        [_send setBackgroundColor:RGB(238, 238, 238)];
        [_send setTitleColor:[UIColor ALTextDarkColor] forState:UIControlStateNormal];
        [_send.titleLabel setFont:[UIFont ALFontSize13]];
        _send.layer.cornerRadius = 12.5;
        _send.layer.masksToBounds = YES;
        [_send setTitle:@"发消息" forState:UIControlStateNormal];
        @weakify(self)
        [[_send rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.clickBlcok) {
                self.clickBlcok(self.uid,1);
            }
        }];
    }
    return _send;
}

- (void)drawRect:(CGRect)rect {
    UIColor *lineColor = RGB(200, 200, 200);
    [lineColor set];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.5f;
    [path moveToPoint:CGPointMake(250, 21)];
    [path addLineToPoint:CGPointMake(0, 21)];
    [path closePath];
    [path stroke];
    [super drawRect:rect];
}
@end
