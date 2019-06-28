//
//  ComplaintsViewController.m
//  T-Shion
//
//  Created by together on 2018/8/24.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ComplaintsViewController.h"
#import "OtherComplaintsViewController.h"

@interface ComplaintsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
//@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *array;
@end

@implementation ComplaintsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Report")];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ComplaintsCell" forIndexPath:indexPath];
    cell.textLabel.text = self.array[indexPath.row];
    cell.textLabel.font = [UIFont ALFontSize15];
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
//    if (self.selectedIndexPath == indexPath) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }else{
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OtherComplaintsViewController *other = [[OtherComplaintsViewController alloc] init];
    other.content = indexPath.row == 4? @"":self.array[indexPath.row];
    other.title = self.title;
    other.type = self.type;
    other.targerId = self.userId;
    [self.navigationController pushViewController:other animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor ALLineColor];
        _tableView.backgroundColor = [UIColor ALKeyBgColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ComplaintsCell"];
    }
    return _tableView;
}

- (NSArray *)array {
    if (!_array) {
        _array = [NSArray arrayWithObjects:Localized(@"Harassment"),Localized(@"Fraud"),Localized(@"Spreading_rumours"),Localized(@"Violations"),Localized(@"Other"), nil];
    }
    return _array;
}
@end
