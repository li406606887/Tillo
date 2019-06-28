//
//  InviteFriendTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/12/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "InviteFriendTableViewCell.h"
#import "ALContactManager.h"

@interface InviteFriendTableViewCell()
@property (strong, nonatomic) UIButton *selectedBtn;

@property (strong, nonatomic) UILabel *name;

@property (strong, nonatomic) UILabel *phone;

@property (strong, nonatomic) UILabel *iconLabel;

@end

@implementation InviteFriendTableViewCell
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.selectedBtn.selected = selected;
    [super setSelected:selected animated:animated];
}

- (void)setupViews {
    [self.contentView addSubview:self.iconLabel];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.phone];
    [self.contentView addSubview:self.selectedBtn];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    [self.iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(12);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconLabel.mas_right).with.offset(14);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right);
        make.height.offset(20);
    }];
    
    [self.phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconLabel.mas_right).with.offset(14);
        make.top.equalTo(self.name.mas_bottom).with.offset(5);
        make.right.equalTo(self.contentView.mas_right);
        make.height.offset(20);
    }];
    
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-15);
        make.size.mas_offset(CGSizeMake(30, 30));
        make.centerY.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)setModel:(InviteFriendModel *)model {
    _model = model;
    self.name.text = [model.familyName stringByAppendingString:model.givenName];
    self.phone.text = model.phoneNo;
    self.iconLabel.text = model.letter;
}

- (void)setSysPerson:(ALSysPerson *)sysPerson {
    _sysPerson = sysPerson;
    self.name.text = sysPerson.fullName;
    ALSysPhone *phoneModel = sysPerson.phones.firstObject;
    self.phone.text = phoneModel.phone;
    self.iconLabel.text = [[ALContactManager sharedInstance] al_firstCharacterWithString:sysPerson.fullName];
}

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.layer.masksToBounds = YES;
        _iconLabel.layer.cornerRadius = 20;
        _iconLabel.backgroundColor = RGB(193, 207, 217);
        _iconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _iconLabel;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont fontWithName:@"pingfangsc-medium" size:16];
        _name.textColor = [UIColor ALTextDarkColor];
    }
    return _name;
}

- (UILabel *)phone {
    if (!_phone) {
        _phone = [[UILabel alloc] init];
        _phone.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        _phone.textColor = [UIColor ALTextLightColor];
    }
    return _phone;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setImage:[UIImage imageNamed:@"Friend_choose_normal"] forState:UIControlStateNormal];
        [_selectedBtn setImage:[UIImage imageNamed:@"Friend_choose_selected"] forState:UIControlStateSelected];
        _selectedBtn.userInteractionEnabled = NO;
    }
    return _selectedBtn;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code.
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 0.33);
    //设置颜色
    CGContextSetRGBStrokeColor(context, 0.8, 0.8, 0.8, 1.0);
    //开始一个起始路径
    CGContextBeginPath(context);
    //起始点设置为(0,0):注意这是上下文对应区域中的相对坐标，
    CGContextMoveToPoint(context, 60, 60);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, SCREEN_WIDTH, 60);
    //连接上面定义的坐标点
    CGContextStrokePath(context);
}

@end


@interface InviteLinkTableViewCell ()
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *iconArray;
@property (strong, nonatomic) UIView *wsapp;
@property (strong, nonatomic) UIView *wechat;
@property (strong, nonatomic) UIView *copLink;
@property (assign, nonatomic) BOOL wsappState;
@property (assign, nonatomic) BOOL wechatstate;
@end

@implementation InviteLinkTableViewCell

- (void)setupViews {
    if (self.wsappState) {
        [self addSubview:self.wsapp];
    }
    if (self.wechatstate) {
        [self addSubview:self.wechat];
    }
    [self addSubview:self.copLink];
}

- (void)layoutSubviews {
    if (self.wsappState == YES&& self.wechatstate == YES) {
        [@[self.wsapp,self.wechat,self.copLink] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(15);
            make.height.offset(60);
        }];
        
        CGFloat padding = (SCREEN_WIDTH - 70*3)/4;
        [@[self.wsapp,self.wechat,self.copLink] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:70 leadSpacing:padding tailSpacing:padding];
    }else if(self.wsappState == NO&& self.wechatstate == YES) {
        [@[self.wechat,self.copLink] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(15);
            make.height.offset(60);
        }];
        
        CGFloat padding = (SCREEN_WIDTH - 70*2)/3;
        [@[self.wechat,self.copLink] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:70 leadSpacing:padding tailSpacing:padding];
    }else if (self.wsappState == YES&& self.wechatstate == NO) {
        [@[self.wsapp,self.copLink] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(15);
            make.height.offset(60);
        }];
        
        CGFloat padding = (SCREEN_WIDTH - 70*2)/3;
        [@[self.wsapp,self.copLink] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:70 leadSpacing:padding tailSpacing:padding];
    }else {
        [self.copLink mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_offset(CGSizeMake(70, 60));
        }];
    }
    [super layoutSubviews];
}

- (UIView *)wsapp {
    if (!_wsapp) {
        _wsapp = [self creatButtonWithTitle:self.titleArray[0] image:self.iconArray[0] tag:0];
    }
    return _wsapp;
}

- (UIView *)wechat {
    if (!_wechat) {
        _wechat = [self creatButtonWithTitle:self.titleArray[1] image:self.iconArray[1] tag:1];
    }
    return _wechat;
}

- (UIView *)copLink {
    if (!_copLink) {
        _copLink = [self creatButtonWithTitle:self.titleArray[2] image:self.iconArray[2] tag:2];
    }
    return _copLink;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[Localized(@"whatsApp"),Localized(@"weChat"),Localized(@"copLink")];
    }
    return _titleArray;
}

- (NSArray *)iconArray {
    if (!_iconArray) {
        _iconArray = @[@"invite_whatsapp",@"invite_wechat",@"invite_coplink"];
    }
    return _iconArray;
}

- (UIView*)creatButtonWithTitle:(NSString *)title image:(NSString*)image tag:(int)tag{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor ALTextGrayColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    UIView *view = [[UIView alloc] init];
    [view addSubview:imageView];
    [view addSubview:label];
    view.tag = tag;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.centerX.equalTo(view);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).with.offset(5);
        make.centerX.equalTo(view);
        make.size.mas_offset(CGSizeMake(70, 15));
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    @weakify(self)
    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        if (self.itemClickBlock) {
            self.itemClickBlock((int)x.view.tag);
        }
    }];
    [view addGestureRecognizer:tap];
    return view;
}

- (BOOL)wsappState {
    return [self checkInviteAppWithUrl:@"whatsapp://"];
}

- (BOOL)wechatstate {
    return [self checkInviteAppWithUrl:@"weixin://"];
}

- (BOOL)checkInviteAppWithUrl:(NSString *)url {
    BOOL state = NO;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]){
        state = YES;//说明此设备有安装app
    };
    return state;
}


@end
