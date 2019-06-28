//
//  GroupMessageView.m
//  T-Shion
//
//  Created by together on 2018/6/14.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupListView.h"
#import "SessionTableViewCell.h"
#import "GroupListTableViewCell.h"
#import "GroupListViewModel.h"
#import "CryptGroupListTableViewCell.h"

@interface GroupListView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *table;
@property (strong, nonatomic) UIView *headView;
@property (weak, nonatomic) GroupListViewModel *viewModel;
@property (weak, nonatomic) GroupModel *deleteModel;
@end

@implementation GroupListView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (GroupListViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.refreshUISubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.table reloadData];
    }];
    
    [[[SocketViewModel shared].exitGroupSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.deleteModel) {
            [self exitGroupWithRoomId:self.deleteModel.roomId];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return section == 0 ? 1 : self.viewModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupListTableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([GroupListTableViewCell class])] forIndexPath:indexPath];
        cell.name.textColor = [UIColor ALTextDarkColor];
        cell.name.text = Localized(@"New_group_chat");
        cell.icon.image = [UIImage imageNamed:@"friend_btn_group"];
        cell.segLine.hidden = YES;
    } else {
        GroupModel *model = self.viewModel.dataArray[indexPath.row];
        if (model.isCrypt) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CryptGroupListTableViewCell" forIndexPath:indexPath];
            cell.name.textColor = [UIColor ALLockColor];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([GroupListTableViewCell class])] forIndexPath:indexPath];
            cell.name.textColor = [UIColor ALTextDarkColor];
        }
        cell.groupModel = model;
//        cell.icon.image = [UIImage imageNamed:@"Group_Deafult_Avatar"];
        cell.segLine.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.viewModel.creatGroupSubject sendNext:nil];
    }else {
        [self.viewModel.cellClickSubject sendNext:self.viewModel.dataArray[indexPath.row]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
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
    GroupModel *model = self.viewModel.dataArray[indexPath.row];
    // 添加一个删除按钮
    @weakify(self)
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"1" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        @strongify(self)
        [self deleteGroupWithModel:model];
    }];
    [deleteRowAction setBackgroundColor:[UIColor whiteColor]];
    [btnArray addObject:deleteRowAction];
    return btnArray;
}

- (void)deleteGroupWithModel:(GroupModel *)model {
    self.deleteModel = model;
    [ALAlertView initWithTitle:Localized(@"Tips") sureTitle:[NSString stringWithFormat:@"%@%@?",Localized(@"Exit_group_tips"),model.name] controller:[MBProgressHUD getCurrentUIVC] sureBlock:^{
        if ([model.deflag intValue] == 1) {
            [self exitGroupWithRoomId:model.roomId];
        }else {
            [[SocketViewModel shared].exitGroupCommand execute:@{@"roomId":model.roomId}];
        }
    }];
}

- (void)exitGroupWithRoomId:(NSString *)roomId {
    [FMDBManager deleteConversationWithRoomId:roomId];
    [FMDBManager deleteGroupWithRoomId:roomId];
    [FMDBManager deleteAllMessageWithRoomId:roomId];
    [self.viewModel.dataArray removeObject:self.deleteModel];
    [self.table reloadData];
}

#pragma mark - getter
- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        [_table registerClass:[GroupListTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([GroupListTableViewCell class])]];
        [_table registerClass:[CryptGroupListTableViewCell class] forCellReuseIdentifier:@"CryptGroupListTableViewCell"];
    }
    return _table;
}

@end
