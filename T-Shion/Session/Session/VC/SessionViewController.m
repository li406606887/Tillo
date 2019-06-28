//
//  DialogueViewController.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SessionViewController.h"
#import "SessionViewModel.h"
#import "SessionView.h"
#import "MessageRoomViewController.h"
#import "AddFriendsViewController.h"
#import "CreatGroupRoomController.h"
#import "GroupMessageRoomController.h"
#import "ScanViewController.h"
#import "SearchFriendViewController.h"
#import "ALSlideMenu.h"
#import "FTPopOverMenu.h"


//add by chw 2019.04.19 for Encryption
#import "YMEncryptionManager.h"
#import "SelectFriendViewController.h"

#import "LookForFileViewController.h"


@interface SessionViewController ()
@property (strong, nonatomic) SessionViewModel *viewModel;
@property (strong, nonatomic) SessionView *mainView;
@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) UIButton *searchView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *titleView;


@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add by chw 2019.04.15 for encryption
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [[YMEncryptionManager shareManager] setUserID:userID];
    //判断有没有上传成功公钥信息，要重新上传
    if (![[YMEncryptionManager shareManager] hadUploadPublicKey])
        [[YMEncryptionManager shareManager] uploadKeyAfterLogin];
    else {
        //已经上传成功的要判断是否需要补充一次性密钥
        [[YMEncryptionManager shareManager] supplementOneTimeKey];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [[SocketViewModel shared].getUnreadSessionSubject sendNext:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.sessionCellClickSubject subscribeNext:^(id  _Nullable x) {
        SessionModel *model = x;
        int unReadCount = [FMDBManager selectUnreadCountWithRoomId:model.roomId];
        int count = unReadCount < 1 ? 20 : unReadCount;
        RefreshMessageType type = unReadCount>0 ? Loading_HAVE_NEW_MESSAGES: Loading_NO_NEW_MESSAGES;
        if (model.model) {
            MessageRoomViewController *single = [[MessageRoomViewController alloc] initWithModel:model.model count:count type:type isCrypt:model.isCrypt];
            [self.navigationController pushViewController:single animated:YES];
        }else {
            GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:model.group count:count type:type isCrypt:model.isCrypt];
            [self.navigationController pushViewController:group animated:YES];
        }
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ShowUnreadMsg" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        int count = [FMDBManager getMessageUnreadCount];
        
        NSInteger sessionUnreadCount = [FMDBManager getSessionUnreadCount];

        if (count>0) {
            self.tabBarItem.badgeValue = sessionUnreadCount > 99 ? @"99+": [NSString stringWithFormat:@"%ld",(long)sessionUnreadCount];
            [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:@"PushBadgeCount"];
            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        }else {
            self.tabBarItem.badgeValue = nil;
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"PushBadgeCount"];
        }
    }];
    
    [[self.viewModel.scrollSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        CGFloat offset = [x floatValue];

        if (offset >= 50) {
            self.searchView.alpha = 0;
            self.titleLabel.alpha = 1;
            [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[UIColor ALLineColor] size:CGSizeMake(SCREEN_WIDTH, .5)]];
        } else {
            self.searchView.alpha = (50 - offset)/50;
            self.titleLabel.alpha = (offset)/50;
            [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        }
    }];
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
    [self setUpNavtionLeft];
    [self setRightNavigation];
}

- (UIView *)centerView {
    return self.titleView;
}

