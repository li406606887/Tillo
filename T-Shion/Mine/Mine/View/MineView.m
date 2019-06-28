//
//  MineView.m
//  T-Shion
//
//  Created by together on 2018/6/15.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MineView.h"
#import "MineTableViewCell.h"

@implementation MineView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (MineViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
}

- (void)layoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.titleArray[section];
    return sectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 51;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([MineTableViewCell class])] forIndexPath:indexPath];
    NSArray *titleArray = self.titleArray[indexPath.section];
    NSArray *iconArray = self.iconArray[indexPath.section];
    cell.imageView.image = [UIImage imageNamed:iconArray[indexPath.row]];
    cell.textLabel.text = titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel.cellClickSubject sendNext:indexPath];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.estimatedSectionFooterHeight = 0.f;
        _table.estimatedSectionHeaderHeight = 0.f;
        _table.tableHeaderView = self.headView;
        [_table registerClass:[MineTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MineTableViewCell class])]];
    }
    return _table;
}

- (MineHeadView *)headView {
    if (!_headView) {
        _headView = [[MineHeadView alloc] initWithViewModel:self.viewModel];
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    }
    return _headView;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
//        _titleArray = @[@[@"我的相册"],@[@"我的收藏",@"钱包"],@[@"设置"]];
        _titleArray = @[@[@"设置"]];
    }
    return _titleArray;
}

- (NSArray *)iconArray {
    if (!_iconArray) {
        _iconArray = @[@[@"mine_icon_seting"],@[@"mine_icon_photo_album"],@[@"mine_icon_collect",@"mine_icon_wallet"]];
    }
    return _iconArray;
}
@end
