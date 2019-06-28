//
//  SearchMsgViewController.m
//  T-Shion
//
//  Created by together on 2019/4/24.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SearchMsgViewController.h"
#import "ALSearchView.h"
#import "QueryMessageTableViewCell.h"
#import "MessageRoomViewController.h"
#import "GroupMessageRoomController.h"

@interface SearchMsgViewController ()<UITableViewDelegate,UITableViewDataSource,ALSearchVeiwDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ALSearchView *searchView;
@property (assign, nonatomic) int type;//1 单聊 其他 群聊
@property (copy, nonatomic) NSString *roomId;
@property (strong, nonatomic) NSMutableArray *displayArray;
@end

@implementation SearchMsgViewController
- (instancetype)initWithRoomId:(NSString *)roomId type:(int)type {
    self = [super init];
    if (self) {
        self.roomId = roomId;
        self.type = type;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];

}

- (UIView *)centerView {
    return self.searchView;
}

- (void)viewDidLayoutSubviews {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayArray.count;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QueryMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([QueryMessageTableViewCell class])] forIndexPath:indexPath];
    cell.type = self.type;
    id model = self.displayArray[indexPath.row];
    if ([model isKindOfClass:[MessageModel class]]) {
        MessageModel *message = (MessageModel *)model;
        if (message.senderInfo == nil) {
            if (self.type == 1) {
                message.senderInfo = [FMDBManager selectFriendTableWithRoomId:message.roomId];
            }else {
                MemberModel *member = [FMDBManager selectedMemberWithRoomId:message.roomId memberID:message.sender];
                message.member = member;
            }
        }
        cell.message = message;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageModel *msg = self.displayArray[indexPath.row];
    int count = [FMDBManager selectedHistoryMsgWithRoomId:msg.roomId timestamp:msg.timestamp];
    if (count<5) {
        count = 5;
    }
    if (self.type == 1) {
        MessageRoomViewController *single = [[MessageRoomViewController alloc] initWithModel:msg.senderInfo count:count type:Loading_LOOKFOR_MESSAGES];
        [self.navigationController pushViewController:single animated:YES];
    }else {
        GroupModel *gm = [FMDBManager selectGroupModelWithRoomId:msg.roomId];
        GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:gm count:count type:Loading_LOOKFOR_MESSAGES];
        [self.navigationController pushViewController:group animated:YES];
    }
}

- (void)al_didCancelButtonClick {
    [self.searchView.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [_tableView registerClass:[QueryMessageTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([QueryMessageTableViewCell class])]];
        _tableView.backgroundColor = [UIColor ALKeyBgColor];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0);
    }
    return _tableView;
}


- (ALSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[ALSearchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 30)];
        [[[_searchView.searchBar rac_textSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSString * _Nullable x) {
            [self.displayArray removeAllObjects];
            NSArray *array = [FMDBManager selectedMessageWithKeyWord:x roomId:self.roomId];
            [self.displayArray addObjectsFromArray:array];
            [self.tableView reloadData];
        }];
        _searchView.delegate = self;
        [_searchView.searchBar becomeFirstResponder];
    }
    return _searchView;
}

- (NSMutableArray *)displayArray {
    if (!_displayArray) {
        _displayArray = [NSMutableArray array];
    }
    return _displayArray;
}
@end
