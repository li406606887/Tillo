//
//  OperMemberView.m
//  T-Shion
//
//  Created by together on 2019/1/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "OperMemberView.h"
#import "OperMemberCollectionCell.h"
#import "CreatGroupTableViewCell.h"
#import "SearchField.h"
#import "ZYPinYinSearch.h"

@interface OperMemberView ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) SearchField *searchView;
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSArray *resultArray;
@property (strong, nonatomic) NSMutableArray *indexArray;
@property (copy, nonatomic) NSString *roomId;
@property (copy, nonatomic) NSString *type;
@property (assign, nonatomic) CGFloat topHeight;
@end

@implementation OperMemberView

- (instancetype)initWithFrame:(CGRect)frame roomId:(NSString *)roomId type:(nonnull NSString *)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.roomId = roomId;
        self.type = type;
        [self setupViews];
        [self.tableView reloadData];
        self.backgroundColor = [UIColor whiteColor];
        self.collectionView.hidden = YES;
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.tableView];
    [self addSubview:self.collectionView];
    [self addSubview:self.searchView];
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = self.array[section];
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
    CreatGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([CreatGroupTableViewCell class])] forIndexPath:indexPath];
    NSArray *array = self.array[indexPath.section];
    cell.member = array[indexPath.row];
    if (indexPath.row+1 == self.array.count) {
        cell.line.hidden = YES;
    }else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *array = self.array[indexPath.section];
    MemberModel *model = array[indexPath.row];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    model.selected = cell.selectedBtn.selected;
    if (model.selected == YES) {
        if ([self.type isEqualToString:@"creat"]) {
            if (self.memberArray.count>18) {
                cell.selectedBtn.selected = !cell.selectedBtn.selected;
                model.selected = cell.selectedBtn.selected;
                return;
            }
        }else if ([self.type isEqualToString:@"add"]){
            if (self.memberArray.count>19) {
                cell.selectedBtn.selected = !cell.selectedBtn.selected;
                model.selected = cell.selectedBtn.selected;
                return;
            }
        }
        [self.memberArray addObject:model];
    }else {
        [self.memberArray removeObject:model];
    }
    [self selectedMemberArray];
    [self.collectionView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *array = self.array[indexPath.section];
    MemberModel *model = array[indexPath.row];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    model.selected = cell.selectedBtn.selected;
    if (model.selected == YES) {
        [self.memberArray addObject:model];
    }else {
        [self.memberArray removeObject:model];
    }
    [self selectedMemberArray];
    [self.collectionView reloadData];
}
//右边索引 字节数(如果不实现 就不显示右侧索引)
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArray;
}

- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    NSInteger count = 0;
    for(NSString *letter in self.indexArray) {
        if([letter isEqualToString:title]) {
            return count;
        }
        count++;
    }
    return 0;
}

#pragma makr collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.memberArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
    OperMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperMemberCollectionCell" forIndexPath:indexPath];
    cell.member = self.memberArray[indexPath.row];
    @weakify(self)
    cell.modifyBlock = ^{
        @strongify(self)
        MemberModel *model = self.memberArray[indexPath.row];
        model.selected = NO;
        [self.memberArray removeObject:model];
        [self selectedMemberArray];
        [self.tableView reloadData];
        [self.collectionView reloadData];
    };
    return cell;
}

- (void)selectedMemberArray {
    [UIView animateWithDuration:0.25 animations:^{
        if (self.memberArray.count>0) {
            self.collectionView.hidden = NO;
            self.topHeight = 130;
        }else {
            self.collectionView.hidden = YES;
            self.topHeight = 50;
        }
        self.tableView.y = self.topHeight;
        self.tableView.height = self.height - self.topHeight;
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchView resignFirstResponder];
}

#pragma mark table delegate
- (BaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionHeaderHeight = 0.f;
        _tableView.estimatedSectionFooterHeight = 0.f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headView;
        _tableView.allowsMultipleSelection = YES;
        _tableView.showsVerticalScrollIndicator = YES;
        [_tableView registerClass:[CreatGroupTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([CreatGroupTableViewCell class])]];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-40)/5, 70);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[OperMemberCollectionCell class] forCellWithReuseIdentifier:@"OperMemberCollectionCell"];
    }
    return _collectionView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 30)];
        [title setText:Localized(@"friend_navigation_title")];
        title.textColor = [UIColor ALTextGrayColor];
        title.font = [UIFont systemFontOfSize:12];
        _headView.backgroundColor = [UIColor whiteColor];
        [_headView addSubview:title];
    }
    return _headView;
}

- (NSArray *)array {
    if (!_array) {
        if (self.resultArray.count>0) {
            if (self.indexArray.count>0) {
                [self.indexArray removeAllObjects];
            }
            _array = [MemberModel sortMembersArray:self.resultArray toIndexArray:self.indexArray];
        }
    }
    return _array;
}

- (NSArray *)resultArray {
    if (!_resultArray) {
        if ([self.type isEqualToString:@"creat"]) {
            self.resultArray = [FMDBManager getMemberCreatGroup];
        }else if ([self.type isEqualToString:@"delete"]) {
            self.resultArray = [FMDBManager selectedOtherMemberWithRoomId:self.roomId];
        }else {
            self.resultArray = [FMDBManager selectAbleMemberWithRoomId:self.roomId];
        }
    }
    return _resultArray;
}

- (NSMutableArray *)memberArray {
    if (!_memberArray) {
        _memberArray = [NSMutableArray array];
    }
    return _memberArray;
}

- (NSMutableArray *)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (CGFloat)topHeight {
    if (_topHeight == 0) {
        _topHeight = 50;
    }
    return _topHeight;
}

- (SearchField *)searchView {
    if (!_searchView) {
        _searchView = [[SearchField alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-30, 30)];
        @weakify(self)
        [[_searchView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            if (x.length<1||[x isEqualToString:@""]) {
                self.array = nil;
                [self.tableView reloadData];
            }else {
                [ZYPinYinSearch searchByPropertyName:@"name" withOriginalArray:self.resultArray searchText:x success:^(NSArray *results) {
                    @strongify(self);
                    self.array = [MemberModel sortMembersArray:results toIndexArray:self.indexArray];
                    [self.tableView reloadData];
                } failure:nil];
            }
        }];
    }
    return _searchView;
}
@end
