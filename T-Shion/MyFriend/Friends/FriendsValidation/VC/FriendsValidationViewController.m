//
//  FriendsValidationViewController.m
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsValidationViewController.h"
#import "FriendsValidationView.h"
#import "FriendsValidationViewModel.h"
#import "AddFriendsViewController.h"
#import "OtherInformationViewController.h"
#import "StrangerViewController.h"
#import "AddFriendsModel.h"

@interface FriendsValidationViewController ()
@property (strong, nonatomic) FriendsValidationViewModel *viewModel;
@property (strong, nonatomic) FriendsValidationView *mainView;
@property (nonatomic, strong) UIButton *searchBtn;

@end

@implementation FriendsValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:Localized(@"friend_add_friend_title")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.gotoSearchFriendSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        AddFriendsViewController *searchVC = [[AddFriendsViewController alloc] init];
        searchVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:searchVC];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(FriendsModel *model) {
        @strongify(self)
        if (model.status == 1) {
            
            FriendsModel *friendsModel = [FMDBManager selectFriendTableWithUid:model.userId];
            if (!friendsModel) {
                [self gotoStrangerVC:model];
                return;
            }
            
            OtherInformationViewController *otherVC = [[OtherInformationViewController alloc] init];
            otherVC.model = friendsModel;
            
            [self.navigationController pushViewController:otherVC animated:YES];
        } else {
            [self gotoStrangerVC:model];
        }
    }];
}

- (void)gotoStrangerVC:(FriendsModel *)model {
    StrangerViewController *strangerVC = [[StrangerViewController alloc] init];
    AddFriendsModel *addModel = [[AddFriendsModel alloc] init];
    addModel.name = model.name;
    addModel.avatar = model.avatar;
    addModel.sex = model.sex;
    addModel.mobile = model.mobile;
    addModel.uid = model.userId;
    addModel.requestId = model.requestId;
    strangerVC.model = addModel;
    strangerVC.isFromValidation = YES;
    strangerVC.viewModel.agreeModel = model;
    [self.navigationController pushViewController:strangerVC animated:YES];
}

#pragma mark - getter
- (FriendsValidationView *)mainView {
    if (!_mainView) {
        _mainView = [[FriendsValidationView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (FriendsValidationViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[FriendsValidationViewModel alloc] init];
    }
    return _viewModel;
}

@end
