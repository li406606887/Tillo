//
//  DownSetingView.m
//  AilloTest
//
//  Created by together on 2019/5/22.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "DownSetingView.h"
#import "OtherInformationTableViewCell.h"
#import "YMDownSettingManager.h"

@interface DownSetingView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *titleArray;
@end

@implementation DownSetingView
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
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 3;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 30)];
    if (section == 0) {
        label.text = Localized(@"Automatic_download");
    }else {
        label.text = Localized(@"Auto_save");
    }
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = RGB(153, 153, 153);
    [view addSubview:label];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==1) {
        OtherInformationSwitchTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])] forIndexPath:indexPath];
        cell.title.text = self.titleArray[indexPath.row];
        cell.switchBtn.on = indexPath.row==0 ? [YMDownSettingManager defaultManager].autoSavePhoto : [YMDownSettingManager defaultManager].autoSaveVideo;
        cell.switchBlock = ^(BOOL status) {
            if (indexPath.row == 0) {
                [YMDownSettingManager defaultManager].autoSavePhoto = status;
            }
            else
                [YMDownSettingManager defaultManager].autoSaveVideo = status;
        };
        return cell;
    }else {
        OtherInformationFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])] forIndexPath:indexPath];
        cell.textLabel.text = self.titleArray[indexPath.row];
        cell.nickName.userInteractionEnabled = NO;
        switch (indexPath.row) {
            case 0:
                cell.nickName.text = [self getDetailForAutoDownloadWithNetType:[YMDownSettingManager defaultManager].autoDownloadPhoto];
                break;
            case 1:
                cell.nickName.text = [self getDetailForAutoDownloadWithNetType:[YMDownSettingManager defaultManager].autoDownloadVideo];
                break;
            case 2:
                cell.nickName.text = [self getDetailForAutoDownloadWithNetType:[YMDownSettingManager defaultManager].autoDownloadFile];
                break;
            default:
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        NSString *title = self.titleArray[indexPath.row];
        @weakify(self)
        [ALAlertView initWithTitle:title array:@[Localized(@"close"),Localized(@"wifi"),Localized(@"wifi_cellular_network")] controller:[MBProgressHUD getCurrentUIVC] sureBlock:^(int index) {
            switch (indexPath.row) {
                case 0:{
                    [YMDownSettingManager defaultManager].autoDownloadPhoto = index;
                }
                    break;
                case 1: {
                    [YMDownSettingManager defaultManager].autoDownloadVideo = index;
                }
                    break;
                case 2:
                    [YMDownSettingManager defaultManager].autoDownloadFile = index;
                    break;
                default:
                    break;
            }
            OtherInformationFieldTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            @strongify(self)
            cell.nickName.text = [self getDetailForAutoDownloadWithNetType:index];
        }];
    }
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
        [_table registerClass:[OtherInformationFieldTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationFieldTableViewCell class])]];
        [_table registerClass:[OtherInformationSwitchTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([OtherInformationSwitchTableViewCell class])]];
    }
    return _table;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[Localized(@"pthoto"),Localized(@"video"),Localized(@"file")];
    }
    return _titleArray;
}

- (NSString*)getDetailForAutoDownloadWithNetType:(NSInteger)net {
    switch (net) {
        case 0: //不自动下载
        {
            return Localized(@"close");
        }
            break;
        case 1: //wifi下
        {
            return Localized(@"wifi");
        }
            break;
        case 2: //所有网络下
        {
            return Localized(@"wifi_cellular_network");
        }
            break;
        default:
            break;
    }
    return nil;
}
@end
