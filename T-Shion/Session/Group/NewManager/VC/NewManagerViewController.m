//
//  NewManagerViewController.m
//  T-Shion
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NewManagerViewController.h"
#import "SearchField.h"
#import "FriendsTableViewCell.h"
#import "NewManagerViewModel.h"

@interface NewManagerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *indexArray;
@property (weak, nonatomic) GroupModel *group;
@property (weak, nonatomic) MemberModel *seletedMember;
@property (strong, nonatomic) NewManagerViewModel *viewModel;
@end

@implementation NewManagerViewController
- (instancetype)initWithGroup:(GroupModel *)group {
    self = [super init];
    if (self) {
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"choose_manager")];
}

- (void)addChildView {
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.transferSuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        GroupModel *model = (GroupModel *)x;
        self.group.owner = model.owner;
        MessageModel *msg = [[MessageModel alloc] init];
        msg.roomId = self.group.roomId;
        msg.sender = self.group.owner;
        msg.timestamp = [NSDate getNowTimestamp];
        msg.messageId = msg.backId = [NSUUID UUID].UUIDString;
        
        MemberModel *member = [FMDBManager selectedMemberWithRoomId:self.group.roomId memberID:self.group.owner];
        msg.content = [NSString stringWithFormat:@"“%@”%@",member.name,Localized(@"tobe_group_manager")];
        [FMDBManager insertMessageWithContentModel:msg];
        [[SocketViewModel shared].sendMessageSubject sendNext:msg];
        NSInteger index = self.navigationController.childViewControllers.count-3;
        [self.navigationController popToViewController:self.navigationController.childViewControllers[index] animated:YES];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.indexArray[section];
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
    NSArray *array = self.dataArray[indexPath.section];
    cell.member = array[indexPath.row];
    if (indexPath.row+1 == array.count) {
        cell.line.hidden = YES;
    }else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *array = self.dataArray[indexPath.section];
    self.seletedMember = array[indexPath.row];
    [self selectedMember];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *array = self.dataArray[indexPath.section];
    self.seletedMember = array[indexPath.row];
    [self selectedMember];
}

- (void)selectedMember{
    NSString *tips = [NSString stringWithFormat:@"%@”%@“?",Localized(@"transfer_tips"),self.seletedMember.name];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"Tips") message:tips preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self)
    UIAlertAction *sure = [UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self.viewModel.transferManagerCommand execute:@{@"roomId":self.group.roomId,@"ownerId":self.seletedMember.userId}];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    [alert addAction:sure];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor ALKeyBgColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headView;
        [_tableView registerClass:[FriendsTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([FriendsTableViewCell class])]];
    }
    return _tableView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        SearchField *field = [[SearchField alloc] initWithFrame:CGRectMake(25, 15, SCREEN_WIDTH-50, 30)];
        [_headView addSubview:field];
        _headView.backgroundColor = [UIColor whiteColor];
    }
    return _headView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *members = [FMDBManager selectedMemberWithRoomId:self.group.roomId];
        for (MemberModel *m in members) {
            if ([m.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
                [members removeObject:m];
                break;
            }
        }
        NSMutableArray *array = [MemberModel sortMembersArray:members toIndexArray:self.indexArray];
        _dataArray = [NSMutableArray arrayWithArray:array];
    }
    return _dataArray;
}

- (NSMutableArray *)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (NewManagerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[NewManagerViewModel alloc] init];
    }
    return _viewModel;
}
@end
