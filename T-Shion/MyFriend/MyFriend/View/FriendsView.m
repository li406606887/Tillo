//
//  FriendsView.m
//  T-Shion
//
//  Created by together on 2018/3/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsView.h"
#import "FriendsTableViewCell.h"
#import "FriendsViewModel.h"
#import "FriendHeadView.h"

@interface FriendsView ()<UITableViewDelegate,UITableViewDataSource,FriendHeadViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) FriendsViewModel *viewModel;
@property (nonatomic, strong) FriendHeadView *headView;

@end


@implementation FriendsView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (FriendsViewModel *)viewModel;
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
    @weakify(self)
    [[[SocketViewModel shared].getFriendsSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.viewModel.dataArray = nil;
        [self.table reloadData];
    }];
}

#pragma mark - FriendHeadViewDelegate
- (void)didClickOperateButtonWithIndex:(NSInteger)index {
    [self.viewModel.validationClickSubject sendNext:@(index)];
}


#pragma mark - UITableViewDataSource
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
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsTableViewCell class])] forIndexPath:indexPath];
    NSMutableArray *array = self.viewModel.dataArray[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.model = array[indexPath.row];
    if (indexPath.section+1 == self.viewModel.dataArray.count && array.count == indexPath.row+1) {
        cell.line.hidden = YES;
    }else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = self.viewModel.dataArray[indexPath.section];
    [self.viewModel.sendMessageClickSubject sendNext:array[indexPath.row]];
}

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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.headView.scrollOffset = scrollView.contentOffset.y;
    [self.viewModel.scrollSubject sendNext:@(scrollView.contentOffset.y)];
}

#pragma mark - getter
- (FriendHeadView *)headView {
    if (!_headView) {
        _headView = [[FriendHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
        _headView.delegate = self;
    }
    return _headView;
}

- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.tableHeaderView = self.headView;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table registerClass:[FriendsTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsTableViewCell class])]];
   
    }
    return _table;
}

- (void)dealloc {
    NSLog(@"friendView 释放了");
}
@end
