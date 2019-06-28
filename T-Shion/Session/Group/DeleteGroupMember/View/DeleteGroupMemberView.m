//
//  DeleteGroupMemberView.m
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "DeleteGroupMemberView.h"
#import "CreatGroupTableViewCell.h"
#import "DeleteGroupMemberViewModel.h"

@interface DeleteGroupMemberView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) DeleteGroupMemberViewModel *viewModel;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation DeleteGroupMemberView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (DeleteGroupMemberViewModel *)viewModel;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
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
    cell.member = self.viewModel.dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MemberModel *model = self.viewModel.dataArray[indexPath.row];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    model.selected = cell.selectedBtn.selected;
    if (model.selected == YES) {
        [self.viewModel.memberArray addObject:model];
    }else {
        [self.viewModel.memberArray removeObject:model];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CreatGroupTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MemberModel *model = self.viewModel.dataArray[indexPath.row];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    model.selected = cell.selectedBtn.selected;
    if (model.selected == YES) {
        [self.viewModel.memberArray addObject:model];
    }else {
        [self.viewModel.memberArray removeObject:model];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BaseTableView *)table {
    if(!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.allowsMultipleSelection = YES;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table registerClass:[CreatGroupTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([CreatGroupTableViewCell class])]];
    }
    return _table;
}

@end
