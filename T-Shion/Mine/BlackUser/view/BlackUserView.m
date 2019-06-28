//
//  BlackUserView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/7.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BlackUserView.h"
#import "BlackUserViewModel.h"
#import "FriendsTableViewCell.h"

@interface BlackUserView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) BlackUserViewModel *viewModel;
@property (nonatomic, strong) UITableView *mainTableView;

@end


@implementation BlackUserView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (BlackUserViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.mainTableView];
}

- (void)bindViewModel {
    [self.viewModel.loadDataCommand execute:nil];
    
    @weakify(self);
    [self.viewModel.refreshEndSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.mainTableView reloadData];
    }];
    
    [self.viewModel.removeEndSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        FriendsModel *model = self.viewModel.dataArray[self.viewModel.editIndexPath.row];

        [FMDBManager setRoomBlackWithRoomId:model.roomId blacklistFlag:NO];
        [self.viewModel.dataArray removeObjectAtIndex:self.viewModel.editIndexPath.row];
        [self.mainTableView deleteRowsAtIndexPaths:@[self.viewModel.editIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)layoutSubviews {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsTableViewCell class])] forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.model = self.viewModel.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Localized(@"Remove_BlackUser");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    self.viewModel.editIndexPath = indexPath;
    FriendsModel *model = self.viewModel.dataArray[indexPath.row];
    [self.viewModel.removeCommand execute:@{@"friendId":model.userId}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsModel *model = self.viewModel.dataArray[indexPath.row];
    [self.viewModel.cellClickSubject sendNext:model];
}

#pragma mark - getter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _mainTableView.allowsSelection = NO;
        _mainTableView.backgroundColor = [UIColor ALKeyBgColor];
        [_mainTableView registerClass:[FriendsTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsTableViewCell class])]];
    }
    return _mainTableView;
}


@end
