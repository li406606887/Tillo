//
//  SendCardView.m
//  AilloTest
//
//  Created by together on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "SendCardView.h"
#import "SendCardViewModel.h"
#import "SearchField.h"
#import "FriendsTableViewCell.h"
#import "ZYPinYinSearch.h"

@interface SendCardView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) SendCardViewModel *viewModel;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) SearchField *field;
@end

@implementation SendCardView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (SendCardViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}


- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.table];
}

- (void)bindViewModel {
    @weakify(self)
}

- (void)layoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.viewModel.dataArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.viewModel.indexArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsTableViewCell class])] forIndexPath:indexPath];
    NSArray *array = self.viewModel.dataArray[indexPath.section];
    cell.model = array[indexPath.row];
    if (indexPath.row+1 == array.count) {
        cell.line.hidden = YES;
    }else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *array = self.viewModel.dataArray[indexPath.section];
    FriendsModel *fm = array[indexPath.row];
    [self.viewModel.clickSubject sendNext:fm];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *array = self.viewModel.dataArray[indexPath.section];
    FriendsModel *fm = array[indexPath.row];
    [self.viewModel.clickSubject sendNext:fm];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.field resignFirstResponder];
}

#pragma mark - lazy
- (BaseTableView*)table{
    if (!_table){
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.tableHeaderView = self.headView;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table registerClass:[FriendsTableViewCell class] forCellReuseIdentifier:@"FriendsTableViewCell"];
    }
    return _table;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        _headView.backgroundColor = [UIColor whiteColor];
        self.field = [[SearchField alloc] initWithFrame:CGRectMake(25, 15, SCREEN_WIDTH-50, 30)];
        [_headView addSubview:self.field];
        @weakify(self)
        [[self.field rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            if (x.length<1||[x isEqualToString:@""]) {
                [self.viewModel.dataArray removeAllObjects];
                [self.viewModel.indexArray removeAllObjects];
                NSArray *array = [MemberModel sortFriendsArray:self.viewModel.array toIndexArray:self.viewModel.indexArray];
                [self.viewModel.dataArray addObjectsFromArray:array];
                [self.table reloadData];
            }else {
                [ZYPinYinSearch searchByPropertyName:@"name" withOriginalArray:self.viewModel.array searchText:x success:^(NSArray *results) {
                    @strongify(self);
                    self.viewModel.dataArray = [MemberModel sortFriendsArray:results toIndexArray:self.viewModel.indexArray];
                    [self.table reloadData];
                } failure:nil];
            }
        }];
    }
    return _headView;
}
@end