- (void)setUpNavtionLeft {
    
    NSString *imageName = @"navigation_slide";
    
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
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

- (void)setRightNavigation {
    
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.addBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}

- (void)leftButtonClick {
    [self.al_sldeMenu showLeftViewControllerAnimated:YES];
}

- (void)addBtnClick:(UIButton *)addbtn {
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuRowHeight = 50;
    configuration.menuIconMargin = 16;
    configuration.menuTextMargin = 10;
    configuration.textColor = [UIColor whiteColor];
    configuration.textFont = [UIFont ALBoldFontSize14];
    configuration.tintColor = RGB(105, 107, 106);
    configuration.borderColor = [UIColor ALLineColor];
    configuration.borderWidth = 0.5;
    configuration.textAlignment = NSTextAlignmentLeft;
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
    if ([value isEqualToString:@"zh-Hans"]) {
        configuration.menuWidth = 150;
    } else {
        configuration.menuWidth = 220;
    }
    //暂时屏蔽掉加密群聊入口
    @weakify(self);
    [FTPopOverMenu showForSender:addbtn
                   withMenuArray:@[Localized(@"friend_add_friend_title"),
                                   Localized(@"New_group_chat"),
                                   Localized(@"scan_title"),
                                   Localized(@"crypt_create_single"),
                                   Localized(@"crypt_create_group")]
                      imageArray:@[@"public_menu_addFriend",
                                   @"public_menu_groupChat",
                                   @"public_menu_scan",
                                   @"start_crypt_single",
                                   @"start_crypt_group"]
                       doneBlock:^(NSInteger selectedIndex) {
       @strongify(self)
       switch (selectedIndex) {
           case 0: {
               AddFriendsViewController *searchVC = [[AddFriendsViewController alloc] init];
               searchVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
               BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:searchVC];
               [self presentViewController:nav animated:YES completion:nil];
           }
               break;
           case 1: {
               CreatGroupRoomController *group = [[CreatGroupRoomController alloc] init];
               [self.navigationController pushViewController:group animated:YES];
           }
               break;
           case 2: {
               ScanViewController *scanVC = [[ScanViewController alloc] init];
               [self.navigationController pushViewController:scanVC animated:YES];
           }
               break;
           case 3: {//发起加密单聊
               SelectFriendViewController *controller = [[SelectFriendViewController alloc] init];
               [self.navigationController pushViewController:controller animated:YES];
           }
               break;
           case 4: {//发起加密群聊
               CreatGroupRoomController *group = [[CreatGroupRoomController alloc] init];
               group.isCrypt = YES;
               [self.navigationController pushViewController:group animated:YES];
           }
               break;
           default:
               break;
       }
    } dismissBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (SessionView *)mainView {
    if (!_mainView) {
        _mainView = [[SessionView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (SessionViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SessionViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"navigation_add"] forState:UIControlStateNormal];
        
        [_addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (UIButton *)searchView {
    if (!_searchView) {
        _searchView = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_searchView setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateNormal];
        
        [_searchView setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateHighlighted];
        
        _searchView.layer.masksToBounds = YES;
        _searchView.layer.cornerRadius = 15;
        _searchView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 120, 30);
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_search"]];
        [_searchView addSubview:searchIcon];
        searchIcon.x = 15;
        searchIcon.centerY = 15;
        
        UILabel *tipLabel = [UILabel constructLabel:CGRectMake(searchIcon.x + searchIcon.width + 4, 0, 200, 20)
                                               text:Localized(@"search_placeholder")
                                               font:[UIFont systemFontOfSize:13]
                                          textColor:[UIColor ALTextGrayColor]];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        [_searchView addSubview:tipLabel];
        tipLabel.centerY = 15;
        
        @weakify(self);
        [[_searchView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            SearchFriendViewController *searchVC = [[SearchFriendViewController alloc] init];
            searchVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:searchVC];
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }
    return _searchView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel constructLabel:CGRectMake(0, 0, SCREEN_WIDTH - 120, 30)
                                         text:Localized(@"home_navigation_title")
                                         font:[UIFont ALBoldFontSize18]
                                    textColor:[UIColor ALTextDarkColor]];
        _titleLabel.alpha = 0;
    }
    return _titleLabel;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 120, 30)];
        [_titleView addSubview:self.titleLabel];
        [_titleView addSubview:self.searchView];
    }
    return _titleView;
}


@end
