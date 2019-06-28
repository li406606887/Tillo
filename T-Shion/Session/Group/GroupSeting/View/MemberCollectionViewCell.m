//
//  MemberCollectionViewCell.m
//  T-Shion
//
//  Created by together on 2018/8/13.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MemberCollectionViewCell.h"

@implementation MemberCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headIcon];
        [self addSubview:self.setBtn];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.headIcon.mas_bottom).with.offset(7);
        make.size.mas_offset(CGSizeMake(self.width-10, 13));
    }];
    [super layoutSubviews];
}

- (void)setModel:(MemberModel *)model {
    _model = model;
    @weakify(self)
    self.headIcon.image = nil;
    if (model) {
        self.setBtn.hidden = YES;
        self.headIcon.hidden = NO;
        [[RACObserve(model, showName) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            self.nameLabel.text = [MemberModel getShowNameWithMember:model];
        }];
    }else {
        self.nameLabel.text = @"";
        self.setBtn.hidden = NO;
        self.headIcon.hidden = YES;
    }
    if ([model.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:[TShionSingleCase myThumbAvatarImgPath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headIcon setImage:image];
            });
        });
    } else {
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
        [TShionSingleCase loadingAvatarWithImageView:self.headIcon url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];
    }
}

#pragma mark - getter
- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Avatar_Deafult"]];
        _headIcon.layer.masksToBounds = YES;
        _headIcon.layer.cornerRadius = 25;
        _headIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
           @strongify(self)
            if (self.memberClickBlock) {
                self.memberClickBlock(self.model);
            }
        }];
        [_headIcon addGestureRecognizer:tap];
    }
    return _headIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:11];
        _nameLabel.textColor = HEXCOLOR(0x666666);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _nameLabel;
}

- (UIButton *)setBtn {
    if(!_setBtn) {
        _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setBtn setImage:[UIImage imageNamed:@"member_add"] forState:UIControlStateNormal];
        [_setBtn setImage:[UIImage imageNamed:@"member_subtract"] forState:UIControlStateSelected];
//        _setBtn.layer.masksToBounds = YES;
//        _setBtn.layer.cornerRadius = 25;
//        _setBtn.layer.borderWidth = 1.0f;
//        _setBtn.layer.borderColor = HEXCOLOR(0x518FFF).CGColor;
        @weakify(self)
        [[_setBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.modifyBlock) {
                self.modifyBlock(x.selected);
            }
        }];
    }
    return _setBtn;
}

- (void)dealloc {
}
@end
