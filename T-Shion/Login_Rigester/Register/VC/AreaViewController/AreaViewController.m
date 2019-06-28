//
//  AreaViewController.m
//  T-Shion
//
//  Created by together on 2018/4/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AreaViewController.h"
#import "AreaTableViewCell.h"
#import "AreaModel.h"
#import "ALDialCodeManager.h"
#import "ZYPinYinSearch.h"

@interface AreaViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UITableView *table;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSArray *keys;
@property (nonatomic, assign) BOOL isEnglish;
@property (nonatomic, strong) UISearchController *searchVC;
@property (nonatomic, strong) NSMutableArray *resultArray;//搜索结果
@property (nonatomic, strong) NSMutableArray *dataSource;//数据源

@end

@implementation AreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"register_dialCode");
    [self setUpNavtionLeft];
    [self.view addSubview:self.table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setUpNavtionLeft {
    
    NSString *imageName = @"navigation_close";
    
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
    self.searchVC.active = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bindViewModel {
    self.isEnglish = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"en"];
    
    @weakify(self);
    [[ALDialCodeManager sharedInstance] al_dialCodeSectionWithEnglish:self.isEnglish complection:^(NSArray<ALDialCodeSectionModel *> *sections, NSArray<NSString *> *keys, NSArray<ALDialCodeModel *> *dataSource) {
        @strongify(self);
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:dataSource];
        [self.dataArray addObjectsFromArray:sections];
        self.keys = keys;
        [self.table reloadData];
    }];

}

//- (void)viewDidLayoutSubviews {
//    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
//    [super viewDidLayoutSubviews];
//}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchVC.active) {
        return 1;
    }
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchVC.active) {
        return self.resultArray.count;
    }
    
    ALDialCodeSectionModel *sectionModel = self.dataArray[section];
    return sectionModel.dialArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchVC.active) {
        return nil;
    }
    return self.keys[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.searchVC.active) {
        return nil;
    }
    return self.keys;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchVC.active) {
        return 0.0001;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.searchVC.active) {
        return 0.0001;
    }
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AreaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([AreaTableViewCell class])] forIndexPath:indexPath];

    
    if (self.searchVC.active) {
        ALDialCodeModel *model = self.resultArray[indexPath.row];
        cell.countryName.text = self.isEnglish ? model.en_name:model.cn_name;
        cell.countryCode.text = [NSString stringWithFormat:@"+%@",model.dialCode];
    } else {
        ALDialCodeSectionModel *sectionModel = self.dataArray[indexPath.section];
        ALDialCodeModel *model = sectionModel.dialArray[indexPath.row];
        cell.countryName.text = self.isEnglish ? model.en_name:model.cn_name;
        cell.countryCode.text = [NSString stringWithFormat:@"+%@",model.dialCode];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchVC.active) {
        self.searchVC.active = NO;
        ALDialCodeModel *model = self.resultArray[indexPath.row];
        self.areaNameBlock(model.dialCode);
    } else {
        ALDialCodeSectionModel *sectionModel = self.dataArray[indexPath.section];
        ALDialCodeModel *model = sectionModel.dialArray[indexPath.row];
        self.areaNameBlock(model.dialCode);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (!self.searchVC.active) {
        return;
    }
    NSString *inputStr = searchController.searchBar.text ;
    NSLog(@"-------%@",inputStr);
    
    BOOL isNumber = [self deptNumInputShouldNumber:inputStr];
    NSString *propertyName;
    if (isNumber) {
        propertyName = @"dialCode";
    } else {
        propertyName = self.isEnglish ? @"en_name" : @"cn_name";
    }
    @weakify(self);
    [ZYPinYinSearch searchByPropertyName:propertyName withOriginalArray:self.dataSource searchText:inputStr success:^(NSArray *results) {
        @strongify(self);
        [self.resultArray removeAllObjects];
        [self.resultArray addObjectsFromArray:results];
        [self.table reloadData];
    } failure:nil];
    
    [self.table reloadData];
}

- (BOOL)deptNumInputShouldNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

#pragma mark - UISearchControllerDelegate
- (void)didDismissSearchController:(UISearchController *)searchController {
    [self.table reloadData];
}

#pragma mark - getter
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.sectionIndexColor = [UIColor ALPlaceholderColor];
        _table.tableHeaderView = self.searchVC.searchBar;
        
        [_table registerClass:[AreaTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([AreaTableViewCell class])]];
    }
    return _table;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

- (UISearchController *)searchVC {
    if (!_searchVC) {
        _searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchVC.delegate = self;
        _searchVC.searchResultsUpdater = self;
        //搜索时，背景变暗色
        _searchVC.dimsBackgroundDuringPresentation = NO;
        //隐藏导航栏
        _searchVC.hidesNavigationBarDuringPresentation = NO;
    }
    return _searchVC;
}

- (NSMutableArray *)resultArray {
    if (!_resultArray) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
@end
