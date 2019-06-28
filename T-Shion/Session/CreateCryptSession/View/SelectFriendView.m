//
//  SelectFriendView.m
//  T-Shion
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "SelectFriendView.h"
#import "SelectFriendViewModel.h"
#import "FriendsTableViewCell.h"
#import "SearchField.h"
#import "ZYPinYinSearch.h"

@interface SelectFriendView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SelectFriendViewModel *viewModel;

@property (nonatomic, strong) BaseTableView *tableView;

@property (nonatomic, strong) SearchField *searchView;

@property (nonatomic, strong) NSArray *searchArray;
@property (nonatomic, strong) NSMutableArray *indexArray;
@property (nonatomic, assign) BOOL inSearch;
@end

@implementation SelectFriendView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (SelectFriendViewModel*)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tableView];
    [self addSubview:self.searchView];
}

- (void)layoutSubviews {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.offset(SCREEN_WIDTH);
        make.top.equalTo(self).with.offset(60);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [super layoutSubviews];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *dataArray = self.inSearch ? self.searchArray : self.viewModel.dataArray;
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataArray = self.inSearch ? self.searchArray : self.viewModel.dataArray;
    NSMutableArray *array = dataArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"  forIndexPath:indexPath];
    NSArray *dataArray = self.inSearch ? self.searchArray : self.viewModel.dataArray;
    NSMutableArray *array = dataArray[indexPath.section];
    FriendsModel *fm = array[indexPath.row];
    cell.model = fm;
    if (indexPath.section+1 == self.viewModel.dataArray.count && array.count == indexPath.row+1) {
        cell.line.hidden = YES;
    }else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataArray = self.inSearch ? self.searchArray : self.viewModel.dataArray;
    NSMutableArray *array = dataArray[indexPath.section];
    [self.viewModel.sendMessageClickSubject sendNext:array[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 25)];
    view.backgroundColor = [UIColor whiteColor];
    NSArray *array = self.inSearch ? self.indexArray : self.viewModel.indexArray;
    NSString *title = [array objectAtIndex:section];
    UILabel *label = [UILabel constructLabelSizeToFitWithText:title font:[UIFont systemFontOfSize:12] textColor:[UIColor ALTextGrayColor]];
    label.x = 16;
    label.centerY = 12.5;
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001f;
}

//右边索引 字节数(如果不实现 就不显示右侧索引)
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.inSearch)
        return self.indexArray;
    return self.viewModel.indexArray;
}

- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    NSArray *array = self.inSearch ? self.indexArray : self.viewModel.indexArray;
    NSInteger count =0;
    for(NSString *letter in array) {
        if([letter isEqualToString:title]) {
            return count;
        }
        count++;
    }
    return 0;
}

- (BaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor ALKeyBgColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FriendsTableViewCell class] forCellReuseIdentifier:@"FriendsTableViewCell"];
        
    }
    return _tableView;
}

- (SearchField *)searchView {
    if (!_searchView) {
        _searchView = [[SearchField alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 30)];
        @weakify(self)
        [[_searchView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            if (x.length<1||[x isEqualToString:@""]) {
                self.inSearch = NO;
                self.searchArray = nil;
                [self.tableView reloadData];
            }else {
                self.inSearch = YES;
                [ZYPinYinSearch searchByPropertyName:@"name" withOriginalArray:self.viewModel.friendsArray searchText:x success:^(NSArray *results) {
                    @strongify(self);
                    self.searchArray = [MemberModel sortMembersArray:results toIndexArray:self.indexArray];
                    [self.tableView reloadData];
                } failure:nil];
            }
        }];
    }
    return _searchView;
}
- (NSMutableArray*)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _indexArray;
}
@end
