//
//  StorageView.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "StorageView.h"
#import "StorageViewModel.h"

@interface StorageView ()<UITableViewDelegate,UITableViewDataSource>

@property (strong , nonatomic) StorageViewModel *viewModel;
@property (nonatomic, strong) UITableView *mainTableView;

@end


@implementation StorageView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (StorageViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

#pragma mark - private
- (void)setupViews {
    [self addSubview:self.mainTableView];
}

- (void)updateConstraints {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}

- (NSString *)getCacheSize{
    //得到缓存路径
    NSString * path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager * manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    //首先判断是否存在缓存文件
    if ([manager fileExistsAtPath:path]) {
        NSArray * childFile = [manager subpathsAtPath:path];
        for (NSString * fileName in childFile) {
            //缓存文件绝对路径
            NSString * absolutPath = [path stringByAppendingPathComponent:fileName];
            size = size + [manager attributesOfItemAtPath:absolutPath error:nil].fileSize;
        }
        //计算sdwebimage的缓存和系统缓存总和
//        size = size + [[SDWebImageManager sharedManager].imageCache getSize];
        size = size + [[SDImageCache sharedImageCache] totalDiskSize];
    }
    return [NSString stringWithFormat:@"%.2fM",(size/1024/1024)];
}

- (void)cleanCache{
    //获取缓存路径
    NSString * path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager * manager = [NSFileManager defaultManager];
    //判断是否存在缓存文件
    if ([manager fileExistsAtPath:path]) {
        NSArray * childFile = [manager subpathsAtPath:path];
        //逐个删除缓存文件
        for (NSString *fileName in childFile) {
            NSString * absolutPat = [path stringByAppendingPathComponent:fileName];
            [manager removeItemAtPath:absolutPat error:nil];
        }
        //删除sdwebimage的缓存
        [[SDImageCache sharedImageCache] clearMemory];
    }
    //这里是又调用了得到缓存文件大小的方法，是因为不确定是否删除了所有的缓存，所以要计算一遍，展示出来
    [self getCacheSize];
    
    [self.mainTableView reloadData];
    ShowWinMessage(Localized(@"set_storage_clean_success"));
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *resuseID = @"dadawdaw";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:resuseID];
    }
    cell.textLabel.font = [UIFont ALBoldFontSize15];
    cell.detailTextLabel.font = [UIFont ALFontSize15];
    cell.textLabel.text = Localized(@"set_storage_clean");
    cell.detailTextLabel.text = [self getCacheSize];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self cleanCache];
}

#pragma mark - getter and setter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = RGB(248, 248, 248);
        _mainTableView.delegate = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

@end
