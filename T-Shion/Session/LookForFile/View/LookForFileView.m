//
//  LookForFileView.m
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForFileView.h"
#import "LookForFileTableViewCell.h"
#import "LookForFileViewModel.h"
#import "SearchField.h"

@interface LookForFileView()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *table;
@property (weak, nonatomic) LookForFileViewModel *viewModel;
@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) SearchField *searchField;
@end

@implementation LookForFileView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (LookForFileViewModel *)viewModel;
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

- (void)bindViewModel {
    
}

#pragma mark tableview delegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.fileIndexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.viewModel.fileArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LookForFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([LookForFileTableViewCell class])] forIndexPath:indexPath];
    NSArray *array = self.viewModel.fileArray[indexPath.section];
    cell.message = array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.viewModel.fileArray[indexPath.section];
    MessageModel *model = array[indexPath.row];
    [self.viewModel.clickFileSubject sendNext:model];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchField resignFirstResponder];
}
#pragma mark lazy loading
-(UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.tableHeaderView = self.searchView;
        [_table registerClass:[LookForFileTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([LookForFileTableViewCell class])]];
    }
    return _table;
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        self.searchField = [[SearchField alloc] initWithFrame:CGRectMake(25, 15, SCREEN_WIDTH-50, 30)];
        [_searchView addSubview:self.searchField];
        _searchView.backgroundColor = [UIColor whiteColor];
        @weakify(self)
        [[self.searchField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            [self.viewModel.fileArray removeAllObjects];
            NSArray *array = [FMDBManager selectFileWithRoom:self.viewModel.roomId keyWord:x];
                NSArray *sortArray = [self.viewModel messageSortWithArray:array index:self.viewModel.fileIndexArray];
                [self.viewModel.fileArray addObjectsFromArray:sortArray];
                [self.table reloadData];
        }];
    }
    return _searchView;
}
@end
