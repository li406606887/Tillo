//
//  GroupMessageViewController.m
//  T-Shion
//
//  Created by together on 2018/6/14.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupListView.h"
#import "GroupListViewModel.h"
#import "GroupMessageRoomController.h"
#import "CreatGroupRoomController.h"

@interface GroupListViewController ()
@property (strong, nonatomic) GroupListViewModel *viewModel;
@property (strong, nonatomic) GroupListView *mainView;
@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"friend_group_chat_title")];
}

- (void)viewWillAppear:(BOOL)animated {
    self.viewModel.dataArray = nil;
    [self.viewModel.refreshUISubject sendNext:nil];
    [super viewWillAppear:animated];
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

- (void)bindViewModel {
    [self.viewModel.getGroupListCommand execute:@{@"user_id":[SocketViewModel shared].userModel.ID}];
    @weakify(self)
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x) {
            GroupModel *model = (GroupModel *)x;
            GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES];
            [self.navigationController pushViewController:group animated:YES];
        }
    }];
    
    [self.viewModel.creatGroupSubject subscribeNext:^(id  _Nullable x) {
       @strongify(self)
        CreatGroupRoomController *group = [[CreatGroupRoomController alloc] init];
        [self.navigationController pushViewController:group animated:YES];
    }];
}

#pragma mark - getter
- (GroupListView *)mainView {
    if (!_mainView) {
        _mainView = [[GroupListView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (GroupListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GroupListViewModel alloc] init];
    }
    return _viewModel;
}
@end
