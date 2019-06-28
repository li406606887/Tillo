//
//  GroupMessageRoomController.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupMessageRoomController.h"
#import "GroupMessageRoomViewModel.h"
#import "GroupMessageRoomView.h"
#import "GroupSetingViewController.h"
#import "MessageModel.h"
#import "ChatTitleView.h"

#import "OtherInformationViewController.h"
#import "StrangerViewController.h"
#import "CreatGroupRoomController.h"
#import "AddMemberViewController.h"
#import "GroupMemberTableView.h"
#import "MessageRoomViewController.h"
#import "WebLinkViewController.h"
#import "DownFileViewController.h"
#import "TransmitViewController.h"

#import "AddFriendsModel.h"

#import "SendInviteMsgController.h"

@interface GroupMessageRoomController ()
@property (strong, nonatomic) GroupMessageRoomViewModel *viewModel;
@property (strong, nonatomic) ChatTitleView *navigationView;
@property (strong, nonatomic) GroupMessageRoomView *mainView;
@property (copy, nonatomic) GroupModel *model;
@property (nonatomic, assign) BOOL hadLoadDraft;

@end

@implementation GroupMessageRoomController
- (instancetype)initWithModel:(GroupModel *)model count:(int)count type:(RefreshMessageType)type {
    
    return [self initWithModel:model count:count type:type isCrypt:NO];
}
- (instancetype)initWithModel:(GroupModel *)model count:(int)count type:(RefreshMessageType)type isCrypt:(BOOL)isCrypt {
    if (self = [super init]) {
        _model = model;
        if (type == Loading_HAVE_NEW_MESSAGES) {
            self.viewModel.unreadCount = count;
        }else {
            [FMDBManager ChangeAllMessageReadStatusWithRoomId:self.model.roomId];
        }
        self.viewModel.type = type;
        self.viewModel.msgCount = count;
        self.viewModel.groupModel = model;
        self.viewModel.isCrypt = model.isCrypt ? YES : isCrypt;
        [SocketViewModel shared].room = model.roomId;
        [self.view addSubview:self.mainView];
        [self loadingViewWithModel:model];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItems = @[[self creatBarButtonItemWithImage:@"Group_look_member" tag:0]];
    if (self.viewModel.isCrypt) {
        @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self)
            [self.viewModel sendScreenShotMessage];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    self.navigationItem.leftBarButtonItem = [self leftButton];
    self.navigationView.group = self.viewModel.groupModel;
    //add by chw 2019.5.30 for ‘加密群聊’
    self.navigationView.showLock = self.viewModel.isCrypt;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mainView stopAudioPlay];
    [FMDBManager clearMessageUnreadCountWithRoomId:self.model.roomId];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.hadLoadDraft) {
        [self.mainView loadDraftData];
        self.hadLoadDraft = YES;
    }
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.clickHeadIconSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        MemberModel *member = [self.viewModel.members objectForKey:x];
        [self itemClickWithPrarm:member];
    }];
    
    [[self.viewModel.messageClickUrlSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        WebLinkViewController *link = [[WebLinkViewController alloc] init];
        link.url = (NSURL *)x;
        [self.navigationController pushViewController:link animated:YES];
    }];
    
    [[[SocketViewModel shared].reconnectGetNetDataSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([SocketViewModel shared].room == self.model.roomId) {
            [self.viewModel.getMemberCommand execute:@{@"roomId":self.model.roomId}];
            [[SocketViewModel shared] getGroupChatOfflineMessageWithParam:@{@"roomId":self.model.roomId}];
        }
    }];
    
    [[[self.viewModel.messageClickFileSubject takeUntil:self.rac_willDeallocSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        DownFileViewController *downFile = [[DownFileViewController alloc] initWithMessage:x];
        [self.navigationController pushViewController:downFile animated:YES];
    }];

    //add by chw for transmit message 2019.2.27
    [[self.viewModel.messageTransmitSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        TransmitViewController *controller = [[TransmitViewController alloc] init];
        controller.completeBlock = ^(NSArray *selectArray) {
            if (![x isKindOfClass:[MessageModel class]])
                return;
            for (id m in selectArray) {
                MessageModel *model = [x copy];
                NSString *originFilePath;
                NSString *videoIMGPath;
                
                if (model.msgType != MESSAGE_TEXT || model.msgType != MESSAGE_RTC) {
                    originFilePath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
                    
                    if (model.msgType == MESSAGE_Video && model.videoIMGName.length > 0) {
                        videoIMGPath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.videoIMGName];
                    }
                }
                
                if ([m isKindOfClass:[FriendsModel class]]) {
                    FriendsModel *friend = m;
                    model.roomId = friend.roomId;
                    model.receiver = friend.userId;
                }
                else if ([m isKindOfClass:[GroupModel class]]) {
                    GroupModel *group = m;
                    if ([group.roomId isEqualToString:self.viewModel.groupModel.roomId]) {
                        [self.viewModel sendMessageWithModel:model];
                        continue;
                    }
                    model.roomId = group.roomId;
                    model.receiver = nil;
                }
                
                if (originFilePath.length>10) {
                    NSLog(@"%@",originFilePath);
                    NSData *data = [NSData dataWithContentsOfFile:originFilePath];
                    NSString *newFilePath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
                    [data writeToFile:newFilePath atomically:YES];
                }
                
                if (videoIMGPath.length > 10) {
                    NSData *videoIMGData = [NSData dataWithContentsOfFile:videoIMGPath];
                    NSString *videoIMGPath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.videoIMGName];
                    
                    if (videoIMGData) {
                        [videoIMGData writeToFile:videoIMGPath atomically:YES];
                    }
                }
                
                model.sender = [SocketViewModel shared].userModel.ID;
                model.sendStatus = @"3";
                [self.viewModel transmitMessageWithModel:model];
            }
        };
        BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:controller];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }];
    
    [[self.viewModel.refreshTableSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        //更新成员后刷新
        if ([x integerValue] == REFRESH_Table_MESSAGES) {
            self.navigationView.group = self.viewModel.groupModel;
        }
    }];
    
    [[self.viewModel.sendMsgSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        FriendsModel *fm = [FMDBManager selectFriendTableWithUid:x];
        int unReadCount = [FMDBManager selectUnreadCountWithRoomId:fm.roomId];
        int count = unReadCount < 1 ? 20 : unReadCount;
        RefreshMessageType type = unReadCount>0 ? Loading_HAVE_NEW_MESSAGES: Loading_NO_NEW_MESSAGES;
        MessageRoomViewController *msgVc = [[MessageRoomViewController alloc] initWithModel:fm count:count type:type];
        [self.navigationController pushViewController:msgVc animated:YES];
    }];
    
    [[self.viewModel.addFriendSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        AddFriendsModel *model = [[AddFriendsModel alloc] init];
        model.uid = (NSString *)x;
        SendInviteMsgController *sendInvite = [[SendInviteMsgController alloc] init];
        sendInvite.viewModel.model = model;
        sendInvite.isNavPop = YES;
        [self.navigationController pushViewController:sendInvite animated:YES];
    }];
}

