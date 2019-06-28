
//
//  GroupSetingHeadView.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSetingHeadView.h"
#import "MemberCollectionViewCell.h"
#import "GroupSetingViewModel.h"

@interface GroupSetingHeadView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) GroupSetingViewModel *viewModel;
@property (strong, nonatomic) UIButton *lookAll;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@end

@implementation GroupSetingHeadView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (GroupSetingViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.collectionView];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 85);
}

- (void)layoutSubviews {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.refreshMemberSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.viewModel.memberArray = nil;
        [self refreshView];
        [self.collectionView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.viewModel.model.owner isEqualToString:[SocketViewModel shared].userModel.ID]) {
        if (self.viewModel.memberArray.count<9) {
            self.count = self.viewModel.memberArray.count+2;
        }else {
            self.count = 10;
        }
    }else if(self.viewModel.model.inviteSwitch){
        if (self.viewModel.memberArray.count<10) {
            self.count = self.viewModel.memberArray.count;
        }else {
            self.count = 10;
        }
    }else {
        if (self.viewModel.memberArray.count<10) {
            self.count = self.viewModel.memberArray.count+1;
        }else {
            self.count = 10;
        }
    }
    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MemberCollectionViewCell class])] forIndexPath:indexPath];
    if ([self.viewModel.model.owner isEqualToString:[SocketViewModel shared].userModel.ID]) {
        if (indexPath.row + 2 == self.count) {
            cell.setBtn.selected = NO;
            cell.model = nil;
        }else if (indexPath.row + 2 > self.count) {
            cell.setBtn.selected = YES;
            cell.model = nil;
        }else {
            cell.model = self.viewModel.memberArray[indexPath.row];
        }
    }else {
        if(self.viewModel.model.inviteSwitch){
            cell.model = self.viewModel.memberArray[indexPath.row];
        }else {
            if (indexPath.row +1 == self.count) {
                cell.setBtn.selected = NO;
                cell.model = nil;
            }else {
                cell.model = self.viewModel.memberArray[indexPath.row];
            }
        }
       
    }
    @weakify(self)
    cell.modifyBlock = ^(BOOL status) {
        @strongify(self)
        [self.viewModel.addMemberSubject sendNext:@(status)];
    };
    cell.memberClickBlock = ^(MemberModel *model) {
        @strongify(self)
        [self.viewModel.memberClickSubject sendNext:model];
    };
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
   if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"lookAllMember" forIndexPath:indexPath];
        if(footerView == nil) {
            footerView = [[UICollectionReusableView alloc] init];
        }
        footerView.backgroundColor = [UIColor lightGrayColor];
       [footerView addSubview:self.lookAll];
        return footerView;
    }
    return nil;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3.f;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentSize"]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.collectionView.contentSize.height);
    }
}

- (void)refreshView {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 85);
    self.layout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, 0.0f);  // 设置footerView大小
    if ([self.viewModel.model.owner isEqualToString:[SocketViewModel shared].userModel.ID]) {
        if (self.viewModel.memberArray.count>8) {
            self.layout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, 45.0f);  // 设置footerView大小
        }
    }else {
        if (self.viewModel.memberArray.count>9) {
            self.layout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, 45.0f);  // 设置footerView大小
        }
    }
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        self.layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout.itemSize = CGSizeMake((SCREEN_WIDTH-40)/5, 70);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self refreshView];
        [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"lookAllMember"];
        [_collectionView registerClass:[MemberCollectionViewCell class] forCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([MemberCollectionViewCell class])]];
    }
    return _collectionView;
}

- (UIButton *)lookAll {
    if (!_lookAll) {
        _lookAll = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lookAll setTitle:[NSString stringWithFormat:@"%@ >",Localized(@"view_group_members")] forState:UIControlStateNormal];
        [_lookAll setTitleColor:[UIColor ALTextGrayColor] forState:UIControlStateNormal];
        [_lookAll setBackgroundColor:[UIColor whiteColor]];
        [_lookAll.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_lookAll setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
        @weakify(self)
        [[_lookAll rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.viewModel.lookAllMemberSubject sendNext:nil];
        }];
    }
    return _lookAll;
}


- (UIView *)creatAddOrSubtractButtonWithImage:(NSString *)image tag:(int)tag{
    UIView *view = [[UIView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 25;
    [button setTitle:image forState:UIControlStateNormal];;
    [button setTitleColor:HEXCOLOR(0x518FFF) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:30]];
    button.layer.borderColor = HEXCOLOR(0x518FFF).CGColor;
    button.layer.borderWidth = 1.0f;
    button.tag = tag;
    [view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(view);
        make.size.mas_offset(CGSizeMake(50, 50));
    }];
    @weakify(self)
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.viewModel.addMemberSubject sendNext:@(x.tag)];

    }];
    return view;
}


- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}
@end
