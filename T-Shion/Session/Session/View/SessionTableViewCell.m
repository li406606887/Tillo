//
//  DialogueTableViewCell.m
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SessionTableViewCell.h"
#import "YYText.h"
#import "NSString+Storage.h"

@implementation SessionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setupViews {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.messageNumber];
    [self.contentView addSubview:self.receivingTime];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.detailsMessage];
    [self.contentView addSubview:self.disturbView];
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.bottom.equalTo(self.contentView.mas_centerY).with.offset(-2);
        make.right.equalTo(self.receivingTime.mas_left).with.offset(-5);
    }];

    [self.detailsMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.name.mas_bottom).with.offset(8);
        make.left.equalTo(self.icon.mas_right).with.offset(10);
        make.right.equalTo(self.disturbView.mas_left).with.offset(-10);
    }];

    [self.receivingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(self.name);
        make.width.mas_equalTo(72);
    }];

    [self.messageNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(self.detailsMessage);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];

    [self.disturbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.messageNumber.mas_left).with.offset(-5);
        make.centerY.equalTo(self.detailsMessage);
        make.size.mas_equalTo(CGSizeMake(10, 12));
    }];
    
}

#pragma mark method
- (void)setModel:(SessionModel *)model {
    _model = model;
    if (model.isCrypt) {
        self.name.textColor = [UIColor ALLockColor];
    }else {
        self.name.textColor = [UIColor blackColor];
    }
    NSMutableAttributedString *detailStr = [[NSMutableAttributedString alloc] initWithString:Localized(model.text)];
    detailStr.yy_color = [UIColor ALTextGrayColor];
    detailStr.yy_font = [UIFont ALFontSize15];
    self.messageNumber.backgroundColor = [UIColor ALBtnNormalColor];
    if (model.isMentioned) {
        NSMutableAttributedString *mentionTip = [[NSMutableAttributedString alloc] initWithString:Localized(@"Chat_Msg_Mentioned")];
        mentionTip.yy_color = [UIColor ALRedColor];
        mentionTip.yy_font = [UIFont ALFontSize15];
        [detailStr insertAttributedString:mentionTip atIndex:0];
        self.messageNumber.backgroundColor = [UIColor redColor];
    } else {
        if (model.draftContent.length > 0) {
            detailStr = [[NSMutableAttributedString alloc] initWithString:model.draftContent];
            NSMutableAttributedString *draftTip = [[NSMutableAttributedString alloc] initWithString:Localized(@"Chat_Msg_Draft")];
            draftTip.yy_color = [UIColor ALRedColor];
            draftTip.yy_font = [UIFont ALFontSize15];
            [detailStr insertAttributedString:draftTip atIndex:0];
        }
    }
    self.detailsMessage.attributedText = detailStr;
    
    self.receivingTime.text = model.timestamp;
    NSString *name;
    if (model.model) {
        name = model.model.showName;
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.model.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.model.avatar] filePath:imagePath];
    } else {
        NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:model.group.roomId];
        
        [TShionSingleCase loadingGroupAvatarWithImageView:self.icon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.group.avatar] filePath:imagePath];
        name = _model.group.name;
    }
    
    
    self.name.text = name;
    
    BOOL state = [FMDBManager selectedRoomDisturbWithRoomId:model.roomId];
    self.disturbView.hidden = !state;
    
    if (model.unReadCount == 0 && model.offlineCount == 0) {
        self.messageNumber.hidden = YES;
    } else {
        self.messageNumber.hidden = NO;
//        self.messageNumber.backgroundColor = [UIColor ALBtnNormalColor];
        if (state) {
            self.messageNumber.text = nil;
        } else {
            self.messageNumber.text = model.unReadCount>99 ? @"99+": [NSString stringWithFormat:@"%d",model.unReadCount];
        }
    }
    
    CGFloat width;
    CGFloat height;
    
    if (self.messageNumber.text.length == 0 || self.messageNumber.hidden) {
        width = 10;
        height = 10;
        self.messageNumber.layer.cornerRadius = 5;
    } else if (self.messageNumber.text.length == 2) {
        width = 25;
        height = 20;
        self.messageNumber.layer.cornerRadius = 10;
    } else if (self.messageNumber.text.length > 2) {
        width = 35;
        height = 20;
        self.messageNumber.layer.cornerRadius = 10;
    } else {
        self.messageNumber.layer.cornerRadius = 10;
        width = 20;
        height = 20;
    }
    
//    CGFloat width = self.messageNumber.text.length>2 ? 35: 23;
    
    [self.messageNumber mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
 
    if (model.top) {
        [self setBackgroundColor:RGB(245, 245, 245)];
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
}
// 重写 insertSubview:atIndex 方法
- (void)addSubview:(UIView *)view {
    if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
        for (UIButton *btn in view.subviews) {
            
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn setBackgroundColor:[UIColor orangeColor]];
                
                [btn setTitle:nil forState:UIControlStateNormal];
                
                UIImage *img = [[UIImage imageNamed:@"Group_Create"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [btn setImage:img forState:UIControlStateNormal];
                [btn setImage:img forState:UIControlStateHighlighted];
                
                [btn setTintColor:[UIColor whiteColor]];
            }
        }
    }
    [super addSubview:view];
}
#pragma mark 懒加载
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 25;
        _icon.clipsToBounds = YES;
        _icon.image = [UIImage imageNamed:@"Avatar_Deafult"];
    }
    return _icon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont ALBoldFontSize18];
        _name.textColor = [UIColor blackColor];//pingfangsc-medium
    }
    return _name;
}

- (UILabel *)detailsMessage {
    if (!_detailsMessage) {
        _detailsMessage = [[UILabel alloc] init];
        _detailsMessage.font = [UIFont ALFontSize15];
        _detailsMessage.textColor = [UIColor ALTextGrayColor];
    }
    return _detailsMessage;
}

- (UILabel *)receivingTime {
    if (!_receivingTime) {
        _receivingTime = [[UILabel alloc] init];
        _receivingTime.textAlignment = NSTextAlignmentRight;
        _receivingTime.textColor = [UIColor ALTextGrayColor];
        _receivingTime.font = [UIFont ALFontSize13];
    }
    return _receivingTime;
}

- (UILabel *)messageNumber {
    if (!_messageNumber) {
        _messageNumber = [[UILabel alloc] init];
        _messageNumber.textColor = [UIColor whiteColor];
        _messageNumber.font = [UIFont systemFontOfSize:12];
        _messageNumber.textAlignment = NSTextAlignmentCenter;
        _messageNumber.backgroundColor = [UIColor ALBtnNormalColor];
        _messageNumber.layer.cornerRadius = 10;
        _messageNumber.layer.masksToBounds = YES;
    }
    return _messageNumber;
}

- (UIImageView *)disturbView {
    if (!_disturbView) {
        _disturbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"session_disturb"]];
    }
    return _disturbView;
}

//- (void)dealloc {
//    [self.model.group removeObserver:self forKeyPath:@"status"];
//}
@end
