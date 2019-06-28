//
//  DialogueContentViewController.m
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageRoomViewController.h"
#import "MessageRoomView.h"
#import "MessageRoomViewModel.h"
#import "MessageModel.h"
#import "OtherInformationViewController.h"
#import "WebRTCHelper.h"
#import "ChatTitleView.h"
#import "WebLinkViewController.h"
#import "DownFileViewController.h"
#import "TransmitViewController.h"
//add by chw 2019.04.17 for Encryption
#import "YMEncryptionManager.h"
#import "AddFriendsModel.h"

#import "SendInviteMsgController.h"
#import "TSRTCChatViewController.h"
#import "YMRTCBrowser.h"

@interface MessageRoomViewController ()
@property (strong, nonatomic) MessageRoomViewModel *viewModel;
@property (strong, nonatomic) ChatTitleView *navigationView;
@property (strong, nonatomic) MessageRoomView *mainView;
@property (assign, nonatomic) int type;
@property (weak, nonatomic) FriendsModel *model;

@property (nonatomic, assign) BOOL hadLoadDraft;

//add by chw 2019.04.16 for Encryption
@property (nonatomic, assign) BOOL isCrypt;
@property (nonatomic, weak) NSString *roomId;

@end

@implementation MessageRoomViewController

- (instancetype)initWithModel:(FriendsModel *)model count:(int)count type:(RefreshMessageType)type{
    return [self initWithModel:model count:count type:type isCrypt:NO];
}

