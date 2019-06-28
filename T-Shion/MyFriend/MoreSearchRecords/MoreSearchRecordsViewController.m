//
//  MoreSearchRecordsViewController.m
//  T-Shion
//
//  Created by together on 2019/3/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MoreSearchRecordsViewController.h"
#import "SearchTableViewCell.h"
#import "MessageRoomViewController.h"
#import "GroupMessageRoomController.h"
#import "QueryHistoryViewController.h"
#import "SearchLockTableViewCell.h"

@interface MoreSearchRecordsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) FriendsModel *friendModel;
@property (weak, nonatomic) GroupModel *groupModel;
@end

@implementation MoreSearchRecordsViewController

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        self.dataArray = array;
        id obj = array[0];
        if (![obj isKindOfClass:[NSArray class]])  {
            if ([obj isKindOfClass:[FriendsModel class]]) {
                self.friendModel = (FriendsModel *)obj;
            }else {
                self.groupModel = (GroupModel *)obj;
            }
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.table];
    self.title = Localized(@"More_record");
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
    SearchTableViewCell *cell;
    id model = self.dataArray[indexPath.row];
    if ([model isKindOfClass:[FriendsModel class]]||[model isKindOfClass:[GroupModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchTableViewCell class])] forIndexPath:indexPath];
        if ([model isKindOfClass:[FriendsModel class]]) {
            cell.friendModel = model;
        }else if([model isKindOfClass:[GroupModel class]]){
            cell.groupModel = model;
        }
    }else {
        NSArray *msgArray = model;
        MessageModel *msg = msgArray[0];
        if (msg.cryptoType>0) {
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchLockTableViewCell class])] forIndexPath:indexPath];
            cell.msgArray = msgArray;
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchTableViewCell class])] forIndexPath:indexPath];
            cell.msgArray = msgArray;
        }
    }
    cell.line.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.friendModel) {
        MessageRoomViewController *single = [[MessageRoomViewController alloc] initWithModel:self.friendModel count:20 type:Loading_NO_NEW_MESSAGES];
        [self.navigationController pushViewController:single animated:YES];
    }else if(self.groupModel){
        GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:self.groupModel count:20 type:Loading_NO_NEW_MESSAGES];
        [self.navigationController pushViewController:group animated:YES];
    }else {
        int type;
        NSArray *array = self.dataArray[indexPath.row];
        if (array.count>0) {
            MessageModel *msg = array[0];
            FriendsModel *fm = [FMDBManager selectFriendTableWithRoomId:msg.roomId];
            if (fm) {
                type = 1;
            }else {
                type = 0;
            }
            QueryHistoryViewController *query = [[QueryHistoryViewController alloc] initWithArray:self.dataArray[indexPath.row] type:type];
            [self.navigationController pushViewController:query animated:YES];
        }
        
    }
//    NSArray *array = self.dataArray[indexPath.section];
//    id model = array[indexPath.row];
//    if ([model isKindOfClass:[FriendsModel class]]) {
//        MessageRoomViewController *single = [[MessageRoomViewController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES];
//        [self.navigationController pushViewController:single animated:YES];
//    }else if([model isKindOfClass:[GroupModel class]]){
//        GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES];
//        [self.navigationController pushViewController:group animated:YES];
//    }else {
//        if (array.count>0) {
//            NSArray *msgArray = array[indexPath.row];
//            MessageModel *msg = msgArray[0];
//            FriendsModel *fm = [FMDBManager selectFriendTableWithRoomId:msg.roomId];
//            int type;
//            if (fm) {
//                type = 1;
//            }else {
//                type = 0;
//            }
//            QueryHistoryViewController *qhistory = [[QueryHistoryViewController alloc] initWithArray:msgArray type:type];
//            [self.navigationController pushViewController:qhistory animated:YES];
//        }
//    }
    
}
#pragma mark - getter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0);
        [_table registerClass:[SearchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchTableViewCell class])]];
        [_table registerClass:[SearchLockTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchLockTableViewCell class])]];

    }
    return _table;
}
@end
