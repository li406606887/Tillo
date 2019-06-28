//
//  GroupSetingView.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSetingView.h"
#import "OtherInformationTableViewCell.h"
#import "GroupSetingViewModel.h"
#import "GroupSetingHeadView.h"
#import "NetworkModel.h"
#import "LookAvatarViewController.h"

#import "YMImageBrowseCellData.h"
#import "YMImageBrowser.h"

@interface GroupSetingView ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) GroupSetingViewModel *viewModel;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) GroupSetingHeadView *headView;
@end

@implementation GroupSetingView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (GroupSetingViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
}

- (void)layoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.refreshMemberSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.table reloadData];
    }];
    
    [self.viewModel.updateGroupAvatarEndSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.viewModel.model.avatar = [x objectForKey:@"avatar"];
        [FMDBManager updateGroupListWithModel:self.viewModel.model];
        [self.table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)uploadGroupAvatarWithData:(NSData *)imageData {
    LoadingView(@"");
    @weakify(self)
    
    [NetworkModel uploadImageWithData:imageData params:@{} fileName:[NSString stringWithFormat:@"GroupHead_%@.jpg",[NSUUID UUID].UUIDString] success:^(id x) {
        @strongify(self)
        NSString *sourceId = [x objectForKey:@"id"];
        NSString *imageUrl = [NSString ym_imageUrlStringWithSourceId:sourceId];
        [self.viewModel.updateGroupAvatarCommand execute:@{@"avatar":imageUrl,@"roomId":self.viewModel.model.roomId}];
        
    } fail:^{
        HiddenHUD;
        ShowWinMessage(Localized(@"Upload_Fail"));
    }];
    
}

#pragma mark - 查看群头像大图
- (void)showGroupBigAvatar {
    YMImageBrowseCellData *browseCellData = [YMImageBrowseCellData new];
    
    NSString *originalAvatarPath = [TShionSingleCase originalGroupHeadImgPathWithGroupId:self.viewModel.model.roomId];
    
    NSString *thumAvatarPath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:self.viewModel.model.roomId];
    
    //先展示预览图
    if ([[NSFileManager defaultManager] fileExistsAtPath:originalAvatarPath]) {
        browseCellData.thumbImage = [UIImage imageWithContentsOfFile:originalAvatarPath];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:thumAvatarPath]) {
        browseCellData.thumbImage = [UIImage imageWithContentsOfFile:thumAvatarPath];
    } else {
        browseCellData.thumbImage = [UIImage imageNamed:@"Group_Deafult_Avatar"];
    }
    
    browseCellData.url = [NSURL URLWithString:self.viewModel.model.avatar];
    browseCellData.thumbUrl = [NSURL URLWithString:[NSString ym_thumbAvatarUrlStringWithOriginalString:self.viewModel.model.avatar]];
    
    OtherInformationHeadTableViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    browseCellData.sourceObject = cell.headBack;
    
    browseCellData.extraData = @{@"thumAvatarPath":thumAvatarPath,
                                 @"originalAvatarPath":originalAvatarPath,
                                 @"isGroup":@(YES)};
    
    YMImageBrowser *browser = [YMImageBrowser new];
    browser.dataSourceArray = @[browseCellData];
    [browser show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.titleArray[section];
    if (section == 0) {
        if (![self.viewModel.model.owner isEqualToString:[SocketViewModel shared].userModel.ID]) {
            return array.count-1;
        }
    }
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == self.titleArray.count - 1 ? 50 : 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 51;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.titleArray[indexPath.section];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            OtherInformationHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationHeadTableViewCell class])] forIndexPath:indexPath];
            cell.headIcon.hidden = YES;
            cell.headBack.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
            cell.title.text = array[indexPath.row];
            cell.isGroupOwner = [[SocketViewModel shared].userModel.ID isEqualToString:self.viewModel.model.owner];
            
            NSString *imagePath = [TShionSingleCase thumbGroupHeadImgPathWithGroupId:self.viewModel.model.roomId];
            
            [TShionSingleCase loadingGroupAvatarWithImageView:cell.headBack url:[NSString ym_thumbAvatarUrlStringWithOriginalString:self.viewModel.model.avatar] filePath:imagePath];
            
            @weakify(self)
            cell.headBlock = ^(UIImage *image) {
                @strongify(self)
                if (image) {
                    NSData *data = UIImageJPEGRepresentation(image, 0.3);
                    [self uploadGroupAvatarWithData:data];
                }
            };
            
            cell.clickHeadBlock = ^(UIImage *image) {
                @strongify(self)
                [self showGroupBigAvatar];
//                LookAvatarViewController *lookAvatar = [[LookAvatarViewController alloc] initWithImage:image url:self.viewModel.model.avatar];
//                lookAvatar.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                [[MBProgressHUD getCurrentWindowVC] presentViewController:lookAvatar animated:YES completion:nil];
            };
            
            return cell;
        } else if (indexPath.row == 1) {
            OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
            cell.title.text = array[indexPath.row];
            cell.nickName.userInteractionEnabled = NO;
            if (self.viewModel.model) {
                cell.nickName.text = self.viewModel.model.name;
            }
            return cell;
        }else if(indexPath.row == 2){
            OtherInformationHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationHeadTableViewCell class])] forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
            cell.title.text = array[indexPath.row];
            cell.headBack.hidden = YES;
            cell.headIcon.hidden = NO;
            cell.headIcon.image = [UIImage imageNamed:@"setting_QRCode"];
            return cell;
        }else {
            OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
            cell.title.text = array[indexPath.row];
            cell.nickName.userInteractionEnabled = NO;
            return cell;
        }
    }else if (indexPath.section == 2){
        OtherInformationSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = array[indexPath.row];
        @weakify(self)
        if (indexPath.row == 0) {
            cell.switchBtn.on = [FMDBManager selectedRoomTopWithRoomId:self.viewModel.model.roomId];
            cell.switchBlock = ^(BOOL status) {
                @strongify(self)
                [[SocketViewModel shared].settingRoomCommand execute:@{@"type":@"top",@"roomId":self.viewModel.model.roomId}];
            };
        } else {
            cell.switchBtn.on = [FMDBManager selectedRoomDisturbWithRoomId:self.viewModel.model.roomId];
            cell.switchBlock = ^(BOOL status) {
                @strongify(self)
                [[SocketViewModel shared].settingRoomCommand execute:@{@"type":@"shield",@"roomId":self.viewModel.model.roomId}];
            };
        }
        if (indexPath.row == 3) {
            cell.line.hidden = YES;
        }else {
            cell.line.hidden = NO;
        }
        return cell;
        
    } else if (indexPath.section == 3) {
        OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.title.text = array[indexPath.row];
        cell.nickName.userInteractionEnabled = NO;
        cell.nickName.text = self.viewModel.model.nickNameInGroup;
        return cell;
    }
    
    else if(indexPath.section == 5) {
        OtherInformationNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = array[indexPath.row];
        if (indexPath.row == 1) {
            cell.line.hidden = YES;
        }else {
            cell.line.hidden = NO;
        }
        return cell;
    }else {
        OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
        cell.title.text = array[indexPath.row];
        cell.nickName.userInteractionEnabled = NO;
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self.viewModel.modifyNameSubject sendNext:nil];
        }else if (indexPath.row == 2|| indexPath.row == 3) {
            [self.viewModel.groupSetingSubject sendNext:@(indexPath.row)];
        }
    }
    
    if (indexPath.section == 1) {
        [self.viewModel.lookForHistorySubject sendNext:@(indexPath.row)];
    }
    
    if (indexPath.section == 3) {
        [self.viewModel.modifyNameInGroupSubject sendNext:nil];
    }
   
    if (indexPath.section == 5) {
        [self.viewModel.showAlertSubject sendNext:@(indexPath.row)];
    }
    
    if (indexPath.section == 4) {
        [self.viewModel.complaintsSubject sendNext:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"frame"]) {
        [self.table reloadData];
        NSLog(@"%f",self.headView.frame.size.height);
    }
}


#pragma mark - getter
- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = DEFAULT_COLOR;
        _table.tableHeaderView = self.headView;
        _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _table.separatorStyle = NO;
        
        [_table registerClass:[OtherInformationFieldTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])]];
        
        [_table registerClass:[OtherInformationSwitchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])]];
        
        [_table registerClass:[OtherInformationNormalTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])]];
        
        [_table registerClass:[OtherInformationHeadTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationHeadTableViewCell class])]];
    }
    return _table;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@[Localized(@"Group_avatar"),Localized(@"Group_name"),Localized(@"qr_code"),Localized(@"group_manage")],@[Localized(@"lookfor_chat_msg"),Localized(@"lookfor_chat_file")],@[Localized(@"Sticky_on_top"),Localized(@"Do_not_disturb")],@[Localized(@"my_name_in_group")],@[Localized(@"Report")],@[Localized(@"Delete_All_Message"),Localized(@"Exit_group")]];
    }
    return _titleArray;
}

- (GroupSetingHeadView *)headView {
    if (!_headView) {
        _headView = [[GroupSetingHeadView alloc] initWithViewModel:self.viewModel];
        [_headView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return _headView;
}

- (void)dealloc {
    [self.headView removeObserver:self forKeyPath:@"frame"];
}
@end
