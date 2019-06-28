//
//  QueryHistoryViewController.m
//  T-Shion
//
//  Created by together on 2019/3/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "QueryHistoryViewController.h"
#import "QueryMessageTableViewCell.h"
#import "MessageRoomViewController.h"
#import "GroupMessageRoomController.h"
#import "MemberModel.h"

@interface QueryHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *dataArray;
@property (assign, nonatomic) int type;
@end

@implementation QueryHistoryViewController

- (instancetype)initWithArray:(NSArray *)array type:(int)type {
    self = [super init];
    if (self) {
        self.dataArray = array;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.table];
    self.title = Localized(@"Chat_record");
}


- (void)viewDidLayoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
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
    id model = self.dataArray[indexPath.row];
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
    MessageModel *msg = self.dataArray[indexPath.row];
    int count = [FMDBManager selectedHistoryMsgWithRoomId:msg.roomId timestamp:msg.timestamp];
    if (count<5) {
        count = 5;
    }
    if (self.type == 1) {
        MessageRoomViewController *single;
        if (msg.cryptoType<1) {
            single = [[MessageRoomViewController alloc] initWithModel:msg.senderInfo count:count type:Loading_LOOKFOR_MESSAGES];
        }else {
            single = [[MessageRoomViewController alloc] initWithModel:msg.senderInfo count:count type:Loading_LOOKFOR_MESSAGES isCrypt:YES];
        }
        [self.navigationController pushViewController:single animated:YES];
    }else {
        GroupModel *gm = [FMDBManager selectGroupModelWithRoomId:msg.roomId];
        GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:gm count:count type:Loading_LOOKFOR_MESSAGES];
        [self.navigationController pushViewController:group animated:YES];
    }
}

#pragma mark - getter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        [_table registerClass:[QueryMessageTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([QueryMessageTableViewCell class])]];
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0);
    }
    return _table;
}

@end
