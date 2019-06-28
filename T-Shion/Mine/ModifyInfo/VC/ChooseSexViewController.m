//
//  ChooseSexViewController.m
//  T-Shion
//
//  Created by together on 2018/6/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ChooseSexViewController.h"
#import "ModifyInfoViewModel.h"

@interface ChooseSexViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ModifyInfoViewModel *viewModel;
@property (assign, nonatomic) int index;
@end

@implementation ChooseSexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"setting_sex")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.modifySuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.index==0) {
            self.chooseBlock(@"0");
        }else {
            self.chooseBlock(@"1");
        }
        
        [FMDBManager updateUserInfo:[SocketViewModel shared].userModel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ModifySex" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseSexCell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = Localized(@"UserInfo_Man");
    } else {
        cell.textLabel.text = Localized(@"UserInfo_Woman");
    }
    
    cell.accessoryType = indexPath.row == [SocketViewModel shared].userModel.sex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.tintColor = [UIColor ALKeyColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.index = (int)indexPath.row;
    NSString *param;
    if (self.index==0) {
        param = @"0";
    } else {
        param = @"1";
    }
    [self.viewModel.modifyInfoCommand execute:@{@"sex":param}];
}


#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = [UIColor ALLineColor];
        _tableView.backgroundColor = [UIColor ALKeyBgColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChooseSexCell"];
    }
    return _tableView;
}

- (ModifyInfoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ModifyInfoViewModel alloc] init];
    }
    return _viewModel;
}
@end
