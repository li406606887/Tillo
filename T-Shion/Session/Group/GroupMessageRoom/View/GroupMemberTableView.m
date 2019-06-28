//
//  GroupMemberTableView.m
//  T-Shion
//
//  Created by together on 2018/12/18.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupMemberTableView.h"
#import "MemberTableViewCell.h"
#import "TSRTCCallingView.h"
#import "SearchField.h"
#import "YMRTCBrowser.h"
#import "TSRTCChatViewController.h"

#define kHeight SCREEN_HEIGHT * 0.5

@interface GroupMemberTableView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) UILabel *headLabel;
@property (strong, nonatomic) NSMutableArray *memberArray;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *selectArray;
@property (weak, nonatomic) NSArray *displayArray;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UIView *backView;
//@property (strong, nonatomic) UIView *whiteView;
@property (strong, nonatomic) SearchField *searchView;
@property (copy, nonatomic) NSString *room;
@end

@implementation GroupMemberTableView
- (instancetype)initWithFrame:(CGRect)frame roomId:(nonnull NSString *)roomId array:(nonnull NSArray *)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = [array mutableCopy];
        self.room = roomId;
        [self setupViews];
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.backView];
    [self addSubview:self.tableView];
    [self addSubview:self.headView];
    [self addSubview:self.searchView];

    
    [self showView];
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (self.tableView.contentSize.height<kHeight+120) {
            self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, kHeight +120);
        }
    });
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    id hitView = [super hitTest:point withEvent:event];
//    NSString *className = NSStringFromClass([hitView class]);
//    if (![className isEqualToString:@"UITableViewCellContentView"]) {
//        [self removeView];
//    }
//    return hitView;
//}

- (void)removeView{
    if (self.searchView.editing == YES) {
        [self.searchView resignFirstResponder];
        return;
    }
    [self hiddenView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchView.text.length == 0) {
        self.displayArray = nil;
        self.displayArray = self.memberArray;
    }
    
    return self.displayArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([MemberTableViewCell class])] forIndexPath:indexPath];
    cell.model = self.displayArray[indexPath.row];
    @weakify(self)
    cell.menuClickBlock = ^(int index) {
        @strongify(self)
        MemberModel *member = self.displayArray[indexPath.row];
        if (index == 3) {
            [self showAddFirendView:member];
        }else {
            [self clickMemberEventWithMemberModel:member index:index];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberModel *model = self.displayArray[indexPath.row];
    if ([model.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
        return;
    }
    if (self.itemCellClick) {
        self.itemCellClick(model.userId);
    }
    [self removeFromSuperview];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%@",@(self.tableView.contentSize));
//    if (self.tableView.contentSize.height<kHeight+120) {
//        self.tableView.contentSize = CGSizeMake(_tableView.contentSize.width, kHeight +120);
//    }
//}

#pragma mark 添加好友
- (void)showAddFirendView:(MemberModel *)member {
    [self removeFromSuperview];
    // 1.创建UIAlertController
    __block UITextField *field;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"验证信息"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"";
        field = textField;
    }];
    
    UIAlertAction *send = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:@"0" forKey:@"status"];//0表示申请加好友  1表示通过
        [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
        [param setObject:member.userId forKey:@"receiver"];
        [param setObject:field.text forKey:@"remark"];
        [[SocketViewModel shared].addFriendsCommand execute:param];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Reset Action");
    }];
    [alertController addAction:send];
    [alertController addAction:cancel];
    // 3.显示警报控制器
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark 聊天、音视频
- (void)clickMemberEventWithMemberModel:(MemberModel *)member index:(int)index {
    FriendsModel *model = [FMDBManager selectFriendTableWithUid:member.userId];
    if (!model) {
        return;
    }
    switch (index) {
        case 0: {
            if (self.sendMessageClick) {
                self.sendMessageClick(model);
            }
        }
            break;
        case 1:
            [self rtcCallWithFriendModel:model type:@"rtc_video"];
            break;
            
        case 2:
            [self rtcCallWithFriendModel:model type:@"rtc_Audio"];
            break;
            
        default:
            break;
    }
    [self removeFromSuperview];

}

