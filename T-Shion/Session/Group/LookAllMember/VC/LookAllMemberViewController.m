//
//  LookAllMemberViewController.m
//  T-Shion
//
//  Created by together on 2018/12/21.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LookAllMemberViewController.h"
#import "MemberCollectionViewCell.h"
#import "AddMemberViewController.h"
#import "DeleteGroupMemberViewController.h"
#import "OtherInformationViewController.h"
#import "StrangerInfoViewController.h"

@interface LookAllMemberViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *array;
@property (weak, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) GroupModel *group;
@property (copy, nonatomic) NSString *roomId;
@end

@implementation LookAllMemberViewController
- (instancetype)initWithRoomId:(NSString *)roomId data:(NSMutableDictionary *)data {
    self = [super init];
    if (self) {
        self.data = data;
        self.roomId = roomId;
        self.group = [FMDBManager selectGroupModelWithRoomId:roomId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"group_member_title")];
}

- (void)viewWillAppear:(BOOL)animated {
    self.array = nil;
    [self.collectionView reloadData];
    [super viewWillAppear:animated];
}

- (void)addChildView {
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.group.owner isEqualToString:[SocketViewModel shared].userModel.ID]) {
        return self.array.count+2;
    }else {
        if (self.group.inviteSwitch) {
            return self.array.count;
        }else {
            return self.array.count+1;
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(6, 0, 3, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MemberCollectionViewCell class])] forIndexPath:indexPath];
    if (indexPath.row  >= self.array.count) {
        cell.model = nil;
        if (indexPath.row  == self.array.count) {
            cell.setBtn.selected = NO;
        }else {
            cell.setBtn.selected = YES;
        }
    }else {
        cell.model = self.array[indexPath.row];
    }
    @weakify(self)
    cell.modifyBlock = ^(BOOL status) {
        @strongify(self)
        if (status) {
            DeleteGroupMemberViewController *delete = [[DeleteGroupMemberViewController alloc] initWithGroupModel:self.group data:self.data];
            [self.navigationController pushViewController:delete animated:YES];
        }else {
            AddMemberViewController *addMember = [[AddMemberViewController alloc] initWithGroupModel:self.group data:self.data];
            [self.navigationController pushViewController:addMember animated:YES];
        }
    };
    cell.memberClickBlock = ^(MemberModel *model) {
        @strongify(self)
        [self memberClickSubject:model];
    };
    return cell;
}

- (void)memberClickSubject:(MemberModel *)member {
    if (![member.userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
        if (member.isHad==0) {
            OtherInformationViewController *other = [[OtherInformationViewController alloc] init];
            other.model = (FriendsModel*)member;
            [self.navigationController pushViewController:other animated:YES];
        }else {
            StrangerInfoViewController *stranger = [[StrangerInfoViewController alloc] init];
            stranger.model = member;
            [self.navigationController pushViewController:stranger animated:YES];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-40)/5, 70);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MemberCollectionViewCell class] forCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MemberCollectionViewCell class])]];
    }
    return _collectionView;
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
        NSMutableArray *index = [NSMutableArray array];
        NSArray *array = [MemberModel sortMembersArray:[self.data allValues] toIndexArray:index];
        for (NSArray *a in array) {
            [_array addObjectsFromArray:a];
        }
    }
    return _array;
}
@end