- (instancetype)initWithModel:(FriendsModel *)model count:(int)count type:(RefreshMessageType)type isCrypt:(BOOL)isCrypt {
    self = [super init];
    if (self) {
        self.viewModel.msgCount = count +10;
        if (type == Loading_HAVE_NEW_MESSAGES) {
            self.viewModel.unreadCount = count;
        }else {
            [FMDBManager ChangeAllMessageReadStatusWithRoomId:self.roomId];
        }
        self.viewModel.type = type;
        self.model = model;
        self.viewModel.friendModel = self.model;
        self.viewModel.isCrypt = isCrypt;
        self.isCrypt = isCrypt;
        if (isCrypt)
            self.roomId = model.encryptRoomID;
        else
            self.roomId = model.roomId;
        [self.view addSubview:self.mainView];
        [self loadingViewWithModel:model];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.isCrypt && self.model.enableEndToEndCrypt) {
        self.navigationItem.rightBarButtonItems = @[[self creatBarButtonItemWithImage:@"Seting_Video_Icon" tag:1],[self creatBarButtonItemWithImage:@"Seting_Calling_Icon" tag:0],[self creatBarButtonItemWithImage:@"crypt_session_start" tag:2]];
    }else {
        self.navigationItem.rightBarButtonItems = @[[self creatBarButtonItemWithImage:@"Seting_Video_Icon" tag:1],[self creatBarButtonItemWithImage:@"Seting_Calling_Icon" tag:0]];
    }
    
    NSLog(@"viewDidLoad titleView.x  = %f",self.navigationItem.titleView.x);
    if (self.isCrypt) {
        @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self)
            [self.viewModel sendScreenShotMessage];
        }];
        if (![[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:self.model.userId]) {
            [[YMEncryptionManager shareManager] getCryptRoomIDWithUserID:self.model.userId complete:^(NSString * _Nonnull cryptRoomID) {
                
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear titleView.x  = %f",self.navigationItem.titleView.x);
    self.navigationItem.leftBarButtonItem = [self leftButton];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.hadLoadDraft) {
        [self.mainView loadDraftData];
        self.hadLoadDraft = YES;
    }
    NSLog(@"viewDidAppear titleView.x  = %f",self.navigationItem.titleView.x);
    [super viewDidAppear:animated];
    [SocketViewModel shared].room = self.roomId;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mainView stopAudioPlay];
    NSLog(@"viewWillDisappear titleView.x  = %f",self.navigationItem.titleView.x);
    [FMDBManager clearMessageUnreadCountWithRoomId:self.roomId];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"viewDidDisappear titleView.x  = %f",self.navigationItem.titleView.x);
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (UIBarButtonItem *)leftButton {
    return [[UIBarButtonItem alloc] initWithCustomView:self.navigationView];
}

- (void)loadingViewWithModel:(FriendsModel *)model {
    [SocketViewModel shared].room = self.roomId;
    if (model.roomId) {
        [[SocketViewModel shared] getSingleChatOfflineMessageWithParam:@{@"roomId":self.roomId}];
        [FMDBManager clearMessageUnreadCountWithRoomId:self.roomId];
        [self.viewModel getLocationHistoryMessage];
    }
    self.navigationView.model = model;
    self.navigationView.showLock = self.isCrypt;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.clickHeadIconSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self lookOtherUserInfo];
    }];
    
    [[self.viewModel.messageClickUrlSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
       @strongify(self)
        WebLinkViewController *link = [[WebLinkViewController alloc] init];
        link.url = (NSURL *)x;
        [self.navigationController pushViewController:link animated:YES];
    }];
    
    [[[SocketViewModel shared].reconnectGetNetDataSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([SocketViewModel shared].room == self.roomId) {
            [[SocketViewModel shared] getSingleChatOfflineMessageWithParam:@{@"roomId":self.roomId}];
        }
    }];
    
    [[self.viewModel.rtcCallSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(MessageModel *msgModel) {
        @strongify(self);
//        NSArray *receiveIDArray = @[self.viewModel.friendModel.userId];
//        RTCChatType chatType;
//        if ([msgModel.type isEqualToString:@"rtc_video"]) {
//            chatType = RTCChatType_Video;
//        } else {
//            chatType = RTCChatType_Audio;
//        }
//
//        UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
//        if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
//            return;
//        }
//
//        TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Caller
//                                                                               chatType:chatType
//                                                                                 roomID:self.roomId
//                                                                         receiveIDArray:receiveIDArray receiveHostURL:nil];
//        chatVC.receiveModel = self.viewModel.friendModel;
//        [topVC presentViewController:chatVC animated:YES completion:nil];
        
        YMRTCChatType chatType;
        if ([msgModel.type isEqualToString:@"rtc_video"]) {
            chatType = YMRTCChatType_Video;
        } else {
            chatType = YMRTCChatType_Audio;
        }

        [self startRTCChatWithType:chatType];
    }];
    
    [[self.viewModel.messageClickFileSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        DownFileViewController *downFile = [[DownFileViewController alloc] initWithMessage:x];
        [self.navigationController pushViewController:downFile animated:YES];
    }];
    
    //add by chw for transmit message 2019.2.27
    [self.viewModel.messageTransmitSubject subscribeNext:^(id  _Nullable x) {
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
                    if ([friend.userId isEqualToString:self.viewModel.friendModel.userId]){
                        [self.viewModel sendMessageWithModel:model];
                        continue;
                    }
                    model.roomId = friend.roomId;
                    model.receiver = friend.userId;
                } else if ([m isKindOfClass:[GroupModel class]]) {
                    GroupModel *group = m;
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
        NSDictionary *dic = [NSString dictionaryWithJsonString:(NSString *)x];
        AddFriendsModel *model = [[AddFriendsModel alloc] init];
        model.uid = dic[@"friendId"];
        model.name = dic[@"name"];
        model.avatar = dic[@"avatar"];
        model.mobile = dic[@"mobile"];
        SendInviteMsgController *sendInvite = [[SendInviteMsgController alloc] init];
        sendInvite.viewModel.model = model;
        sendInvite.isNavPop = YES;
        [self.navigationController pushViewController:sendInvite animated:YES];
    }];
}

- (void)lookOtherUserInfo {
    OtherInformationViewController *info = [[OtherInformationViewController alloc] init];
    info.isCrypt = self.isCrypt;//add by chw 2019.04.18 for Encryption
    info.model = self.viewModel.friendModel;
    [self.navigationController pushViewController:info animated:YES];
}

