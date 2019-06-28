//
//  OhterInformationView.m
//  T-Shion
//
//  Created by together on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//  

#import "OtherInformationView.h"
#import "OtherInformationTableViewCell.h"
#import "RoomSetModel.h"

@implementation OtherInformationView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (OtherInformationViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
    
    [self setNeedsUpdateConstraints];
}

- (void)bindViewModel {
    @weakify(self);
    [[SocketViewModel shared].blackUserEndSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        RoomSetModel *roomSet = [RoomSetModel mj_objectWithKeyValues:x];
        BOOL isBlock = roomSet.blacklistFlag;
        [FMDBManager setRoomBlackWithRoomId:self.viewModel.model.roomId blacklistFlag:isBlock];
    }];
}

- (void)updateConstraints {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == self.titleArray.count - 1 ? 50 : 0.0001f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.titleArray[section];
    return array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
    [v setBackgroundColor:tableView.backgroundColor];
    return v;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [v setBackgroundColor:tableView.backgroundColor];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 51;
}
//modify by chw 2019.04.16 for Encryption and search
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.titleArray[indexPath.section];
    NSInteger section = indexPath.section;
    //加密聊天进来的是不一样的，区分开处理
    if (self.viewModel.isCrypt) {
        switch (section) {
            case 0: {//聊天置顶、拉黑
                OtherInformationSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])] forIndexPath:indexPath];
                cell.title.text = array[indexPath.row];
                @weakify(self)
                if (indexPath.row == 0) {
                    cell.switchBtn.on = [FMDBManager selectedRoomTopWithRoomId:self.viewModel.model.encryptRoomID];
                    cell.switchBlock = ^(BOOL status) {
                        @strongify(self)
                        [[SocketViewModel shared].settingRoomCommand execute:@{@"type":@"top",@"roomId":self.viewModel.model.encryptRoomID}];
                    };
                    cell.line.hidden = NO;
                } else if (indexPath.row == 1) {
                    cell.switchBtn.on = [FMDBManager selectedRoomDisturbWithRoomId:self.viewModel.model.encryptRoomID];
                    cell.switchBlock = ^(BOOL status) {
                        @strongify(self)
                        [[SocketViewModel shared].settingRoomCommand execute:@{@"type":@"shield",@"roomId":self.viewModel.model.encryptRoomID}];
                    };
                    cell.line.hidden = YES;
                }
                return cell;
            }
                break;
            case 1: {//加密验证
                OtherInformationNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])] forIndexPath:indexPath];
                cell.title.text = array[indexPath.row];
                cell.title.textColor = [UIColor ALTextDarkColor];
                cell.line.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crypt_lock"]];
                return cell;
            }
            case 2: {//删除聊天记录
                OtherInformationNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])] forIndexPath:indexPath];
                cell.title.text = array[indexPath.row];
                cell.title.textColor = [UIColor ALRedColor];
                cell.accessoryType = UITableViewCellAccessoryNone; //隐藏最右边的箭头
                cell.line.hidden = YES;
                return cell;
            }
            default:
                break;
        }
        return nil;
    }
    if (!self.viewModel.model.enableEndToEndCrypt)
        section += 1;
    if (section == 1) {//备注
        OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.title.text = array[indexPath.row];
        cell.nickName.userInteractionEnabled = NO;
        cell.nickName.text = self.viewModel.model.nickName;
        cell.line.hidden = YES;
        return cell;
    }
    else if (section == 3 && indexPath.row < 3) {//聊天置顶、消息免打扰、拉黑
        OtherInformationSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = array[indexPath.row];
        @weakify(self)
        switch (indexPath.row) {
            case 0: { //置顶聊天
                cell.switchBtn.on = [FMDBManager selectedRoomTopWithRoomId:self.viewModel.model.roomId];
                cell.switchBlock = ^(BOOL status) {
                    @strongify(self)
                    [[SocketViewModel shared].settingRoomCommand execute:@{@"type":@"top",@"roomId":self.viewModel.model.roomId}];
                };
            }
                break;
            case 1: { //消息免打扰
                    cell.switchBtn.on = [FMDBManager selectedRoomDisturbWithRoomId:self.viewModel.model.roomId];
                    cell.switchBlock = ^(BOOL status) {
                        @strongify(self)
                        [[SocketViewModel shared].settingRoomCommand execute:@{@"type":@"shield",@"roomId":self.viewModel.model.roomId}];
                    };
            }
                break;
            case 2: { //拉黑
                cell.switchBtn.on = [FMDBManager selectedRoomBlackWithRoomId:self.viewModel.model.roomId];
                cell.switchBlock = ^(BOOL status) {
                    @strongify(self)
                    [[SocketViewModel shared].blackUserCommand execute:@{@"friendId":self.viewModel.model.userId}];
                };
            }
                break;
            default:
                break;
        }
        return cell;
    }
    else {
        OtherInformationNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = array[indexPath.row];
        if (section == 4) {
            cell.title.textColor = [UIColor ALRedColor];
            cell.accessoryType = UITableViewCellAccessoryNone; //隐藏最右边的箭头
        }
        else {
            cell.title.textColor = [UIColor ALTextDarkColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        }
        if (indexPath.row == array.count-1) {
            cell.line.hidden = YES;
        }else {
            cell.line.hidden = NO;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger section = indexPath.section;
    //加密聊天进来展示的是不一样的，区分开处理
    if (self.viewModel.isCrypt) {
        if (section == 1) {
            [self.viewModel.checkSecurCodeSubject sendNext:nil];
        }
        else if (section == 2) {
            [self.viewModel.deleteClickSubject sendNext:@(0)];
        }
        return;
    }
    if (!self.viewModel.model.enableEndToEndCrypt)
        section += 1;
    switch (section) {
        case 0: //发起加密聊天
        {
            [self.viewModel.startCryptSession sendNext:nil];
        }
            break;
        case 1: //备注
        {
            [self.viewModel.cellClickSubject sendNext:@(0)];//兼容原来的备注是第0行
        }
            break;
        case 2: //搜索聊天记录、文件
        {
            [self.viewModel.lookForMsgSubject sendNext:@(indexPath.row)];
        }
            break;
        case 3: //聊天置顶、消息免打扰、拉黑、投诉
        {
            if (indexPath.row == 3)
                [self.viewModel.cellClickSubject sendNext:@(3)];//兼容原来的投诉是第3行
        }
            break;
        case 4: //删除聊天记录、删除好友
        {
            [self.viewModel.deleteClickSubject sendNext:@(indexPath.row)];
        }
            break;
        default:
            break;
    }
}


#pragma mark - getter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor ALKeyBgColor];
//        _table.separatorColor = [UIColor clearColor];
        _table.tableHeaderView = self.informationView;
        _table.separatorStyle = NO;
        [_table registerClass:[OtherInformationFieldTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])]];
        
        [_table registerClass:[OtherInformationSwitchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])]];
        
        [_table registerClass:[OtherInformationNormalTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])]];
    }
    
    return _table;
}

