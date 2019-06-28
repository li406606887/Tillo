//
//  SingleChatNavigationView.m
//  T-Shion
//
//  Created by together on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ChatTitleView.h"
#import "NSString+Storage.h"

@interface ChatTitleView()
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *headView;
@property (assign, nonatomic) CGSize intrinsicContentSize;
@property (strong, nonatomic) UIButton *leftButton;
@property (nonatomic, strong) UIImageView *disturbView;
@property (assign, nonatomic) BOOL show;

//add by chw 2019.04.18 for Encryption
@property (strong, nonatomic) UIImageView *lockView;
@end

@implementation ChatTitleView
- (instancetype)initWithFrame:(CGRect)frame headIcon:(BOOL)isShow {
    self = [super initWithFrame:frame];
    if (self) {
        self.show = isShow;
        [self addSubview:self.leftButton];
        [self addSubview:self.headView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.disturbView];
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints {
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(30);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headView.mas_right).with.offset(10);
        make.centerY.equalTo(self.mas_centerY);
        make.right.lessThanOrEqualTo(self.mas_right).with.offset(-20);
    }];
    
    [self.disturbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel.mas_centerY);
        make.left.equalTo(self.nameLabel.mas_right).with.offset(5).with.priorityHigh();
    }];
}

- (CGSize)intrinsicContentSize {
    return self.frame.size;
}

- (void)setModel:(FriendsModel *)model {
    [self.model removeObserver:self forKeyPath:@"showName"];
    [self.model removeObserver:self forKeyPath:@"avatar"];
    _model = model;
    _disturbView.hidden = YES;
    
    NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:model.userId];
    
    [TShionSingleCase loadingAvatarWithImageView:self.headView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:model.avatar] filePath:imagePath];

    self.nameLabel.text = model.showName;
    
    [self.model addObserver:self forKeyPath:@"showName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.model addObserver:self forKeyPath:@"avatar" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)setGroup:(GroupModel *)group {
    [self.group removeObserver:self forKeyPath:@"name"];
    _group = group;
    
    [self.group addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    int memberCount = [self getGroupCountWithRoomId:self.group.roomId];
    if (memberCount < 1) {
        memberCount = group.memberCount;
    }
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@(%d)",group.name,memberCount];
    
//    NSString *imagePath = [[TShionSingleCase groupHeadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"GroupHead_%@.jpg",group.roomId]];
    
    NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:group.roomId];
    
    [TShionSingleCase loadingGroupAvatarWithImageView:self.headView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:group.avatar] filePath:imagePath];
    
    BOOL state = [FMDBManager selectedRoomDisturbWithRoomId:group.roomId];
    _disturbView.hidden = !state;
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"groupMemberCountChange" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            int count = [self getGroupCountWithRoomId:self.group.roomId];
            if (count<1) {
                count = group.memberCount;
            }
            self.nameLabel.text = [NSString stringWithFormat:@"%@(%d)",self.group.name,count];
        });
    }];
}

- (void)refreshDisturbState {
    BOOL state = [FMDBManager selectedRoomDisturbWithRoomId:self.group.roomId];
    _disturbView.hidden = !state;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"showName"]) {
        self.nameLabel.text = self.model.showName;
    } else if ([keyPath isEqualToString:@"name"]) {
        int count = [self getGroupCountWithRoomId:self.group.roomId];
        self.nameLabel.text = [NSString stringWithFormat:@"%@(%d)",self.group.name,count];
    } else if ([keyPath isEqualToString:@"avatar"]) {
        NSString *imagePath = [TShionSingleCase thumbAvatarImgPathWithUserId:self.model.userId];
        
        [TShionSingleCase loadingAvatarWithImageView:self.headView url:[NSString ym_thumbAvatarUrlStringWithOriginalString:self.model.avatar] filePath:imagePath];
    }
}

#pragma mark - getter
- (UIImageView *)headView {
    if (!_headView) {
        _headView = [[UIImageView alloc] init];
        _headView.layer.cornerRadius = 15;
        _headView.clipsToBounds = YES;
        _headView.userInteractionEnabled = YES;
        
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[[tap rac_gestureSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.infoClick) {
                self.infoClick();
            }
        }];
        [_headView addGestureRecognizer:tap];
    }
    return _headView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel constructLabel:CGRectZero
                                        text:nil
                                        font:[UIFont ALBoldFontSize18]
                                   textColor:[UIColor ALTextDarkColor]];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.userInteractionEnabled = YES;

        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[[tap rac_gestureSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.infoClick) {
                self.infoClick();
            }
        }];
        
        [_nameLabel addGestureRecognizer:tap];
    }
    return _nameLabel;
}

- (UIButton *)leftButton {
    if (!_leftButton) {

        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftButton setImage:[UIImage imageNamed:@"NavigationBar_Back"] forState:UIControlStateNormal];//设置左边按钮的图片
        _leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
        @weakify(self)
        [[_leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
           @strongify(self)
            if (self.backClick) {
                self.backClick();
            }
        }];
    }
    return _leftButton;
}

- (UIImageView *)disturbView {
    if (!_disturbView) {
        _disturbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"session_disturb"]];
        _disturbView.hidden = YES;
    }
    return _disturbView;
}

- (void)dealloc {
    if (self.model) {
        [self.model removeObserver:self forKeyPath:@"showName"];
    } else if(self.group) {
        [self.group removeObserver:self forKeyPath:@"name"];
        
    }
}

//add by chw 2019.04.18 for Encryption
- (UIImageView *)lockView {
    if (!_lockView) {
        _lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crypt_lock"]];
    }
    return _lockView;
}

- (void)setShowLock:(BOOL)showLock {
    _showLock = showLock;
    if (showLock) {
        [self addSubview:self.lockView];
        [self.lockView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headView.mas_right).with.offset(10);
            make.centerY.equalTo(self.nameLabel.mas_centerY);
        }];
        self.nameLabel.textColor = [UIColor ALLockColor];
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headView.mas_right).with.offset(10+self.lockView.width+6);
        }];
    }
}

- (int)getGroupCountWithRoomId:(NSString *)roomId {
    if (roomId) {
        int count = [FMDBManager selectedMemberCountWithRoomId:roomId];
        return count;
    }else {
        return 0;
    }
}
@end
