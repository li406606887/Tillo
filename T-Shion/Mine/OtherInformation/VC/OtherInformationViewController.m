//
//  OhterInformationViewController.m
//  T-Shion
//
//  Created by together on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "OtherInformationViewController.h"
#import "OtherInformationViewModel.h"
#import "OtherInformationView.h"
#import "ModifyInfoViewController.h"
#import "ComplaintsViewController.h"
#import "MessageRoomViewController.h"
#import "LookAvatarViewController.h"
#import "LookForFileViewController.h"
#import "LookForMsgViewController.h"
//add by chw 2019.04.16 for Encryption
#import "YMEncryptionManager.h"

#import "YMRTCBrowser.h"
#import "TSRTCChatViewController.h"

@interface OtherInformationViewController ()
@property (strong, nonatomic) OtherInformationView *mainView;
@property (strong, nonatomic) OtherInformationViewModel *viewModel;
@property (assign, nonatomic) int selectedIndex;    
@end

@implementation OtherInformationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"friend_navigation_title")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}


#pragma mark - system
- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

#pragma mark - private
- (void)bindViewModel {
    @weakify(self);
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id index) {
        @strongify(self);
        if ([index intValue] == 0) {
            ModifyInfoViewController *modify = [[ModifyInfoViewController alloc] init];
            modify.type = 1;
            modify.param = self.model.userId;
            modify.title = Localized(@"Set_remarks");
            modify.fieldValue = self.model.nickName;
            modify.successBlock = ^(id param) {
                @strongify(self)
                self.model.nickName = param;
                if (self.model.nickName.length<1) {
                    self.model.showName = self.model.name;
                }else {
                    self.model.showName = self.model.nickName;
                }
                [FMDBManager updateFriendTableWithFriendsModel:self.model];
                [self.viewModel.refreshUISubject sendNext:self.model];
                [self.mainView.table reloadData];
            };
            [self.navigationController pushViewController:modify animated:YES];
        } else {
            @strongify(self)
            ComplaintsViewController *complaints = [[ComplaintsViewController alloc] init];
            complaints.userId = self.model.userId;
            complaints.type = 0;
            [self.navigationController pushViewController:complaints animated:YES];
        }
    }];
    
    [[self.viewModel.menuItemClickSubject takeUntil:self.rac_willDeallocSignal]subscribeNext:^(id x) {
        @strongify(self)
        switch ([x intValue]) {
            case 0:{
                NSInteger count = self.navigationController.childViewControllers.count;
                BaseViewController *vc = self.navigationController.childViewControllers[count - 2];
                if ([vc isKindOfClass:[MessageRoomViewController class]]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else {
                    MessageRoomViewController *message = [[MessageRoomViewController alloc] initWithModel:self.model count:20 type:Loading_NO_NEW_MESSAGES];
                    [self.navigationController pushViewController:message animated:YES];
                }
            }
                break;
                
            case 1:
                [self callRtcWithType:@"audio"];
                break;
            case 2:
                [self callRtcWithType:@"video"];
                break;
                
            default:
                break;
        }
    }];
    
    [[self.viewModel.deleteClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.selectedIndex = [x intValue];
        if (self.selectedIndex == 0) {
            [self showAlertViewControllerWithTitle:[NSString stringWithFormat:@"%@?",Localized(@"Delete_All_Message")] detailsTitle:Localized(@"Confirm")];
        }else {
            [self showAlertViewControllerWithTitle:[NSString stringWithFormat:@"%@?",Localized(@"Delete_friend")] detailsTitle:Localized(@"Confirm")];
        }
    }];
    
    [self.viewModel.deleteSuccessSubject subscribeNext:^(id  _Nullable x) {
       @strongify(self)
        [self removeAllMessageIsDelFriend:YES encryption:self.isCrypt];
        [FMDBManager deleteFriendWithFriendsModel:self.model];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    [[self.viewModel.clickAvatarSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self)
//            LookAvatarViewController *lookAvatar = [[LookAvatarViewController alloc] initWithImage:x url:@""];
//            lookAvatar.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            [self presentViewController:lookAvatar animated:YES completion:nil];
//        });
    }];
    //add by chw 2019.04.16 for Encryption
    [self.viewModel.startCryptSession subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self startCryptSession];
    }];
 
    [self.viewModel.checkSecurCodeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [[YMEncryptionManager shareManager] showSecureCodeVC:self.model.userId userName:self.model.showName withNavigationController:self.navigationController];
    }];
    
    [self.viewModel.lookForMsgSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x intValue] == 1) {
            LookForFileViewController *lookfile = [[LookForFileViewController alloc] initWithRoomId:self.model.roomId type:1];
            [self.navigationController pushViewController:lookfile animated:YES];
        }else {
            LookForMsgViewController *lookmsg = [[LookForMsgViewController alloc] init];
            lookmsg.fModel = self.model;
            [self.navigationController pushViewController:lookmsg animated:YES];
        }
    }];
    
}

