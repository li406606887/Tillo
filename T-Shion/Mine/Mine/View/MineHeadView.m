

//
//  MineHeadView.m
//  T-Shion
//
//  Created by together on 2018/6/15.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MineHeadView.h"

@implementation MineHeadView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (MineViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.headBack];
    [self.headBack addSubview:self.headIcon];
    [self addSubview:self.nickName];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    [self.headBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(30);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(70, 70));
    }];
    
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headBack);
    }];
    [self.nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headIcon.mas_bottom).with.offset(10);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(300, 20));
    }];
    
    [super layoutSubviews];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
//        _headIcon.contentMode = UIViewContentModeScaleAspectFit;
        [_headIcon sd_setImageWithURL:[NSURL URLWithString:[SocketViewModel shared].userModel.avatar] placeholderImage:self.defaultImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error == nil) {
                NSData *data = UIImageJPEGRepresentation(image, 1);//指定新建文件夹路径
                BOOL result = [data writeToFile:[TShionSingleCase myThumbAvatarImgPath] atomically:YES];
                if (result) {
                    NSLog(@"存储成功");
                }
            }
        }];
    }
    return _headIcon;
}

- (UIImageView *)headBack {
    if (!_headBack) {
        _headBack = [[UIImageView alloc] init];
        _headBack.layer.masksToBounds = YES;
        _headBack.layer.cornerRadius = 35;
        _headBack.userInteractionEnabled = YES;
        _headBack.image = [UIImage imageNamed:@"Avatar_Deafult"];
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            [self.viewModel.headClickSubject sendNext:nil];
        }];
        [_headBack addGestureRecognizer:tap];
    }
    return _headBack;
}

- (UILabel *)nickName {
    if (!_nickName) {
        _nickName = [[UILabel alloc] init];
        _nickName.font = [UIFont systemFontOfSize:18];
        _nickName.textAlignment = NSTextAlignmentCenter;
        _nickName.text = [SocketViewModel shared].userModel.name;
    }
    return _nickName;
}

- (UIImage *)defaultImage {
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:[TShionSingleCase myThumbAvatarImgPath]];
    if (!isExists) {
        _defaultImage = [UIImage imageNamed:@"Avatar_Deafult"];
    }else {
        _defaultImage = [UIImage imageWithContentsOfFile:[TShionSingleCase myThumbAvatarImgPath]];
    }
    return _defaultImage;
}
@end
