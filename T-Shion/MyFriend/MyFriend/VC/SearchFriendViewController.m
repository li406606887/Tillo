//
//  SearchFriendViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "ALSearchView.h"
#import "ZYPinYinSearch.h"
#import "SearchTableViewCell.h"
#import "SearchLockTableViewCell.h"
#import "MessageRoomViewController.h"
#import "MoreSearchRecordsViewController.h"
#import "GroupMessageRoomController.h"
#import "QueryHistoryViewController.h"

@interface SearchFriendViewController ()<ALSearchVeiwDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (copy, nonatomic) NSString *searchText;
@property (nonatomic, strong) ALSearchView *searchView;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end


@implementation SearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchView;
    [self.view addSubview:self.mainTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [super viewDidLayoutSubviews];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    if (array.count>3) {
        return 3;
    }else {
        return array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    if (array.count>3) {
        return 60.00001f;
    }else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    if (array.count>3) {
        return [self creatFootViewWithTag:section];
    }else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    title.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
    title.backgroundColor = [UIColor whiteColor];
    NSArray *array = self.dataArray[section];
    id model = array[0];
    NSString *sectionTitle;
    if ([model isKindOfClass:[FriendsModel class]]) {
        sectionTitle = Localized(@"friend_navigation_title");
    }else if([model isKindOfClass:[GroupModel class]]){
        sectionTitle = Localized(@"friend_group_chat_title");
    }else {
        sectionTitle = Localized(@"Chat_record");
    }
    title.text = [NSString stringWithFormat:@"   %@",sectionTitle];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell;
    NSArray *array = self.dataArray[indexPath.section];
    id model = array[indexPath.row];
    if ([model isKindOfClass:[FriendsModel class]]||[model isKindOfClass:[GroupModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchTableViewCell class])] forIndexPath:indexPath];
    }else {
        NSArray *msgArray = model;
        MessageModel *msg = msgArray[0];
        if (msg.cryptoType>0) {
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchLockTableViewCell class])] forIndexPath:indexPath];
            cell.msgArray = msgArray;
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchTableViewCell class])] forIndexPath:indexPath];
            cell.msgArray = array[indexPath.row];
        }
    }
    if ([model isKindOfClass:[FriendsModel class]]) {
        cell.friendModel = array[indexPath.row];
    }else if([model isKindOfClass:[GroupModel class]]) {
        cell.groupModel = array[indexPath.row];
    }
    if (indexPath.row+1 == array.count || indexPath.row +1 == 3) {
        cell.line.hidden = YES;
    }else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *array = self.dataArray[indexPath.section];
    id model = array[indexPath.row];
    if ([model isKindOfClass:[FriendsModel class]]) {
        MessageRoomViewController *single = [[MessageRoomViewController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES];
        [self.navigationController pushViewController:single animated:YES];
    }else if([model isKindOfClass:[GroupModel class]]){
        GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES];
        [self.navigationController pushViewController:group animated:YES];
    }else {
        if (array.count>0) {
            NSArray *msgArray = array[indexPath.row];
            MessageModel *msg = msgArray[0];
            FriendsModel *fm = [FMDBManager selectFriendTableWithRoomId:msg.roomId];
            int type;
            if (fm) {
                type = 1;
            }else {
                type = 0;
            }
            QueryHistoryViewController *qhistory = [[QueryHistoryViewController alloc] initWithArray:msgArray type:type];
            [self.navigationController pushViewController:qhistory animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchView.searchBar resignFirstResponder];
}

#pragma mark - ALSearchVeiwDelegate
- (void)al_didCancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// wsp 修改 2019.4.5
- (void)searchview:(ALSearchView *)searchView didSearchTextChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.searchText = searchText;
        [self.dataArray removeAllObjects];
        [self.mainTableView reloadData];
        return;
    }
    
    if ([searchText isEqualToString:self.searchText]) return;
    
    @weakify(self)
    self.searchText = searchText;
    [self.dataArray removeAllObjects];
    if (searchText.length < 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.mainTableView reloadData];
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        NSArray *friend = [FMDBManager selectedFriendWithKeyword:searchText];
        if(friend.count>0) {
            [self.dataArray addObject:friend];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.mainTableView reloadData];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        NSArray *group = [FMDBManager selectedGroupWithKeyword:searchText];
        if(group.count>0) {
            [self.dataArray addObject:group];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.mainTableView reloadData];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        NSArray *history = [FMDBManager selectedAllHistoryMessageWithKeyWord:searchText];
        if(history.count>0) {
            [self.dataArray addObject:history];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.mainTableView reloadData];
        });
    });
}
// end

#pragma mark - getter
- (ALSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[ALSearchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 30)];
        _searchView.placeholder = Localized(@"search_placeholder");
        _searchView.placeholderFont = 13;
        _searchView.delegate = self;
        [_searchView.searchBar becomeFirstResponder];
        _searchView.cancelBtnAlways = YES;
        _searchView.searchBar.delegate = self;
        
    }
    return _searchView;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor ALKeyBgColor];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 75, 0, 0);
        [_mainTableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchTableViewCell class])]];
//        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_mainTableView registerClass:[SearchLockTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([SearchLockTableViewCell class])]];
    }
    return _mainTableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)creatFootViewWithTag:(long)tag{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    label.text = @"查看全部记录";
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
    label.textColor = RGB(84, 208, 172);
    label.tag = tag;
    label.userInteractionEnabled = YES;
    [backView addSubview:label];
    @weakify(self)
    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
       @strongify(self)
        NSArray *array = self.dataArray[x.view.tag];
        MoreSearchRecordsViewController *more = [[MoreSearchRecordsViewController alloc] initWithArray:array];
        [self.navigationController pushViewController:more animated:YES];
    }];
    [label addGestureRecognizer:tap];
    return backView;
}
@end
