//
//  MineViewController.m
//  T-Shion
//
//  Created by together on 2018/6/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MineViewController.h"
#import "MineView.h"
#import "MineViewModel.h"
#import "SettingViewController.h"
#import "MyInfoViewController.h"

@interface MineViewController ()
@property (strong, nonatomic) MineView *mainView;
@property (strong, nonatomic) MineViewModel *viewModel;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    UIImage *image = [UIImage imageWithContentsOfFile:[TShionSingleCase myThumbAvatarImgPath]];
    if (image) {
        [self.mainView.headView.headIcon setImage:image];
    }
    self.mainView.headView.nickName.text = [SocketViewModel shared].userModel.name;
    [super viewWillAppear:animated];
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

- (UIBarButtonItem *)leftButton {
    return nil;
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSIndexPath *index = (NSIndexPath *)x;
        switch (index.section) {
            case 0: {
                SettingViewController *seting = [[SettingViewController alloc] init];
                [self.navigationController pushViewController:seting animated:YES];
            }
                break;
            default:
                break;
        }
    }];
    
    [self.viewModel.headClickSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        MyInfoViewController *myInfo = [[MyInfoViewController alloc] init];
        [self.navigationController pushViewController:myInfo animated:YES];
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
- (MineView *)mainView {
    if (!_mainView) {
        _mainView = [[MineView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (MineViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MineViewModel alloc] init];
    }
    return _viewModel;
}
@end
