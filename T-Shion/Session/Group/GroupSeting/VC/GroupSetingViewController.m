//
//  GroupSetingViewController.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSetingViewController.h"
#import "GroupSetingViewModel.h"
#import "GroupSetingView.h"
#import "AddMemberViewController.h"
#import "ModifyGroupViewController.h"
#import "OtherInformationViewController.h"
#import "StrangerInfoViewController.h"
#import "DeleteGroupMemberViewController.h"
#import "LookAllMemberViewController.h"
#import "GroupQRcodeViewController.h"
#import "GroupManageViewController.h"
#import "LookForFileViewController.h"
#import "LookForMsgViewController.h"
#import "ComplaintsViewController.h"

@interface GroupSetingViewController ()
@property (strong, nonatomic) GroupSetingViewModel *viewModel;
@property (strong, nonatomic) GroupSetingView *mainView;
@property (assign, nonatomic) int selectedIndex;
@property (weak, nonatomic) GroupModel *model;
@end

@implementation GroupSetingViewController
- (instancetype)initWithModel:(GroupModel *)model data:(NSMutableDictionary *)data {
    self = [super init];
    if (self) {
        self.model = model;
        self.viewModel.data = data;
        self.viewModel.model = model;
        MemberModel *member = [FMDBManager selectedGroupMemberWithRoomId:self.viewModel.model.roomId memberId:[SocketViewModel shared].userModel.ID];
        self.viewModel.model.nickNameInGroup = member.groupName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Group_Setting")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.viewModel.refreshMemberSubject sendNext:nil];
    [super viewWillAppear:animated];
}


- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.getGroupMemberCommand execute:self.model.roomId];
    [self.viewModel.getGroupInfoCommand execute:@{@"roomId":self.model.roomId}];
    [[self.viewModel.addMemberSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x intValue]==1) {
            DeleteGroupMemberViewController *delete = [[DeleteGroupMemberViewController alloc] initWithGroupModel:self.model data:self.viewModel.data];
            [self.navigationController pushViewController:delete animated:YES];
        }else {
            AddMemberViewController *addMember = [[AddMemberViewController alloc] initWithGroupModel:self.model data:self.viewModel.data];
            [self.navigationController pushViewController:addMember animated:YES];
        }
    }];
    
    [[self.viewModel.showAlertSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
       @strongify(self)
        self.selectedIndex = [x intValue];
        if (self.selectedIndex == 0) {
            [self showAlertViewControllerWithTitle:[NSString stringWithFormat:@"%@?",Localized(@"Delete_All_Message")] detailsTitle:Localized(@"Confirm")];
        }else {
            [self showAlertViewControllerWithTitle:[NSString stringWithFormat:@"%@%@?",Localized(@"Exit_group_tips"),self.model.name] detailsTitle:Localized(@"Confirm")];
        }
    }];
    
    [[self.viewModel.modifyNameSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        ModifyGroupViewController *addMember = [[ModifyGroupViewController alloc] init];
        addMember.model = self.model;
        [self.navigationController pushViewController:addMember animated:YES];
    }];
    
    [[[SocketViewModel shared].exitGroupSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self exitGroup];
    }];
    
    [self.viewModel.memberClickSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        MemberModel *member = x;
        if (![member.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
            if (member.isHad==0) {
                OtherInformationViewController *other = [[OtherInformationViewController alloc] init];
                other.model = (FriendsModel *)member;
                [self.navigationController pushViewController:other animated:YES];
            }else {
                StrangerInfoViewController *stranger = [[StrangerInfoViewController alloc] init];
                stranger.model = member;
                [self.navigationController pushViewController:stranger animated:YES];
            }
        }
    }];
    
    [self.viewModel.lookAllMemberSubject subscribeNext:^(id  _Nullable x) {
       @strongify(self)
        if (self.model.roomId.length>0) {
            LookAllMemberViewController *lookAll = [[LookAllMemberViewController alloc] initWithRoomId:self.model.roomId data:self.viewModel.data];
            [self.navigationController pushViewController:lookAll animated:YES];
        }
    }];
    
    [self.viewModel.groupSetingSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x intValue] == 2) {
            if (self.model.inviteSwitch) {
                [self lookQrCodeTips];
            }else {
                GroupQRcodeViewController *qrcode = [[GroupQRcodeViewController alloc] initWithGroup:self.model];
                [self.navigationController pushViewController:qrcode animated:YES];
            }
        }else {
            GroupManageViewController * manage = [[GroupManageViewController alloc] initWithGroup:self.model];
            [self.navigationController pushViewController:manage animated:YES];
        }
    }];
    
    [self.viewModel.lookForHistorySubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x intValue] == 1) {
            LookForFileViewController *lookfile = [[LookForFileViewController alloc] initWithRoomId:self.model.roomId type:2];
            [self.navigationController pushViewController:lookfile animated:YES];
        }else {
            LookForMsgViewController *lookmsg = [[LookForMsgViewController alloc] init];
            lookmsg.group = self.model;
            [self.navigationController pushViewController:lookmsg animated:YES];
        }
    }];
    
    [[self.viewModel.modifyNameInGroupSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        ModifyGroupViewController *modifyGroupVC = [[ModifyGroupViewController alloc] init];
        modifyGroupVC.modifyType = 1;
        modifyGroupVC.model = self.model;
        [self.navigationController pushViewController:modifyGroupVC animated:YES];
    }];
    
    [self.viewModel.complaintsSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        ComplaintsViewController *complaints = [[ComplaintsViewController alloc] init];
        complaints.userId = self.model.roomId;
        complaints.type = 1;
        [self.navigationController pushViewController:complaints animated:YES];
    }];
}

- (void)showAlertViewControllerWithTitle:(NSString *)title detailsTitle:(NSString *)details {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"Tips") message:title preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:details style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.selectedIndex == 0) {
            [self removeAllMessage:NO];
            [FMDBManager cleanConversationTextWithRoomId:self.model.roomId];
        }else {
            [[SocketViewModel shared].exitGroupCommand execute:@{@"roomId":self.model.roomId}];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)removeAllMessage:(BOOL)bQuit {
    if (self.model.isCrypt)
        [FMDBManager deleteCryptMessageWithRoomId:self.model.roomId isDeleteConversation:NO];
    else
        [FMDBManager deleteAllMessageWithRoomId:self.model.roomId];
}
- (void)exitGroup {
    [FMDBManager deleteConversationWithRoomId:self.model.roomId];
    [FMDBManager deleteGroupWithRoomId:self.model.roomId];
    [self removeAllMessage:YES];
    int index = (int)self.navigationController.childViewControllers.count -3;
    BaseViewController *vc = self.navigationController.childViewControllers[index];
    [self.navigationController popToViewController:vc animated:YES];
}

- (void)lookQrCodeTips {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"Tips") message:Localized(@"group_invite_swich_tips") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sure];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (GroupSetingView *)mainView {
    if (!_mainView) {
        _mainView = [[GroupSetingView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (GroupSetingViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GroupSetingViewModel alloc] init];
    }
    return _viewModel;
}

- (void)dealloc {
    NSLog(@"我被销毁了");
}

@end