- (void)showAlertViewControllerWithTitle:(NSString *)title detailsTitle:(NSString *)details {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"Tips") message:title preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self)
    UIAlertAction *sure = [UIAlertAction actionWithTitle:details style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        if (self.selectedIndex == 0) {
            [self removeAllMessageIsDelFriend:NO encryption:self.isCrypt];
        }else {
            [self.viewModel.deleteFriendCommand execute:@{@"friendId":self.viewModel.model.userId}];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)callRtcWithType:(NSString *)type {
    
    YMRTCChatType chatType;
    if ([type isEqualToString:@"audio"]) {
        chatType = YMRTCChatType_Audio;
    } else {
        chatType = YMRTCChatType_Video;
    }

    NSString *roomId = self.model.roomId;
    if (self.isCrypt)
        roomId = self.model.encryptRoomID;

    YMRTCDataItem *dataItem = [[YMRTCDataItem alloc] initWithChatType:chatType
                                                                 role:YMRTCRole_Caller
                                                               roomId:roomId otherInfoData:self.model];
    YMRTCBrowser *browser = [[YMRTCBrowser alloc] initWithDataItem:dataItem];
    [browser show];
    
//    NSArray *receiveIDArray = @[self.model.userId];
//    RTCChatType chatType;
//    if ([type isEqualToString:@"audio"]) {
//        chatType = RTCChatType_Audio;
//    } else {
//        chatType = RTCChatType_Video;
//    }
//    
//    UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
//    if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
//        return;
//    }
//    NSString *roomId = self.model.roomId;
//    if (self.isCrypt)
//        roomId = self.model.encryptRoomID;
//    TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Caller
//                                                                           chatType:chatType
//                                                                             roomID:roomId
//                                                                     receiveIDArray:receiveIDArray receiveHostURL:nil];
//    
//    chatVC.receiveModel = self.model;
//    [topVC presentViewController:chatVC animated:YES completion:nil];
}

- (void)setModel:(FriendsModel *)model {
    _model = model;
    self.viewModel.model = _model;
    [self.mainView.table reloadData];
}

- (void)removeAllMessageIsDelFriend:(BOOL)del encryption:(BOOL)encryption {
    if (del) {  //删除好友时要删除普通聊天记录和加密聊天记录
        [self clearCryptMessageWithIsDelFriend:del];
        [FMDBManager deleteConversationWithRoomId:self.model.encryptRoomID];

        [self clearMessage];
        [FMDBManager deleteConversationWithRoomId:self.model.roomId];
    }
    else { //不是删除好友清除聊天记录要根据是在普通聊天还是加密聊天做的清除
        if (encryption) {
            [FMDBManager cleanConversationTextWithRoomId:self.model.encryptRoomID];
            [self clearCryptMessageWithIsDelFriend:del];
        }else {
            [FMDBManager cleanConversationTextWithRoomId:self.model.roomId];
            [self clearMessage];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteAllMessage" object:nil];
}

- (void)clearMessage {
    [FMDBManager deleteAllMessageWithRoomId:self.model.roomId];
  
}

- (void)clearCryptMessageWithIsDelFriend:(BOOL)del {
    [FMDBManager deleteCryptMessageWithRoomId:self.model.encryptRoomID isDeleteConversation:del];
}

//add by chw 2019.04.16 for Encryption
#pragma mark - Encryption
- (void)startCryptSession {
    @weakify(self)
    [[YMEncryptionManager shareManager] getCryptRoomIDWithUserID:self.model.userId complete:^(NSString * _Nonnull cryptRoomID) {
        @strongify(self)
        self.model.encryptRoomID = cryptRoomID;
        MessageRoomViewController *controller = [[MessageRoomViewController alloc] initWithModel:self.model count:20 type:Loading_NO_NEW_MESSAGES isCrypt:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

#pragma mark - getter and setter
- (OtherInformationView *)mainView {
    if (!_mainView) {
        _mainView = [[OtherInformationView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (OtherInformationViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OtherInformationViewModel alloc] init];
        _viewModel.isCrypt = self.isCrypt;
    }
    return _viewModel;
}

- (void)dealloc {
    NSLog(@"otherinformation释放了");
    
}
@end
