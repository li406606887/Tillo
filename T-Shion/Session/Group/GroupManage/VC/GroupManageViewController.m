//
//  GroupManageViewController.m
//  AilloTest
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "GroupManageViewController.h"
#import "OtherInformationTableViewCell.h"
#import "NewManagerViewController.h"
#import "GroupManageViewModel.h"
#import "BaseTableViewCell.h"

@interface GroupManageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *titleArray;
@property (weak, nonatomic) GroupModel *group;
@property (strong, nonatomic) GroupManageViewModel *viewModel;
@end

@implementation GroupManageViewController
- (instancetype)initWithGroup:(GroupModel *)group {
    self = [super init];
    if (self) {
        self.group = group;
        self.viewModel.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"group_manage")];
}

- (void)addChildView {
    [self.view addSubview:self.table];
}

- (void)viewDidLayoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 0 ? 68.0f : 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 68)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 68)];
    title.text = Localized(@"group_invite_way_prompt");
    title.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
    title.numberOfLines = 0;
    [foot addSubview:title];
    return section == 0 ? foot: nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==1) {
        BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupManageCell" forIndexPath:indexPath];
        cell.textLabel.text = self.titleArray[indexPath.section];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        OtherInformationSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])] forIndexPath:indexPath];
        cell.textLabel.text = self.titleArray[indexPath.section];
        @weakify(self)
        cell.switchBtn.on = self.group.inviteSwitch;
        cell.switchBlock = ^(BOOL status) {
            @strongify(self)
            [self.viewModel.putGroupInviteCommand execute:@{@"roomId":self.group.roomId}];
        };
        cell.line.hidden = YES;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NewManagerViewController *manager = [[NewManagerViewController alloc] initWithGroup:self.group];
        [self.navigationController pushViewController:manager animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor clearColor];
        [_table registerClass:[BaseTableViewCell class] forCellReuseIdentifier:@"GroupManageCell"];
        [_table registerClass:[OtherInformationSwitchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])]];
    }
    return _table;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[Localized(@"invitation_confirmation"),Localized(@"administrator_transfer")];
    }
    return _titleArray;
}

- (GroupManageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GroupManageViewModel alloc] init];
    }
    return _viewModel;
}
@end
