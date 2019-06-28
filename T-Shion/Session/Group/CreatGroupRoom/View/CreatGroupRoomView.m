//
//  CreatGroupRoomView.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "CreatGroupRoomView.h"
#import "CreatGroupTableViewCell.h"
#import "CreatGroupRoomViewModel.h"

@implementation CreatGroupRoomView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (CreatGroupRoomViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
}

- (void)updateConstraints {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [super updateConstraints];
}


- (void)bindViewModel {

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = self.viewModel.dataArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreatGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([CreatGroupTableViewCell class])] forIndexPath:indexPath];
    @weakify(self)
    cell.clickBlock = ^(BOOL sate) {
        @strongify(self)
        NSArray *array = self.viewModel.dataArray[indexPath.section];
        FriendsModel *model = array[indexPath.row];
        if (sate) {
            [self.viewModel.memberArray addObject:model];
        }else{
            [self.viewModel.memberArray removeObject:model];
        }
    };
    NSMutableArray *array = self.viewModel.dataArray[indexPath.section];
    cell.model = array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
   
}
#pragma mark 索引
//右边索引 字节数(如果不实现 就不显示右侧索引)
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.viewModel.indexArray;
}

- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    NSInteger count =0;
    for(NSString *letter in self.viewModel.indexArray) {
        if([letter isEqualToString:title]) {
            return count;
        }
        count++;
    }
    return 0;
}

#pragma mark - getter
- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.estimatedSectionHeaderHeight = 0.f;
        _table.estimatedSectionFooterHeight = 0.f;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.tableHeaderView = self.headView;
        _table.allowsMultipleSelection = YES;
        [_table registerClass:[CreatGroupTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([CreatGroupTableViewCell class])]];
    }
    return _table;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 30)];
        [title setText:Localized(@"friend_navigation_title")];
        title.textColor = [UIColor ALTextGrayColor];
        title.font = [UIFont systemFontOfSize:12];
        [_headView addSubview:title];
    }
    return _headView;
}

@end
