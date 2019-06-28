//
//  NotifySetViewController.m
//  T-Shion
//
//  Created by together on 2019/5/17.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "NotifySetViewController.h"
#import "NotifySetViewModel.h"
#import "NotifySetView.h"

@interface NotifySetViewController ()
@property (strong, nonatomic) NotifySetViewModel *viewModel;
@property (strong, nonatomic) NotifySetView *mainView;
@end

@implementation NotifySetViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"NotifySet");
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

- (NotifySetView *)mainView {
    if (!_mainView) {
        _mainView = [[NotifySetView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (NotifySetViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NotifySetViewModel alloc] init];
    }
    return _viewModel;
}
@end
