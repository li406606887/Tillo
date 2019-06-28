//
//  WaitingAcceptView.m
//  T-Shion
//
//  Created by together on 2018/9/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "WaitingAcceptView.h"
#import "ARTCVideoChatViewController.h"
#import "TSSoundManager.h"

@interface WaitingAcceptView()
@property (strong, nonatomic) TSButton *acceptButton;//接受
@property (strong, nonatomic) TSButton *refusedButton;//拒绝
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *title;
@property (copy, nonatomic) NSString *type;//0音频 1视频
@property (strong, nonatomic) FriendsModel *friendModel;
@property (copy, nonatomic) NSString *room;
@property (strong, nonatomic) NSArray *receivers;
@end

@implementation WaitingAcceptView

- (instancetype)initWithData:(NSDictionary *)data {
    self = [self init];
    if (self) {
        self.backgroundColor = RGB(30, 30, 30);
        self.frame = [UIScreen mainScreen].bounds;
        self.room = [data objectForKey:@"roomId"];
        self.receivers = [data objectForKey:@"receivers"];
        self.type = [data objectForKey:@"type"];
        if ([self.type isEqualToString:@"video"]) {
            self.title.text = @"视频通话";
        }else if ([self.type isEqualToString:@"audio"]) {
            self.title.text = @"音频通话";
        }
        self.friendModel = [FMDBManager selectFriendTableWithUid:[data objectForKey:@"sender"]];
        [self addSubview:self.title];
        [self addSubview:self.headIcon];
        [self addSubview:self.name];
        [self addSubview:self.acceptButton];
        [self addSubview:self.refusedButton];
        @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"roomRequestFeedback" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self)
            [self refusedAnimate];
        }];
        
    }
    return self;
}

- (void)dealloc {
    [[TSSoundManager sharedManager] stop];
}

- (void)layoutSubviews {
    [@[self.refusedButton,self.acceptButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).with.offset(-20);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.mas_bottom).with.offset(-20);
        }
        make.height.offset(80);
    }];
    
    CGFloat padding2 = (SCREEN_WIDTH - 80*2)/3;
    [@[self.refusedButton,self.acceptButton] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:80 leadSpacing:padding2 tailSpacing:padding2];
    
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_offset(CGSizeMake(140, 140));
    }];
    
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.headIcon.mas_top).with.offset(-20);
        make.size.mas_offset(CGSizeMake(300, 40));
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).with.offset(20);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.mas_top).with.offset(20);
        }
        make.size.mas_offset(CGSizeMake(300, 40));
    }];
    [super layoutSubviews];
}

- (void)refused {
    [self refusedCommand];
    [self refusedAnimate];
    [[TSSoundManager sharedManager] stop];
}

- (void)refusedAnimate {
    @weakify(self)
    [UIView animateWithDuration:0.4f animations:^{
        @strongify(self)
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        @strongify(self)
        [self removeFromSuperview];
    }];
}

- (void)accept {
   
    [self removeFromSuperview];
//    ARTCVideoChatViewController *login = [[ARTCVideoChatViewController alloc] initWithType:self.type style:self.type room:self.room];
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:login animated:YES completion:^{
//        [self removeFromSuperview];
//    }];
}

- (void)refusedCommand {
//    请求参数 {"type":"video","receivers":[12345],"chatType":"single","sender":45678,"roomId":123456}
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.type forKey:@"type"];//类型音频 视频
    [param setObject:@"false" forKey:@"receivers"];//receivers
    [param setObject:@"single" forKey:@"chatType"];//chatType
    [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];//sender
    [param setObject:self.room forKey:@"roomId"];//roomId
    [[SocketViewModel shared].postCancelRTCCommand execute:param];
}

- (TSButton *)acceptButton {
    if (!_acceptButton) {
        _acceptButton = [[TSButton alloc] init];
        [_acceptButton.titleLabel setText:@"接受"];
        [_acceptButton.icon setImage:[UIImage imageNamed:@"Video_Menu_accept"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(accept)];
        [_acceptButton addGestureRecognizer:tap];
    }
    return _acceptButton;
}

- (TSButton *)refusedButton {
    if (!_refusedButton) {
        _refusedButton = [[TSButton alloc] init];
        [_refusedButton.titleLabel setText:@"拒绝"];
        [_refusedButton.icon setImage:[UIImage imageNamed:@"Video_Menu_Refused"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refused)];
        [_refusedButton addGestureRecognizer:tap];
    }
    return _refusedButton;
}

- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
        _headIcon.layer.cornerRadius = 70;
        _headIcon.layer.masksToBounds = YES;
//        _headIcon.contentMode = UIViewContentModeScaleAspectFit;
        NSString *imagePath = [[[TShionSingleCase shared].doucumentPath stringByAppendingPathComponent:@"Head"] stringByAppendingPathComponent:[NSString stringWithFormat:@"head_%@.jpg",self.friendModel.ID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            _headIcon.image = [UIImage imageWithContentsOfFile:imagePath];
        }else {
            [_headIcon sd_setImageWithURL:[NSURL URLWithString:self.friendModel.avatar] placeholderImage:[UIImage imageNamed:@"Avatar_Deafult"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
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
        _name.text = self.friendModel.showName;
        _name.textAlignment = NSTextAlignmentCenter;
    }
    return _name;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:26];
        _title.textColor = [UIColor whiteColor];
        _title.textAlignment = NSTextAlignmentLeft;
    }
    return _title;
}
@end
