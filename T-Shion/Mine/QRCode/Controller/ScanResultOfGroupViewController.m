//
//  ScanResultOfGroupViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/4/26.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ScanResultOfGroupViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface ScanResultOfGroupViewController ()

@property (nonatomic, assign) ScanResultOfGroupType type;

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *joinBtn;

@property (nonatomic, strong) NSDictionary *resultData;

@end

@implementation ScanResultOfGroupViewController


- (instancetype)initWithType:(ScanResultOfGroupType)type resultData:(id)resultData {
    if (self = [super init]) {
        _type = type;
        _resultData = resultData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    [self.view addSubview:self.avatarView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.joinBtn];
    
    if (self.type == ScanResultOfGroupTypeDefault) {
        self.title = Localized(@"scan_group_info");
        self.joinBtn.hidden = NO;
        self.avatarView.layer.cornerRadius = 75;
        
        NSString *avatarURL = @"";
        if ([_resultData[@"avatar"] isKindOfClass:[NSNull class]]) {
            avatarURL = @"";
        } else {
            avatarURL = _resultData[@"avatar"];
        }
        
        
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"Group_Deafult_Avatar"]];
        
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",_resultData[@"name"],_resultData[@"memberCount"]];
        
    } else {
        self.avatarView.layer.cornerRadius = 50;
        self.avatarView.image = [UIImage imageNamed:@"public_scan_result_error"];
        self.titleLabel.textColor = RGB(255, 99, 121);
        switch (self.type) {
            case ScanResultOfGroupTypeVerify:
                self.titleLabel.text = Localized(@"scan_group_tip_verify");
                break;
            
            case ScanResultOfGroupTypePastDue:
                self.titleLabel.text = Localized(@"scan_group_tip_pastDue");
                break;
                
            case ScanResultOfGroupTypeLeave:
                self.titleLabel.text = Localized(@"scan_group_tip_leave");
                break;
                
            default:
                break;
        }
        
        [self setUpNavtionLeft];
    }
}

- (void)setUpNavtionLeft {
    self.fd_interactivePopDisabled = YES;
    NSString *imageName = @"navigation_close";
    
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    backBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        spaceRight.width = -100;
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        
        spaceLeft.width = -25;
        backBtn.imageInsets = UIEdgeInsetsMake(0, 22, 0, -22);
        spaceRight.width = 15;
        self.navigationItem.leftBarButtonItems = @[spaceLeft, backBtn, spaceRight];
    }
}

- (void)backButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews {
    if (self.type == ScanResultOfGroupTypeDefault) {
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(150, 150));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).with.offset(50);
        }];
        
    } else {
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).with.offset(120);
        }];
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView.mas_bottom).with.offset(30);
        make.left.equalTo(self.view.mas_left).with.offset(30);
        make.right.equalTo(self.view.mas_right).with.offset(-30);
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 40));
        make.centerX.equalTo(self.avatarView.mas_centerX);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(110);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)joinBtnClick {
    LoadingView(@"");
    
    NSMutableDictionary *joinGroupParams = [NSMutableDictionary dictionary];
    [joinGroupParams setObject:self.resultData[@"roomId"] forKey:@"roomId"];
    [joinGroupParams setObject:self.resultData[@"random"] forKey:@"random"];
    [joinGroupParams setObject:self.resultData[@"createUserId"] forKey:@"createUserId"];
    [joinGroupParams setObject:@"true" forKey:@"isJoin"];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        RequestModel *model = [TSRequest getRequetWithApi:api_get_groupQrCode_join withParam:joinGroupParams error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            HiddenHUD
            if (!error) {
                [self joinGroupSuccess:model.data];
            }else {
                if (model!=nil) {
                    if (model.message.length>0) {
                        ShowWinMessage(model.message);
                    }
                }
            }
        });
    });
}

- (void)joinGroupSuccess:(NSDictionary *)data {
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setObject:data[@"roomId"] forKey:@"roomId"];
    [msgDict setObject:[NSDate getNowTimestamp] forKey:@"timestamp"];
    [msgDict setObject:[NSUUID UUID].UUIDString forKey:@"messageId"];
    [msgDict setObject:data[@"name"] forKey:@"groupName"];
    [msgDict setObject:@"scan_group_join" forKey:@"operType"];
    [msgDict setObject:@"system" forKey:@"type"];
    [msgDict setObject:@"group" forKey:@"chatType"];
    [msgDict setObject:@"groupOper" forKey:@"route"];
    BOOL isCrypt = NO;
    if ([data objectForKey:@"isEncryptGroup"]) {
        isCrypt = [[data objectForKey:@"isEncryptGroup"] boolValue];
        [msgDict setObject:[data objectForKey:@"isEncryptGroup"] forKey:@"isCryptoMessage"];
        [msgDict setObject:data[@"userIds"] forKey:@"userIds"];
    }
    NSString *membersStr = @"";
    NSArray *members = data[@"userNames"];
    for (NSInteger i = 0; i < members.count; i++) {
        if (i == members.count - 1) {
            membersStr = [membersStr stringByAppendingString:members[i]];
        } else {
            NSString *tempStr = [NSString stringWithFormat:@"%@、",members[i]];
            membersStr = [membersStr stringByAppendingString:tempStr];
            
        }
    }
    
    NSString *contentStr = isCrypt ? [NSString stringWithFormat:Localized(@"crypt_scan_group_self_join_tip"),membersStr] :
    [NSString stringWithFormat:Localized(@"scan_group_self_join_tip"),membersStr];
    [msgDict setObject:contentStr forKey:@"content"];
    
    [[SocketViewModel shared] dealSystemMessageWithDictionary:msgDict way:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - getter
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectZero
                                         text:nil
                                         font:[UIFont ALFontSize18]
                                    textColor:[UIColor ALTextDarkColor]];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIButton *)joinBtn {
    if (!_joinBtn) {
        _joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinBtn setTitle:Localized(@"scan_group_join") forState:UIControlStateNormal];
        [_joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_joinBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALKeyColor]] forState:UIControlStateNormal];
        _joinBtn.layer.masksToBounds = YES;
        _joinBtn.layer.cornerRadius = 20;
        _joinBtn.hidden = YES;
        [_joinBtn addTarget:self action:@selector(joinBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinBtn;
}

@end
