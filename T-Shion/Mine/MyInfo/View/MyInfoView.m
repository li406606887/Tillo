//
//  MyInfoView.m
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MyInfoView.h"
#import "MyInfoTableViewCell.h"
#import "NetworkModel.h"
#import "NSString+Storage.h"

@implementation MyInfoView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (MyInfoViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}
#pragma mark - privite
- (void)setupViews {
    [self addSubview:self.table];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.setHeadIconSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSString *path = [TShionSingleCase myThumbAvatarImgPath];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        NSData *data = UIImageJPEGRepresentation(self.uploadImage, 1);
        BOOL result = [data writeToFile:path atomically:YES];
        if (result) {
            NSLog(@"存储成功");
        }
        self.headIcon.image = self.uploadImage;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ModifyHeadIcon" object:nil];
    }];
}
#pragma mark - system
- (void)updateConstraints {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
       MyInfoHeadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([MyInfoHeadViewCell class])] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.headIcon = cell.headIcon;
        
        cell.title.text = Localized(self.viewModel.titleArray[indexPath.row]);
        @weakify(self)
        cell.headBlock = ^(UIImage *image) {
          @strongify(self)
            self.uploadImage = image;
            NSData *data = UIImageJPEGRepresentation(image, 0.3);
            [self uploadImageWithData:data];
        };
        return cell;
    } else {
        MyInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([MyInfoTableViewCell class])] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   
        cell.title.text = Localized(self.viewModel.titleArray[indexPath.row]);
        switch (indexPath.row) {
            case 1:
                cell.field.text = [SocketViewModel shared].userModel.name.length>0 ? [SocketViewModel shared].userModel.name: @"";
                break;
                
            case 2:
                cell.field.text = [SocketViewModel shared].userModel.mobile;
                break;
                
            case 3:
                cell.field.text = [SocketViewModel shared].userModel.region.length>0 ? [SocketViewModel shared].userModel.region: @"";
                break;
                
            case 4:
                if ([SocketViewModel shared].userModel.sex == 0) {
                    cell.field.text = Localized(@"UserInfo_Man");
                } else if ([SocketViewModel shared].userModel.sex == 1) {
                    cell.field.text = Localized(@"UserInfo_Woman");
                }
                self.sex = cell.field;
                break;
                
            default:
                break;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 2) {
        return;
    }
   
    [self.viewModel.cellClickSubject sendNext:indexPath];
}

- (void)uploadImageWithData:(NSData *)data {
    LoadingView(@"");
    @weakify(self)
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[SocketViewModel shared].userModel.ID forKey:@"userId"];
    [param setObject:@"5" forKey:@"dirType"];
    
    [NetworkModel uploadImageWithData:data params:param fileName:[NSString stringWithFormat:@"headIcon_%@.jpg",[NSUUID UUID].UUIDString] success:^(id x) {
        @strongify(self)
        NSString *sourceId = [x objectForKey:@"id"];
        
        NSString *imageUrl = [NSString ym_imageUrlStringWithSourceId:sourceId];
        [self.viewModel.setHeadIconCommand execute:@{@"avatar":imageUrl}];
    } fail:^{
        HiddenHUD
        ShowWinMessage(Localized(@"Upload_Fail"))
    }];
}

#pragma mark - getter and setter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.dataSource = self;
        _table.delegate = self;
        _table.separatorColor = [UIColor ALLineColor];
        _table.backgroundColor = [UIColor ALKeyBgColor];
        
        [_table registerClass:[MyInfoTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MyInfoTableViewCell class])]];
        
        [_table registerClass:[MyInfoHeadViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MyInfoHeadViewCell class])]];
    }
    return _table;
}

@end
