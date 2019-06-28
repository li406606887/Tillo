//
//  BlackUserViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/7.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BlackUserViewController.h"
#import "BlackUserViewModel.h"
#import "BlackUserView.h"
#import "OtherInformationViewController.h"

@interface BlackUserViewController ()

@property (nonatomic, strong) BlackUserViewModel *viewModel;
@property (nonatomic, strong) BlackUserView *mainView;

@end

@implementation BlackUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"BlackUserList");
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x) {
            OtherInformationViewController *other = [[OtherInformationViewController alloc] init];
            other.model = (FriendsModel *)x;
            [self.navigationController pushViewController:other animated:YES];
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

#pragma mark - getter
- (BlackUserViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[BlackUserViewModel alloc] init];
    }
    return _viewModel;
}

- (BlackUserView *)mainView {
    if (!_mainView) {
        _mainView = [[BlackUserView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

@end
