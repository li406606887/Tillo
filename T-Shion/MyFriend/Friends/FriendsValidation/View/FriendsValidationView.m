//
//  FriendsValidationView.m
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsValidationView.h"
#import "FriendsValidationTableViewCell.h"
#import "FriendsValidationViewModel.h"

@interface FriendsValidationView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *table;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIButton *searchView;

@property (assign, nonatomic) int editRow;

@property (weak, nonatomic) FriendsValidationViewModel *viewModel;
@property (assign, nonatomic) long addIndex;
@end

@implementation FriendsValidationView
-(instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (FriendsValidationViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
    
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.getValidationFriendCommand execute:@{@"pageNo":@"1",@"pageSize":@"50"}];
    
    [self.viewModel.getValidationFriendSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.table reloadData];
    }];
    
    [self.viewModel.agreeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        FriendsModel *model = self.viewModel.dataArray[self.addIndex];
        model.status = 1;
        [self.table reloadData];
    }];
    
    [self.viewModel.deleteRequestSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSDictionary *data = self.viewModel.sourceDataArray[self.editRow];
        [FMDBManager deleteFriendRequest:data];
        [self.viewModel.dataArray removeObjectAtIndex:self.editRow];
        [self.viewModel.sourceDataArray removeObjectAtIndex:self.editRow];
        [self.table reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
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
    FriendsValidationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsValidationTableViewCell class])] forIndexPath:indexPath];
    cell.model = self.viewModel.dataArray[indexPath.row];
    @weakify(self)
    cell.buttonClickBlock = ^(FriendsModel *model) {
        @strongify(self)
        self.viewModel.agreeModel = model;
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.requestId forKey:@"id"];
        [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
        [param setObject:model.userId forKey:@"receiver"];
        [self.viewModel.agreeCommand execute:param];
        self.addIndex = indexPath.row;
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel.cellClickSubject sendNext:self.viewModel.dataArray[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    for (UIView * subView in self.table.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
            subView.backgroundColor = [UIColor clearColor];//去掉默认红色背景
            for (UIView *btnView in subView.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
                    UIButton *btn = (UIButton *)btnView;
                    [btn setImage:[UIImage imageNamed:@"SwipeActionButton_delete"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray  *btnArray = [NSMutableArray array];
    @weakify(self)
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"1" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        @strongify(self)
        self.editRow = (int)indexPath.row;
        [self deleteFriendRequest:indexPath];
    }];
    [deleteRowAction setBackgroundColor:[UIColor whiteColor]];
    [btnArray addObject:deleteRowAction];
    return btnArray;
}

- (void)deleteFriendRequest:(NSIndexPath *)path {
    @weakify(self)
    [ALAlertView initWithTitle:Localized(@"Tips") sureTitle:Localized(@"delete_friend_verification") controller:[MBProgressHUD getCurrentUIVC] sureBlock:^{
        @strongify(self)
         NSDictionary *dic = self.viewModel.sourceDataArray[path.row];
        NSString *requestId = dic[@"requestId"];
        [self.viewModel.deleteRequestCommand execute:@{@"requestId":requestId}];
    }];
}

#pragma mark - getter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.separatorColor = [UIColor ALLineColor];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.tableHeaderView = self.headView;
        [_table registerClass:[FriendsValidationTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsValidationTableViewCell class])]];
    }
    return _table;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        _headView.backgroundColor = [UIColor whiteColor];
        [_headView addSubview:self.searchView];
    }
    return _headView;
}

- (UIButton *)searchView {
    if (!_searchView) {
        _searchView = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_searchView setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateNormal];
        
        [_searchView setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateHighlighted];
        
        _searchView.layer.masksToBounds = YES;
        _searchView.layer.cornerRadius = 15;
        _searchView.frame = CGRectMake(25, 15, SCREEN_WIDTH - 50, 30);
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_search"]];
        [_searchView addSubview:searchIcon];
        searchIcon.x = 15;
        searchIcon.centerY = 15;
        
        UILabel *tipLabel = [UILabel constructLabel:CGRectMake(searchIcon.x + searchIcon.width + 4, 0, 200, 20)
                                               text:Localized(@"search_placeholder_phone")
                                               font:[UIFont systemFontOfSize:13]
                                          textColor:[UIColor ALTextGrayColor]];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        [_searchView addSubview:tipLabel];
        tipLabel.centerY = 15;
        
        @weakify(self);
        [[_searchView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.viewModel.gotoSearchFriendSubject sendNext:nil];
        }];
    }
    return _searchView;
}

@end