- (NameCardView *)informationView {
    if (!_informationView) {
        _informationView = [[NameCardView alloc] initWithViewModel:self.viewModel];
        _informationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 175);
        @weakify(self)
        _informationView.buttonClickBlock = ^(int index) {
         @strongify(self)
            [self.viewModel.menuItemClickSubject sendNext:@(index)];
        };
    }
    return _informationView;
}
//add by chw 2019.04.16 for Encryption and search
- (NSArray *)titleArray {
    if (!_titleArray) {
        if (self.viewModel.isCrypt) {
            _titleArray = @[
                            @[Localized(@"Sticky_on_top"),
                              Localized(@"Do_not_disturb")],
                            @[Localized(@"crypt_verify_code")],
                            @[Localized(@"Delete_All_Message")]
                            ];
        }
        else {
            if (self.viewModel.model.enableEndToEndCrypt) {
                _titleArray = @[
                                @[Localized(@"crypt_start_single")],
                                @[Localized(@"Remarks")],
                                @[Localized(@"lookfor_chat_msg"),
                                  Localized(@"lookfor_chat_file")],
                                @[Localized(@"Sticky_on_top"),
                                  Localized(@"Do_not_disturb"),
                                  Localized(@"BlockUser"),
                                  Localized(@"Report")],
                                @[Localized(@"Delete_All_Message"),
                                  Localized(@"Delete_friend")]];
            }
            else {
                _titleArray = @[
                                @[Localized(@"Remarks")],
                                @[Localized(@"lookfor_chat_msg"),
                                  Localized(@"lookfor_chat_file")],
                                @[Localized(@"Sticky_on_top"),
                                  Localized(@"Do_not_disturb"),
                                  Localized(@"BlockUser"),
                                  Localized(@"Report")],
                                @[Localized(@"Delete_All_Message"),
                                  Localized(@"Delete_friend")]];
            }
        }
    }
    return _titleArray;
}

@end
