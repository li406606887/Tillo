//
//  AboutUsViewController.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *companyLabel;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"About_Aillo");
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 5;
    longPress.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:longPress];
}

//测试bugly配置符专用隐藏手势
- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    NSArray *array = @[];
    id ddd = array[0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.companyLabel];
}

- (void)viewDidLayoutSubviews {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-15);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headView.mas_centerX);
        make.centerY.equalTo(self.headView.mas_centerY).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headView.mas_centerX);
        make.top.equalTo(self.iconView.mas_bottom).with.offset(5);
    }];
    
    [super viewDidLayoutSubviews];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseID = @"AboutUsViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }
    
    cell.textLabel.font = [UIFont ALBoldFontSize15];
    cell.detailTextLabel.font = [UIFont ALFontSize15];
    cell.textLabel.text = Localized(@"set_about_email");
    cell.detailTextLabel.text = @"service@aillo.cc";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - getter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.allowsSelection = NO;
        _mainTableView.tableHeaderView = self.headView;
        _mainTableView.backgroundColor = [UIColor ALKeyBgColor];
    }
    return _mainTableView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
        _headView.backgroundColor = [UIColor whiteColor];
        [_headView addSubview:self.iconView];
        [_headView addSubview:self.versionLabel];
    }
    return _headView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"auout_appicon"]];
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.cornerRadius = 20;
    }
    return _iconView;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [UILabel constructLabel:CGRectZero
                                           text:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
                                           font:[UIFont systemFontOfSize:18]
                                      textColor:[UIColor ALTextGrayColor]];
    }
    return _versionLabel;
}

- (UILabel *)companyLabel {
    if (!_companyLabel) {
        NSString *companyStr = @"LEAP投资管理 版权所有\nCopyrit 2018 © LEAP.All Rights Reserved";
        _companyLabel = [UILabel constructLabel:CGRectZero
                                           text:companyStr
                                           font:[UIFont systemFontOfSize:10]
                                      textColor:[UIColor ALTextGrayColor]];
        _companyLabel.numberOfLines = 2;
        _companyLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 30;
    }
    return _companyLabel;
}


@end
