//
//  MyInfoViewController.m
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MyInfoViewController.h"
#import "MyInfoViewModel.h"
#import "MyInfoView.h"
#import "ModifyInfoViewController.h"
#import "ChooseSexViewController.h"

@interface MyInfoViewController ()
@property (strong, nonatomic) MyInfoView *infoView;
@property (strong, nonatomic) MyInfoViewModel *viewModel;
@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"UserInfo_Setting")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.infoView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.infoView.table reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSIndexPath *indexPath) {
        @strongify(self)
        if (indexPath.row == 4) {
            [self chooseSex];
            return;
        }
        
        ModifyInfoViewController *modify = [[ModifyInfoViewController alloc] init];
        modify.type = 0;
        modify.title = [NSString stringWithFormat:@"%@%@",Localized(@"setting"),Localized(self.viewModel.titleArray[indexPath.row])];
        
        switch (indexPath.row) {
            case 1:
                modify.param = @"name";
                modify.fieldValue = [SocketViewModel shared].userModel.name;
                break;
                
            case 3:
                modify.param = @"region";
                modify.fieldValue = [SocketViewModel shared].userModel.region;
                break;

            default:
                break;
        }
        
        [self.navigationController pushViewController:modify animated:YES];
    }];
}

- (void)chooseSex {
    @weakify(self)
    ChooseSexViewController *choose = [[ChooseSexViewController alloc] init];
    choose.chooseBlock = ^(NSString *sex) {
      @strongify(self)
        [SocketViewModel shared].userModel.sex = [sex intValue];
        [self.infoView.table reloadData];
    };
    [self.navigationController pushViewController:choose animated:YES];
}

#pragma mark - getter
- (MyInfoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MyInfoViewModel alloc] init];
    }
    return _viewModel;
}

- (MyInfoView *)infoView {
    if (!_infoView) {
        _infoView = [[MyInfoView alloc] initWithViewModel:self.viewModel];
    }
    return _infoView;
}

@end
