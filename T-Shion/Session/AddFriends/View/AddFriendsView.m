//
//  AddFriendsView.m
//  T-Shion
//
//  Created by together on 2018/4/2.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddFriendsView.h"
#import "AddFriendsTableViewCell.h"
#import "AddFriendsViewModel.h"

@interface AddFriendsView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) AddFriendsViewModel *viewModel;

@property (strong, nonatomic) UITableView *table;

@end
@implementation AddFriendsView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (AddFriendsViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.table];
    
    [self setNeedsUpdateConstraints];
}

- (void)bindViewModel {

}

- (void)updateConstraints {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([AddFriendsTableViewCell class])] forIndexPath:indexPath];
    cell.model = self.viewModel.dataArray[indexPath.row];
    @weakify(self)
    cell.buttonClickBlock = ^(AddFriendsModel *model) {
     @strongify(self)
        [self.viewModel.showAddViewSubject sendNext:model];
    };
    return cell;
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
        _table.backgroundColor = DEFAULT_COLOR;
        _table.sectionHeaderHeight = 0.5f;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table registerClass:[AddFriendsTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([AddFriendsTableViewCell class])]];
    }
    return _table;
}

@end
