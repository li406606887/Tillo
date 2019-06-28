//
//  ChooseAtManView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ChooseAtManView.h"
#import "ChooseAtManViewModel.h"
#import "ChooseAtManTableViewCell.h"

@interface ChooseAtManView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ChooseAtManViewModel *viewModel;
@property (nonatomic, strong) UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *memberArray;

@end

@implementation ChooseAtManView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (ChooseAtManViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.mainTableView];
}

- (void)updateConstraints {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : self.memberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *resuseID = @"AllAtCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:resuseID];
        }
        cell.textLabel.font = [UIFont ALBoldFontSize16];
        cell.textLabel.textColor = [UIColor ALKeyColor];
        cell.textLabel.text = @"@所有人";
        return cell;
    } else {
        ChooseAtManTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseAtManTableViewCellReuseIdentifier];
        cell.model = self.memberArray[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 50 : 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MemberModel *member;
    
    if (indexPath.section == 0) {
        member = [MemberModel new];
        member.userId = @"-1";
        member.name = @"所有人";
    } else {
        member = self.memberArray[indexPath.row];
        if (member.isHad == 2) {
            ShowWinMessage(@"不能选择自己");
            return;
        }
    }
   
    [self.viewModel.chooseEndSubject sendNext:member];
}

#pragma mark - getter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor ALKeyBgColor];
        [_mainTableView registerClass:[ChooseAtManTableViewCell class] forCellReuseIdentifier:ChooseAtManTableViewCellReuseIdentifier];
        
    }
    return _mainTableView;
}

- (NSMutableArray *)memberArray {
    if (!_memberArray) {
        NSMutableArray *indexArray = [NSMutableArray array];
        NSArray *array = [MemberModel sortMembersArray:[FMDBManager selectedMemberWithRoomId:self.viewModel.roomID] toIndexArray:indexArray];
        _memberArray = [NSMutableArray array];
        for (NSArray *a in array) {
            [_memberArray addObjectsFromArray:a];
        }

    }
    return _memberArray;
}

@end
