//
//  StrangerInfoViewController.m
//  T-Shion
//
//  Created by together on 2018/8/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "StrangerInfoViewController.h"
#import "StrangerInfoView.h"
#import "StrangerInfoViewModel.h"

@interface StrangerInfoViewController ()
@property (strong, nonatomic) StrangerInfoView *mainView;
@property (strong, nonatomic) StrangerInfoViewModel *viewModel;
@end

@implementation StrangerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModel:(MemberModel *)model {
    _model = model;
    [self setTitle:model.name];
    self.mainView.model = model;
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(10);
        make.centerX.equalTo(self.view);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 60));
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.addSuccessSucject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (StrangerInfoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[StrangerInfoViewModel alloc] init];
    }
    return _viewModel;
}

- (StrangerInfoView *)mainView {
    if (!_mainView) {
        _mainView = [[StrangerInfoView alloc] initWithViewModel:self.viewModel];
        _mainView.backgroundColor = [UIColor whiteColor];
    }
    return _mainView;
}
@end
