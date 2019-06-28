//
//  TransmitRecentlyView.m
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "TransmitView.h"
#import "CreatGroupTableViewCell.h"
#import "OperMemberCollectionCell.h"
#import "CreatGroupTableViewCell+GroupModel.h"
#import "SearchField.h"
#import "ZYPinYinSearch.h"

@interface TransmitView()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, weak) TransmitViewModel *viewModel;
@property (nonatomic, assign) TransmitViewType type;
@property (strong, nonatomic) SearchField *searchView;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) BaseTableView *tableView;         //联系人
@property (strong, nonatomic) UICollectionView *collectionView; //已选中的
@property (assign, nonatomic) CGFloat topHeight;
@end

@implementation TransmitView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel type:(TransmitViewType)type {
    self.viewModel = (TransmitViewModel *)viewModel;
    self.type = type;
    return [super initWithViewModel:viewModel];
}


- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tableView];
    [self addSubview:self.collectionView];
    [self addSubview:self.searchView];
    self.collectionView.hidden = YES;
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.selectedChangeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSArray *array = x;
        [self.collectionView reloadData];
        if (array.count > 0) {
            if (self.tableView.contentInset.top > 0) {
                return;
            }
            [UIView animateWithDuration:0.25 animations:^{
                self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
                self.tableView.contentOffset = CGPointMake(0,-80);
                self.collectionView.height = 80;
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.collectionView.height = 0;
            }];
        }
    }];
    
    [self.viewModel.dataChangeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.collectionView.hidden = NO;
        [self.tableView reloadData];
    }];
}

- (void)layoutSubviews {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.searchView.mas_bottom).with.offset(10);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 80));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.offset(SCREEN_WIDTH);
        make.top.equalTo(self).with.offset(self.topHeight);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [super layoutSubviews];
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.type != TransmitViewTypeFriend) {
        return 1;
    }else {
        return self.viewModel.dataArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type != TransmitViewTypeFriend){
        return self.viewModel.dataArray.count;
    } else {
        NSArray *array = self.viewModel.dataArray[section];
        return array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreatGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreatGroupTableViewCell"  forIndexPath:indexPath];
    BOOL bSelected = NO;
    BOOL disable = NO;
    if (self.type == TransmitViewTypeRecentlySession) {
        id model = [self.viewModel.dataArray objectAtIndex:indexPath.row];
        SessionModel *session = model;
        if ([session.type isEqualToString:@"singleChat"])
            cell.model = session.model;
        else
            cell.group = session.group;
        bSelected = session.transmitSelected;
    }
    else if (self.type == TransmitViewTypeFriend) {
        NSArray *array = [self.viewModel.dataArray objectAtIndex:indexPath.section];
        FriendsModel *fm = array[indexPath.row];
        cell.model = fm;
        bSelected = [(FriendsModel*)fm transmitSelected];
        disable = [(FriendsModel*)fm disableSelect];
    }else if (self.type == TransmitViewTypeGroup) {
        id model = [self.viewModel.dataArray objectAtIndex:indexPath.row];
        cell.group = model;
        bSelected = [(GroupModel*)model transmitSelected];
        disable = [(GroupModel*)model disableSelect];
    }
    cell.selectedBtn.selected = bSelected;
    cell.selectedBtn.enabled = !disable;
    cell.line.hidden = indexPath.row+1 == self.viewModel.dataArray.count ? YES :NO;
    if (bSelected) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell.selectedBtn.enabled) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    cell.selectedBtn.selected = YES;
    id model;
    if (self.type == TransmitViewTypeFriend) {
        NSArray *array = self.viewModel.dataArray[indexPath.section];
        model = array[indexPath.row];
    }else {
        model = [self.viewModel.dataArray objectAtIndex:indexPath.row];
    }
    [self.viewModel selectedOne:model];
    if (self.viewModel.selectedArray.count>0) {
        self.collectionView.hidden = NO;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell.selectedBtn.enabled)
        return;
    cell.selectedBtn.selected = NO;
    id model;
    if (self.type == TransmitViewTypeFriend) {
        NSArray *array = self.viewModel.dataArray[indexPath.section];
        model = array[indexPath.row];
    }else {
        model = [self.viewModel.dataArray objectAtIndex:indexPath.row];
    }
    [self.viewModel deselectedOne:model];
    if (self.viewModel.selectedArray.count < 1) {
        self.collectionView.hidden = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = section == 0 ? 40 :0.01f;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    view.backgroundColor = self.tableView.backgroundColor;
    NSString *title;
    switch (self.type) {
        case 0:{
            title = Localized(@"Transmit_Recently");
        }
            break;
        case 1:{
            title = Localized(@"Transmit_Contants");
        }
            break;
        case 2:{
            title = Localized(@"Group");
        }
            break;
        default:
            break;
    }
    
    UILabel *label = [UILabel constructLabelSizeToFitWithText:title font:[UIFont ALFontSize12] textColor:[UIColor ALTextGrayColor]];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(view.mas_centerY);
    }];
    
    if (section ==0) {
        return view;
    }else {
        return nil;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01)];
    view.backgroundColor = self.tableView.backgroundColor;
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchView resignFirstResponder];
}

