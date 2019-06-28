//
//  NotifySetView.m
//  T-Shion
//
//  Created by together on 2019/5/17.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "NotifySetView.h"
#import "OtherInformationTableViewCell.h"
#import "ALAlertView.h"

@interface NotifySetView ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *descriptionArray;

@end

@implementation NotifySetView

- (void)setupViews {
    [self addSubview:self.table];
}

- (void)layoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.titleArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 35)];
    label.numberOfLines = 0;
    label.font = [UIFont ALFontSize13];
    label.text = self.descriptionArray[section];
    [backView addSubview:label];
    return backView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.titleArray[indexPath.section];
    if (indexPath.section +1 == self.descriptionArray.count) {
        OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = array[indexPath.row];
        cell.nickName.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else if (indexPath.section +2 == self.descriptionArray.count) {
        OtherInformationNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = array[indexPath.row];
        NSLog(@"%@",cell.title.text);
        cell.line.hidden = YES;
        return cell;
    }
    @weakify(self)
    OtherInformationSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])] forIndexPath:indexPath];
    cell.title.text = array[indexPath.row];
    if (indexPath.section == 0) {
        cell.switchBtn.on = [FMDBManager selectedNotifyWithReceiveSwitch];
        cell.switchBlock = ^(BOOL status) {
            @strongify(self)
            [FMDBManager setNotifyWithReceiveSwitch:status];
            self.titleArray = nil;
            self.descriptionArray = nil;
            [self.table reloadData];
        };
    }else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.switchBtn.on = [FMDBManager selectedVoiceNotifySwitch];
            cell.switchBlock = ^(BOOL status) {
                @strongify(self)
                [FMDBManager setVoiceNotifySwitch:status];
                [self.table reloadData];
            };
        }else {
            cell.switchBtn.on = [FMDBManager selectedShockNotifySwitch];
            cell.switchBlock = ^(BOOL status) {
                @strongify(self)
                [FMDBManager setShockNotifySwitch:status];
                [self.table reloadData];
            };
        }
    }else if([FMDBManager selectedNotifyWithReceiveSwitch] == YES) {
         if (indexPath.section == 2) {
            cell.switchBtn.on = [FMDBManager selectedNotifyWithReceiveDetailsSwitch];
            cell.switchBlock = ^(BOOL status) {
                @strongify(self)
                [FMDBManager setNotifyWithReceiveDetailsSwitch:status];
                [self.table reloadData];
            };
        }else {
            cell.switchBtn.on = [FMDBManager selectedNotifyWithRTCSwitch];
            cell.switchBlock = ^(BOOL status) {
                @strongify(self)
                [FMDBManager setNotifyWithRTCSwitch:status];
                [self.table reloadData];
            };
        }
    }else if([FMDBManager selectedNotifyWithReceiveSwitch] == NO) {
        cell.switchBtn.on = [FMDBManager selectedNotifyWithRTCSwitch];
        cell.switchBlock = ^(BOOL status) {
            @strongify(self)
            [FMDBManager setNotifyWithRTCSwitch:status];
            [self.table reloadData];
        };
    }
    cell.line.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section +1 == self.titleArray.count) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            // Fallback on earlier versions
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }else if (indexPath.section + 2 == self.titleArray.count) {
        [ALAlertView initWithTitle:Localized(@"Tips") sureTitle:Localized(@"notify_set_default_tips") controller:[MBProgressHUD getCurrentUIVC] sureBlock:^{
            [FMDBManager setNotifyWithRTCSwitch:YES];
            [FMDBManager setNotifyWithReceiveSwitch:YES];
            [FMDBManager setNotifyWithReceiveDetailsSwitch:YES];
            [FMDBManager setVoiceNotifySwitch:YES];
            [FMDBManager setShockNotifySwitch:YES];
            self.titleArray = nil;
            self.descriptionArray = nil;
            [self.table reloadData];
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor clearColor];
        [_table registerClass:[OtherInformationSwitchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])]];
        [_table registerClass:[OtherInformationNormalTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationNormalTableViewCell class])]];
        [_table registerClass:[OtherInformationFieldTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])]];
    }
    return _table;
}


- (NSArray *)titleArray {
    if (!_titleArray) {
        if ([FMDBManager selectedNotifyWithReceiveSwitch]) {
            _titleArray = @[@[Localized(@"Receiving_Message_Notify")],@[Localized(@"voice"),Localized(@"shock")],@[Localized(@"Lock_screen")],@[Localized(@"Receiving_Audio_Video_Reminders")],@[Localized(@"Reset_notification_settings")],@[Localized(@"System_notify_seting")]];
        }else {
            _titleArray = @[@[Localized(@"Receiving_Message_Notify")],@[Localized(@"voice"),Localized(@"shock")],@[Localized(@"Receiving_Audio_Video_Reminders")],@[Localized(@"Reset_notification_settings")],@[Localized(@"System_notify_seting")]];
        }
        
    }
    return _titleArray;
}

- (NSArray *)descriptionArray {
    if (!_descriptionArray) {
         if ([FMDBManager selectedNotifyWithReceiveSwitch]) {
             _descriptionArray = @[Localized(@"Receiving_Message_Notify_describe"),@"",Localized(@"Lock_screen_details"),Localized(@"Receiving_Audio_Video_Reminders_details"),@"",Localized(@"System_notify_seting_details")];
         }else {
             _descriptionArray = @[Localized(@"Receiving_Message_Notify_describe"),@"",Localized(@"Receiving_Audio_Video_Reminders_details"),@"",Localized(@"System_notify_seting_details")];
         }
    }
    return _descriptionArray;
}
@end
