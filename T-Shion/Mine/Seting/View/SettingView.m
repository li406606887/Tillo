//
//  SettingView.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/23.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SettingView.h"
#import "SettingViewModel.h"
#import "NameCardView.h"
#import "SettingHeadView.h"
#import "BaseTableViewCell.h"

@interface SettingView ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) SettingViewModel *viewModel;

@end

@implementation SettingView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (SettingViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}
#pragma mark - privite
- (void)setupViews {
    [self addSubview:self.mainTableView];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)bindViewModel {
    
}

#pragma mark - system
- (void)updateConstraints {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [super updateConstraints];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *idReuse = @"SettingCell";
    
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idReuse];
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idReuse];
    }

    cell.textLabel.text = Localized(self.titleArray[indexPath.row]);
    cell.textLabel.textColor = [UIColor ALTextDarkColor];
    cell.textLabel.font = [UIFont ALFontSize17];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel.cellClickSubject sendNext:@(indexPath.row)];
}

#pragma mark - getter and setter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.backgroundColor = [UIColor ALKeyBgColor];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"AccountManagement",
                        @"NotifySet",
                        @"down_set_title",
                        @"Storage",
                        @"BlackUserList",
                        @"Languages",
                        @"Feedback",
                        @"About_Aillo",
                        @"set_login_out_title"];
    }
    return _titleArray;
}

@end