#pragma mark - UICollectionViewDataSource/UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.selectedArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
    OperMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperMemberCollectionCell" forIndexPath:indexPath];
    id model = self.viewModel.selectedArray[indexPath.row];
    if ([model isKindOfClass:[FriendsModel class]])
        cell.model = model;
    else
        cell.group = model;
    @weakify(self)
    cell.modifyBlock = ^{
        @strongify(self)
        [self.viewModel deselectedOneAtIndex:indexPath.row];
        [self.tableView reloadData];
    };
    return cell;
}

#pragma mark - lazy
- (BaseTableView*)tableView{
    if (!_tableView){
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor ALKeyBgColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsMultipleSelection = YES;
        if (self.type == TransmitViewTypeRecentlySession) {
            _tableView.tableHeaderView = self.headView;
        }
        [_tableView registerClass:[CreatGroupTableViewCell class] forCellReuseIdentifier:@"CreatGroupTableViewCell"];
    }
    return _tableView;
}

- (UICollectionView*)collectionView{
    if (!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-40)/5, 70);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, 80) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[OperMemberCollectionCell class] forCellWithReuseIdentifier:@"OperMemberCollectionCell"];
    }
    return _collectionView;
}

- (SearchField *)searchView {
    if (!_searchView) {
        _searchView = [[SearchField alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-30, 30)];
        @weakify(self)
        [[_searchView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            if (x.length<1||[x isEqualToString:@""]) {
//                self.array = nil;
                [self.viewModel getDataArrayWithSelectedArray:nil];
                [self setModelSelectedStatus:self.viewModel.dataArray];
                [self.tableView reloadData];
            }else {
                NSArray *array = self.viewModel.originArray;
                NSString *propertyName;
                if (self.type == TransmitViewTypeFriend) {
                    propertyName = @"showName";
                }else {
                    propertyName = @"name";
                }
                [ZYPinYinSearch searchByPropertyName:propertyName withOriginalArray:array searchText:x success:^(NSArray *results) {
                    @strongify(self);
                    [self.viewModel.dataArray removeAllObjects];
                    if (self.type == TransmitViewTypeFriend) {
                        NSArray *array = [FriendsModel sortFriendsArray:results toIndexArray:self.viewModel.indexArray];
                        [self.viewModel.dataArray addObjectsFromArray:array];
                    }else if (self.type == TransmitViewTypeGroup){
                        [self.viewModel.dataArray addObjectsFromArray:results];
                    }else if (self.type == TransmitViewTypeRecentlySession){
                        [self.viewModel.dataArray addObjectsFromArray:results];
                    }
                    [self setModelSelectedStatus:self.viewModel.dataArray];
                    [self.tableView reloadData];
                } failure:nil];
            }
        }];
    }
    return _searchView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        _headView.backgroundColor = [UIColor whiteColor];
        UILabel *contact = [self creatlabelWithTitle:Localized(@"Transmit_Friend") tag:0];
        contact.origin = CGPointMake(0, 0);
        UILabel *group = [self creatlabelWithTitle:Localized(@"Transmit_Select_Group") tag:1];
        group.origin = CGPointMake(0, 40);
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH, 0.6)];
        line.backgroundColor = RGB(229, 229, 229);
        [_headView addSubview:line];
        [_headView addSubview:contact];
        [_headView addSubview:group];
    }
    return _headView;
}

- (UILabel *)creatlabelWithTitle:(NSString *)title tag:(int)tag {
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"    %@",title];
    label.textColor = RGB(21, 21, 21);
    label.tag = tag;
    label.size = CGSizeMake(SCREEN_WIDTH, 40);
    label.font = [UIFont systemFontOfSize:15];
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    @weakify(self)
    [[[tap rac_gestureSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        if (x.view.tag == 0) {
            [self.viewModel.clickFriendSubject sendNext:nil];
        }else {
            [self.viewModel.clickGroupSubject sendNext:nil];
        }
    }];
    [label addGestureRecognizer:tap];
    return label;
}

-  (CGFloat)topHeight {
    if (!_topHeight) {
        _topHeight = 50;
    }
    return _topHeight;
}

- (void)setModelSelectedStatus:(NSArray *)dataArray {
    for (id model in dataArray) {
        if([model isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray*)model;
            for (id obj in array) {
                if ([self.viewModel.selectedArray containsObject:obj]) {
                    [obj setValue:@(YES) forKey:@"transmitSelected"];
                }
            }
        }else {
            if ([self.viewModel.selectedArray containsObject:model]) {
                [model setValue:@(YES) forKey:@"transmitSelected"];
            }
        }
    }
}
@end