- (CGSize )getNavgationTitleSizeWithName:(NSString *)name {
    CGSize size = [NSString getStringSizeWithString:name maxSize:CGSizeMake(MAXFLOAT, 18) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    if (size.width>140) {
        size.width = 140;
    }
    return size;
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}
#pragma mark 添加导航栏右侧按钮
- (UIBarButtonItem *)creatBarButtonItemWithImage:(NSString *)image tag:(int)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    button.tag = tag;
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        //**add by chw 2019.04.17 for Encryption
        if (x.tag == 2) {
            [self showCryptRoom];
            return;
        }
        //**end
        self.type = (int)x.tag;
        
//        NSArray *receiveIDArray = @[self.viewModel.friendModel.userId];
//        RTCChatType chatType;
//        if (x.tag == 1) {
//            chatType = RTCChatType_Video;
//        } else {
//            chatType = RTCChatType_Audio;
//        }
//
//        UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
//        if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
//            return;
//        }
//
//        TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Caller
//                                                                               chatType:chatType
//                                                                                 roomID:self.roomId
//                                                                         receiveIDArray:receiveIDArray receiveHostURL:nil];
//
//        chatVC.receiveModel = self.viewModel.friendModel;
//        [topVC presentViewController:chatVC animated:YES completion:nil];
        
        YMRTCChatType chatType;
        chatType = x.tag == 1 ? YMRTCChatType_Video : YMRTCChatType_Audio;
        [self startRTCChatWithType:chatType];
    }];
    
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)showCryptRoom {
    if (self.model.encryptRoomID.length > 0)
    {
        [[YMEncryptionManager shareManager] storeCryptRoomId:self.model.encryptRoomID userId:self.model.userId isSender:YES timeStamp:[[NSDate date] timeIntervalSince1970]];
        MessageRoomViewController *controller = [[MessageRoomViewController alloc] initWithModel:self.model count:20 type:Loading_NO_NEW_MESSAGES isCrypt:YES];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    @weakify(self)
    LoadingView(@"");
    [[YMEncryptionManager shareManager] getCryptRoomIDWithUserID:self.model.userId complete:^(NSString * _Nonnull cryptRoomID) {
        HiddenHUD;
        @strongify(self)
        if (cryptRoomID) {
            self.model.encryptRoomID = cryptRoomID;
            MessageRoomViewController *controller = [[MessageRoomViewController alloc] initWithModel:self.model count:20 type:Loading_NO_NEW_MESSAGES isCrypt:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }];
}

#pragma mark - 发起音视频相关
- (void)startRTCChatWithType:(YMRTCChatType)chatType{
    YMRTCDataItem *dataItem = [[YMRTCDataItem alloc] initWithChatType:chatType
                                                                 role:YMRTCRole_Caller
                                                               roomId:self.roomId otherInfoData:self.viewModel.friendModel];
    YMRTCBrowser *browser = [[YMRTCBrowser alloc] initWithDataItem:dataItem];
    [browser show];
}

#pragma mark - getter
- (MessageRoomView *)mainView {
    if (!_mainView) {
        _mainView = [[MessageRoomView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (MessageRoomViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MessageRoomViewModel alloc] init];
        //add by chw 2019.04.17 for Encryption
        _viewModel.isCrypt = self.isCrypt;
    }
    return _viewModel;
}

- (ChatTitleView *)navigationView {
    if (!_navigationView) {
        CGFloat width = SCREEN_WIDTH - (20.0 + 12.0 + 16.0 + 120);
        _navigationView = [[ChatTitleView alloc] initWithFrame:CGRectMake(0, 0, width, 30) headIcon:YES];
        @weakify(self)
        _navigationView.backClick = ^{
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        };
        _navigationView.infoClick = ^{
            @strongify(self)
            [self lookOtherUserInfo];
        };
    }
    return _navigationView;
}


- (void)dealloc {
    NSLog(@"---------聊天页面释放");
    [FMDBManager ChangeAllMessageReadStatusWithRoomId:self.roomId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
    if ([[SocketViewModel shared].room isEqualToString:self.roomId])
        [SocketViewModel shared].room = @"";
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [[UIMenuController sharedMenuController] setMenuVisible:NO];
    [UIMenuController sharedMenuController].menuItems = nil;
    self.mainView = nil;
    self.viewModel = nil;
}
@end
