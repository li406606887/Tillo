//
//  LanguageViewController.m
//  T-Shion
//
//  Created by together on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LanguageViewController.h"
#import "AppDelegate.h"
#import "BaseTableViewCell.h"

@interface LanguageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) UIButton *btn;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"Languages")];
    [self setUpNavtionLeft];
}

- (void)addChildView {
    [self.view addSubview:self.table];
}

- (void)viewDidLayoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)setUpNavtionLeft {
    
    NSString *imageName = @"NavigationBar_Back";
    
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClick)];
    backBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        spaceRight.width = -100;
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        
        spaceLeft.width = -25;
        backBtn.imageInsets = UIEdgeInsetsMake(0, 22, 0, -22);
        spaceRight.width = 15;
        self.navigationItem.leftBarButtonItems = @[spaceLeft, backBtn, spaceRight];
    }
}

- (void)backButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setLanguage {
    if (self.selectedIndexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.main = nil;
    delegate.slideVC = nil;
    delegate.window.rootViewController = delegate.slideVC;
    delegate.main.selectedIndex = 2;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageCell"];
    cell.textLabel.text = self.array[indexPath.row];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"];
    if (indexPath.row == 0) {
        if ([value isEqualToString:@"zh-Hans"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndexPath = indexPath;
        }
    } else {
        if ([value isEqualToString:@"en"]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndexPath = indexPath;
        }
    }
    
    cell.tintColor = [UIColor ALKeyColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:self.selectedIndexPath.section]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectedIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self setLanguage];
}

#pragma mark - getter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = [UIColor ALKeyBgColor];
        _table.separatorColor = [UIColor ALLineColor];
        [_table registerClass:[BaseTableViewCell class] forCellReuseIdentifier:@"LanguageCell"];
    }
    return _table;
}


- (NSArray *)array {
    if (!_array) {
        _array = @[@"简体中文",@"English"];
    }
    return _array;
}
@end
