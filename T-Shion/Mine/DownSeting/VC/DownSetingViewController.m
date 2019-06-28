//
//  DownSetingViewController.m
//  AilloTest
//
//  Created by together on 2019/5/22.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "DownSetingViewController.h"
#import "DownSetingView.h"
#import "DownSetingViewModel.h"

@interface DownSetingViewController ()
@property (strong, nonatomic) DownSetingView *mainView;
@property (strong, nonatomic) DownSetingViewModel *viewModel;
@end

@implementation DownSetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"down_set_title")];
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
    
}

- (DownSetingView *)mainView {
    if (!_mainView) {
        _mainView = [[DownSetingView alloc] init];
    }
    return _mainView;
}

- (DownSetingViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[DownSetingViewModel alloc] init];
    }
    return _viewModel;
}
@end
