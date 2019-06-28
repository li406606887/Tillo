//
//  GroupSessionViewController.m
//  T-Shion
//
//  Created by together on 2018/7/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSessionViewController.h"
#import "GroupSessionViewModel.h"
#import "GroupSessionView.h"

@interface GroupSessionViewController ()
@property (strong, nonatomic) GroupSessionViewModel *viewModel;
@property (strong, nonatomic) GroupSessionView *mainView;
@end

@implementation GroupSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.viewModel.dataArray = nil;
    [self.mainView.table reloadData];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
    [super viewWillAppear:animated];
    
}

- (void)bindViewModel {
//    [[self.viewModel.dialogueCellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
//        GroupModel *model = [FMDBManager selectGroupModelWithRoomId:x];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToGroupRoom" object:model];
//    }];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (GroupSessionView *)mainView {
    if (!_mainView) {
        _mainView = [[GroupSessionView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (GroupSessionViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GroupSessionViewModel alloc] init];
    }
    return _viewModel;
}


@end
