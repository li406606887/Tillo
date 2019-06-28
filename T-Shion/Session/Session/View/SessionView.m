//
//  DialogueView.m
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SessionView.h"
#import "SessionViewModel.h"
#import "SessionTableViewCell.h"
#import "SessionLockTableViewCell.h"
#import "SessionCryptGroupTableViewCell.h"

@interface SessionView ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate>
@property (nonatomic, weak) SessionViewModel *viewModel;
@property (weak, nonatomic) SessionModel *editingModel;

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UILabel *titleLabel;


@end

@implementation SessionView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (SessionViewModel *)viewModel;
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
    [self.viewModel.refreshTableSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.table reloadData];
    }];
    
    [[[SocketViewModel shared].getUnreadSessionSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewModel.dataArray = nil;
            [self.table reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionModel *session = self.viewModel.dataArray[indexPath.row];
    if (session.group && session.isCrypt) {
        SessionCryptGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SessionCryptGroupTableViewCell" forIndexPath:indexPath];
        cell.model = session;
        return cell;
    }
    else if (session.group||session.isCrypt) {
        SessionLockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SessionLockTableViewCell class])] forIndexPath:indexPath];
        cell.model = session;
        return cell;
    }else {
        SessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SessionTableViewCell class])] forIndexPath:indexPath];
        cell.model = session;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionModel *model = self.viewModel.dataArray[indexPath.row];
    [self.viewModel.sessionCellClickSubject sendNext:model];
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
                        NSLog(@"%@",btn.titleLabel.text);
                        if ([btn.titleLabel.text isEqualToString:@"1"]){
                            [btn setImage:[UIImage imageNamed:@"SwipeActionButton_top"] forState:UIControlStateNormal];
                        }else if([btn.titleLabel.text isEqualToString:@"2"]) {
                            [btn setImage:[UIImage imageNamed:@"SwipeActionButton_disturb"] forState:UIControlStateNormal];
                        }else {
                            [btn setImage:[UIImage imageNamed:@"SwipeActionButton_delete"] forState:UIControlStateNormal];
                        }
                    }
                }
            }
        }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray  *btnArray = [NSMutableArray array];
    SessionModel *model = self.viewModel.dataArray[indexPath.row];
    // 添加一个删除按钮
    @weakify(self)
    UITableViewRowAction *topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"1" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSString *roomId = model.isCrypt ? model.model.encryptRoomID : model.roomId;
        [[SocketViewModel shared].settingRoomCommand execute:@{@"roomId":roomId,@"type":@"top"}];
    }];
    UITableViewRowAction *disturbAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"2" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSString *roomId = model.isCrypt ? model.model.encryptRoomID : model.roomId;
        [[SocketViewModel shared].settingRoomCommand execute:@{@"roomId":roomId,@"type":@"shield"}];
    }];
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"3" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        @strongify(self)
        [self cleanConversation:model];
    }];
    [topAction setBackgroundColor:[UIColor whiteColor]];
    [disturbAction setBackgroundColor:[UIColor whiteColor]];
    [deleteRowAction setBackgroundColor:[UIColor whiteColor]];
    [btnArray addObject:deleteRowAction];
    [btnArray addObject:disturbAction];
    [btnArray addObject:topAction];
    return btnArray;
}

- (void)cleanConversation:(SessionModel *)model {
    @weakify(self)
    [ALAlertView initWithTitle:Localized(@"Tips") sureTitle:Localized(@"Clear_Delete_Session") controller:[MBProgressHUD getCurrentUIVC] sureBlock:^{
        @strongify(self)
        if (model.isCrypt) {
            //add by chw 2019.04.26 for "密聊清除会话有些系统提示要特殊处理"
            [FMDBManager deleteCryptMessageWithRoomId:model.roomId isDeleteConversation:YES];
        }
        else {
            [FMDBManager deleteAllMessageWithRoomId:model.roomId];
        }
        [FMDBManager deleteConversationWithRoomId:model.roomId];
        [self.viewModel.dataArray removeObject:model];
        [self.table reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowUnreadMsg" object:nil];
    }];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
    if (scrollOffset >= 50) {
        self.titleLabel.alpha = 0;
    } else {
        self.titleLabel.alpha = (50 - scrollOffset)/50;
    }
    [self.viewModel.scrollSubject sendNext:@(scrollView.contentOffset.y)];
}

#pragma mark - getter
- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.tableHeaderView = self.headView;
        [_table registerClass:[SessionTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SessionTableViewCell class])]];
        [_table registerClass:[SessionLockTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SessionLockTableViewCell class])]];
        [_table registerClass:[SessionCryptGroupTableViewCell class] forCellReuseIdentifier:@"SessionCryptGroupTableViewCell"];
    }
    return _table;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _headView.backgroundColor = [UIColor whiteColor];
        [_headView addSubview:self.titleLabel];
    }
    return _headView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [UILabel constructLabel:CGRectMake(15, 0, SCREEN_WIDTH - 15, 50)
                                                 text:Localized(@"home_navigation_title")
                                                 font:[UIFont ALBoldFontSize30]
                                            textColor:[UIColor ALTextDarkColor]];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

@end