- (void)rtcCallWithFriendModel:(FriendsModel *)model type:(NSString *)type {
    YMRTCChatType chatType;
    if ([type isEqualToString:@"audio"]) {
        chatType = YMRTCChatType_Audio;
    } else {
        chatType = YMRTCChatType_Video;
    }

    YMRTCDataItem *dataItem = [[YMRTCDataItem alloc] initWithChatType:chatType
                                                                 role:YMRTCRole_Caller
                                                               roomId:model.roomId otherInfoData:model];
    YMRTCBrowser *browser = [[YMRTCBrowser alloc] initWithDataItem:dataItem];
    [browser show];
    
//    NSArray *receiveIDArray = @[model.userId];
//    RTCChatType chatType;
//    if ([type isEqualToString:@"rtc_video"]) {
//        chatType = RTCChatType_Video;
//    } else {
//        chatType = RTCChatType_Audio;
//    }
//
//    UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
//    if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
//        return;
//    }
//
//    TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Caller
//                                                                           chatType:chatType
//                                                                             roomID:model.roomId
//                                                                     receiveIDArray:receiveIDArray receiveHostURL:nil];
//
//    chatVC.receiveModel = model;
//    [topVC presentViewController:chatVC animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchView resignFirstResponder];
    float y = scrollView.contentOffset.y;
    if (y<0) {
        self.headView.y = self.tableView.y - y -100;
        self.backView.y = self.headView.y +20;
        self.searchView.y = self.headView.y +60;
    }
    if (y>=0) {
        self.headView.y = self.tableView.y - 100;
        self.backView.y = self.headView.y +20;
        self.searchView.y = self.headView.y +60;
    }
}

- (void)showView {
    self.tableView.y = SCREEN_HEIGHT;
    self.headView.y = SCREEN_HEIGHT + 100;
    self.backView.y = SCREEN_HEIGHT +40;
    self.searchView.y = self.headView.y+60;
    [UIView animateWithDuration:0.3 animations:^{
        self.headView.y = kHeight - 100;
        self.searchView.y = self.headView.y+60;
        self.tableView.y = kHeight - 120;
        self.backView.y = self.headView.y + 20;
    } completion:^(BOOL finished) {
        nil;
    }];
}

- (void)hiddenView {
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.y = SCREEN_HEIGHT;
        self.headView.y = SCREEN_HEIGHT + 100;
        self.backView.y = SCREEN_HEIGHT +40;
        self.searchView.y = self.headView.y +60;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor whiteColor];
        
    }
    return _backView;
}

- (BaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectMake(0, kHeight- 120, SCREEN_WIDTH, kHeight+120) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.masksToBounds = YES;
        _tableView.layer.cornerRadius = 10;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(120, 0, 0, 0);
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[MemberTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MemberTableViewCell class])]];
    }
    return _tableView;
}

- (UILabel *)headLabel {
    if (!_headLabel) {
        _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH, 20)];
        [_headLabel setFont:[UIFont fontWithName:@"PingFang-SC-Bold" size:15]];
        _headLabel.text = [NSString stringWithFormat:@"成员(%d)",(int)self.memberArray.count];
        _headLabel.textAlignment = NSTextAlignmentCenter;
        _headLabel.textColor = RGB(153, 153, 153);
    }
    return _headLabel;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        _headView.backgroundColor = [UIColor whiteColor];
        UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        grayView.backgroundColor = RGB(221, 221, 221);
        grayView.layer.masksToBounds = YES;
        grayView.layer.cornerRadius = 2.5;
        grayView.size = CGSizeMake(50, 5);
        grayView.y = 10;
        grayView.centerX = _headView.centerX;
        [_headView addSubview:grayView];
        [_headView addSubview:self.headLabel];
        _headView.layer.masksToBounds = YES;
        _headView.layer.cornerRadius = 10;
        [_headView addSubview:self.searchView];
        _headView.userInteractionEnabled = NO;
    }
    return _headView;
}

- (NSMutableArray *)memberArray {
    if (!_memberArray) {
        NSMutableArray *indexArray = [NSMutableArray array];
        NSArray *array = [MemberModel sortMembersArray:self.dataArray toIndexArray:indexArray];
        _memberArray = [NSMutableArray array];
        for (NSArray *a in array) {
            [_memberArray addObjectsFromArray:a];
        }
    }
    return _memberArray;
}

//- (UIView *)whiteView {
//    if (!_whiteView) {
//        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH, self.tableView.y +120)];
//        _whiteView.backgroundColor = [UIColor clearColor];
//    }
//    return _whiteView;
//}

- (SearchField *)searchView {
    if (!_searchView) {
        _searchView = [[SearchField alloc] initWithFrame:CGRectMake(15, 60, SCREEN_WIDTH - 30, 30)];
        _searchView.centerX = self.centerX;
        _searchView.y = self.headView.y+60;
        _searchView.delegate = self;
        @weakify(self)
        [[_searchView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
           @strongify(self)
            if (x.length>0) {
                self.selectArray = nil;
                self.selectArray = [FMDBManager selectMemberWithRoomId:self.room keyWord:x];
                self.displayArray = self.selectArray;
            }
            [self.tableView reloadData];
        }];
    }
    return _searchView;
}

- (void)dealloc {
//    NSLog(@"123123");
//    [self.tableView removeObserver:self forKeyPath:@"contentInset"];
}
@end
