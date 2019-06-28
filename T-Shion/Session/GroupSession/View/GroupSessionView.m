//
//  GroupSessionView.m
//  T-Shion
//
//  Created by together on 2018/7/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSessionView.h"
#import "SessionTableViewCell.h"
#import "GroupSessionViewModel.h"

@interface GroupSessionView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) GroupSessionViewModel *viewModel;
//@property (weak, nonatomic) GroupSessionModel *deleteModel;
@end


@implementation GroupSessionView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (GroupSessionViewModel *)viewModel;
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SessionTableViewCell class])] forIndexPath:indexPath];
//    cell.groupModel = self.viewModel.dataArray[indexPath.row];
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deleteSession:)];
    longPressGR.minimumPressDuration = 0.5;
    cell.tag = indexPath.row;
    [cell addGestureRecognizer:longPressGR];
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    GroupSessionModel *model = self.viewModel.dataArray[indexPath.row];
//    GroupModel *group;
//    if (model.model == nil) {
//        group = [FMDBManager selectGroupModelWithRoomId:model.roomId];
//    }else {
//        group = model.model;
//    }
//    if (group) {
//        [self.viewModel.dialogueCellClickSubject sendNext:model.roomId];
//    }
//}

- (void)deleteSession:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {//手势开始
//        int index = (int)longPress.view.tag ;
//        self.deleteModel = self.viewModel.dataArray[index];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除" message:nil delegate:self cancelButtonTitle:Localized(@"Cancel") otherButtonTitles:Localized(@"Cancel"), nil];
//        [alert show];
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        [FMDBManager deleteAllMessageWithRoomId:self.deleteModel.roomId];
//        [FMDBManager deleteConversationWithRoomId:self.deleteModel.roomId];
//        [self.viewModel.dataArray removeObject:self.deleteModel];
//        [self.table reloadData];
//    }
//}x/
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        [_table registerClass:[SessionTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SessionTableViewCell class])]];
    }
    return _table;
}
@end
