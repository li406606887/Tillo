//
//  SelectFriendViewController.m
//  T-Shion
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "SelectFriendViewController.h"
#import "SelectFriendView.h"
#import "SelectFriendViewModel.h"
#import "MessageRoomViewController.h"
#import "YMEncryptionManager.h"
@interface SelectFriendViewController ()

@property (nonatomic, strong) SelectFriendViewModel *viewModel;
@property (nonatomic, strong) SelectFriendView *mainView;

@end

@implementation SelectFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Select_contacts")];
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

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.sendMessageClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(FriendsModel * x) {
        @strongify(self);
        [self showCryptRoomWithFriendModel:x];
    }];
}

- (void)showCryptRoomWithFriendModel:(FriendsModel*)model {
    @weakify(self)
    if (model.encryptRoomID.length > 0) {
        [[YMEncryptionManager shareManager] storeCryptRoomId:model.encryptRoomID userId:model.userId isSender:YES timeStamp:[[NSDate date] timeIntervalSince1970]];
        MessageRoomViewController *controller = [[MessageRoomViewController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES isCrypt:YES];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    LoadingView(@"");
    [[YMEncryptionManager shareManager] getCryptRoomIDWithUserID:model.userId complete:^(NSString * _Nonnull cryptRoomID) {
        HiddenHUD;
        if (!cryptRoomID)
            return;
        @strongify(self)
        model.encryptRoomID = cryptRoomID;
        MessageRoomViewController *controller = [[MessageRoomViewController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES isCrypt:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (SelectFriendView *)mainView {
    if (!_mainView) {
        _mainView = [[SelectFriendView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (SelectFriendViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [[SelectFriendViewModel alloc] init];
    }
    return _viewModel;
}

@end
