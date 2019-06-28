//
//  AudioView.m
//  T-Shion
//
//  Created by together on 2018/9/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AudioView.h"
#import "VideoChatViewModel.h"

@interface AudioView()
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *connectTime;
@property (strong, nonatomic) FriendsModel *model;
@property (weak, nonatomic) VideoChatViewModel *viewModel;
@end

@implementation AudioView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (VideoChatViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.headIcon];
    [self addSubview:self.name];
}

- (void)layoutSubviews {
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_offset(CGSizeMake(140, 140));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.headIcon.mas_top).with.offset(10);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 40));
    }];
    [super layoutSubviews];
}


- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.timerSecondSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        int secondCount = [x intValue];
        int second = secondCount % 60;
        int min = secondCount % 360;
        int hour = secondCount / 360;
        self.connectTime.text = [NSString stringWithFormat:@"通话时长:%d:%d:%d",hour,min,second];
    }];
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
        _headIcon.layer.cornerRadius = 70;
        _headIcon.layer.masksToBounds = YES;
//        _headIcon.contentMode = UIViewContentModeScaleAspectFit;
        NSString *imagePath = [[[TShionSingleCase shared].doucumentPath stringByAppendingPathComponent:@"Head"] stringByAppendingPathComponent:[NSString stringWithFormat:@"head_%@.jpg",self.viewModel.friendModel.ID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            _headIcon.image = [UIImage imageWithContentsOfFile:imagePath];
        }else {
            [_headIcon sd_setImageWithURL:[NSURL URLWithString:self.viewModel.friendModel.avatar] placeholderImage:[UIImage imageNamed:@"Avatar_Deafult"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error == nil) {
                    NSData *data = UIImageJPEGRepresentation(image, 1);//指定新建文件夹路径
                    BOOL result = [data writeToFile:imagePath atomically:YES];
                    if (result) {
                        NSLog(@"文件写入成功");
                    }
                }else {
                    NSLog(@"图片加载失败");
                }
            }];
        }
    }
    return _headIcon;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont systemFontOfSize:26];
        _name.textColor = [UIColor whiteColor];
        _name.text = self.model.showName;
    }
    return _name;
}

- (UILabel *)connectTime {
    if (!_connectTime) {
        _connectTime = [[UILabel alloc] init];
        _connectTime.font = [UIFont systemFontOfSize:26];
        _connectTime.textColor = [UIColor whiteColor];
    }
    return _connectTime;
}
@end