- (void)popViewController{
    NSInteger count = self.navigationController.childViewControllers.count;
    if (count<2) {
        return;
    }
    BaseViewController *vc = self.navigationController.childViewControllers[count - 2];
    if ([vc isKindOfClass:[CreatGroupRoomController class]]) {
        BaseViewController *vc = self.navigationController.childViewControllers[count - 3];
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)loadingViewWithModel:(GroupModel *)model {
    if (model.roomId) {
        [self.viewModel.getMemberCommand execute:@{@"roomId":self.model.roomId}];
        [self.viewModel getLocationHistoryMessage];
        [FMDBManager clearMessageUnreadCountWithRoomId:model.roomId];
        [[SocketViewModel shared] getGroupChatOfflineMessageWithParam:@{@"roomId":model.roomId}];
    }
    
//    self.navigationView.group = model;
}


- (UIBarButtonItem *)leftButton {
    return [[UIBarButtonItem alloc] initWithCustomView:self.navigationView];
}

- (CGSize )getNavgationTitleSizeWithName:(NSString *)name {
    CGSize size = [NSString getStringSizeWithString:name maxSize:CGSizeMake(MAXFLOAT, 18) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    if (size.width>140) {
        size.width = 140;
    }
    return size;
}

#pragma mark 查看其他人的信息
- (void)lookOtherUserInfo {
    GroupSetingViewController *seting = [[GroupSetingViewController alloc] initWithModel:self.model data:self.viewModel.members];
    [self.navigationController pushViewController:seting animated:YES];
}
#pragma mark 查看群成员
- (void)lookAtMember {
    if (![self.viewModel.groupModel.deflag isEqualToString:@"1"]) {
        [self.mainView endEditing:YES];
        @weakify(self)
        GroupMemberTableView *groupMember = [[GroupMemberTableView alloc] initWithFrame:[UIScreen mainScreen].bounds roomId:self.viewModel.groupModel.roomId array:[self.viewModel.members allValues]];
        groupMember.itemCellClick = ^(id data) {
            @strongify(self)
            if (data) {
                [self.viewModel.clickHeadIconSubject sendNext:data];
            }
        };
        groupMember.sendMessageClick = ^(id data) {
            @strongify(self)
            FriendsModel *friend = (FriendsModel *)data;
            MessageRoomViewController *message = [[MessageRoomViewController alloc] initWithModel:friend count:20 type:Loading_NO_NEW_MESSAGES];
            [self.navigationController pushViewController:message animated:YES];
            
        };
        [[UIApplication sharedApplication].keyWindow addSubview:groupMember];
    }
}
#pragma mark 添加导航栏右侧按钮
- (UIBarButtonItem *)creatBarButtonItemWithImage:(NSString *)image tag:(int)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    button.tag = tag;
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        switch (x.tag) {
            case 0: {
                [self lookAtMember];
            }
                break;
            default:
                break;
        }
    }];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)itemClickWithPrarm:(id)param {
    MemberModel *member = (MemberModel *)param;
    if (![member.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
        if (member.isHad==0) {
            OtherInformationViewController *other = [[OtherInformationViewController alloc] init];
            other.model = (FriendsModel*)member;
            [self.navigationController pushViewController:other animated:YES];
        }else {
            AddFriendsModel *addModel = [[AddFriendsModel alloc] init];
            addModel.name = member.name;
            addModel.avatar = member.avatar;
            addModel.uid = member.userId;
            addModel.mobile = member.name;
            StrangerViewController *stranger = [[StrangerViewController alloc] init];
            stranger.model = addModel;
            stranger.isNavPop = YES;
            [self.navigationController pushViewController:stranger animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (GroupMessageRoomViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GroupMessageRoomViewModel alloc] init];
    }
    return _viewModel;
}

- (GroupMessageRoomView *)mainView {
    if (!_mainView) {
        _mainView = [[GroupMessageRoomView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (ChatTitleView *)navigationView {
    if (!_navigationView) {
        CGFloat width = SCREEN_WIDTH - (20.0 + 12.0 + 16.0 + 80);
        _navigationView = [[ChatTitleView alloc] initWithFrame:CGRectMake(0, 0, width, 30) headIcon:NO];
        @weakify(self)
        _navigationView.backClick = ^{
            @strongify(self)
            [self popViewController];
        };
        _navigationView.infoClick = ^{
            @strongify(self)
            if (![self.viewModel.groupModel.deflag isEqualToString:@"1"]) {
                [self lookOtherUserInfo];
            }
        };
    }
    return _navigationView;
}

- (void)dealloc {
    [FMDBManager ChangeAllMessageReadStatusWithRoomId:self.viewModel.groupModel.roomId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].enable = YES;
    [SocketViewModel shared].room = @"";
    self.navigationView = nil;
    self.viewModel = nil;
    self.mainView = nil;
}
@end
