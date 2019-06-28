//
//  InviteFriendView.m
//  T-Shion
//
//  Created by together on 2018/12/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "InviteFriendView.h"
#import "InviteFriendViewModel.h"
#import "InviteFriendTableViewCell.h"
#import "ALContactManager.h"
#import "UIView+BorderLine.h"
#import "SearchField.h"
#import "ZYPinYinSearch.h"

@interface InviteFriendView()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) InviteFriendViewModel *viewModel;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSMutableSet *setArray;
@property (strong, nonatomic) UILabel *inviteCount;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) SearchField *searchField;
@end

@implementation InviteFriendView

- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (InviteFriendViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.searchField];
    [self addSubview:self.table];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.inviteCount];
}

- (void)layoutSubviews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(50);
        make.centerX.equalTo(self);
        make.width.mas_offset(SCREEN_WIDTH);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).with.offset(-50);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.mas_bottom).with.offset(-50);
        }
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.table.mas_bottom);
        make.bottom.equalTo(self.mas_bottom);
        make.centerX.equalTo(self);
        make.width.mas_offset(SCREEN_WIDTH);
    }];
    
    [self.inviteCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self.bottomView);
        make.size.mas_offset(CGSizeMake(200, 50));
    }];
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self);
    [self.viewModel.refreshUISubject subscribeNext:^(id  _Nullable x) {
        [[ALContactManager sharedInstance] al_accessSectionContactsWithDataSource:self.viewModel.originArray Complection:^(BOOL complection, NSArray<ALSectionPerson *> * sections, NSArray<NSString *> *keys) {
            @strongify(self);
            if (!complection) {
                [self.table reloadData];
                return;
            }
            [self.viewModel.addressArray addObjectsFromArray:sections];
            [self.table reloadData];
        }];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.addressArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    ALSectionPerson *sectionModel = self.viewModel.addressArray[section -1];
    return sectionModel.persons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 90;
    } else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > 1) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    label.text = [NSString stringWithFormat:@"    %@",self.titleArray[section]];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    label.backgroundColor = RGB(248, 248, 248);
    label.textColor = [UIColor ALTextGrayColor];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 1) {
        return 0.001;
    }
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        InviteLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([InviteLinkTableViewCell class])] forIndexPath:indexPath];
        @weakify(self)
        cell.itemClickBlock = ^(int index) {
            @strongify(self)
            switch (index) {
                case 0:
                    [self openWhatsapp];
                    break;
                case 1:
                    [self openWeChat];
                    break;
                case 2:
                    [self copyLink];
                    break;
                    
                default:
                    break;
            }
        };
        return cell;
    } else {
        InviteFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithUTF8String:object_getClassName([InviteFriendTableViewCell class])] forIndexPath:indexPath];
        ALSectionPerson *sectionModel = self.viewModel.addressArray[indexPath.section -1];
        ALSysPerson *person = sectionModel.persons[indexPath.row];
        cell.sysPerson = person;
        if (person.selected) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    InviteFriendTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ALSectionPerson *sectionModel = self.viewModel.addressArray[indexPath.section -1];
    ALSysPerson *model = sectionModel.persons[indexPath.row];
//    InviteFriendModel *model = self.viewModel.addressArray[indexPath.row];
    model.selected = YES;
    if (cell.selected) {
        [self.setArray addObject:model];
    }
    self.inviteCount.text = self.setArray.count != 0 ? [NSString stringWithFormat:@"%@(%ld)",Localized(@"Invitation_register"),self.setArray.count]:[NSString stringWithFormat:@"%@",Localized(@"Invitation_register")];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    InviteFriendTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    InviteFriendModel *model = self.viewModel.addressArray[indexPath.row];
    ALSectionPerson *sectionModel = self.viewModel.addressArray[indexPath.section -1];
    ALSysPerson *model = sectionModel.persons[indexPath.row];
    model.selected = NO;
    if (!cell.selected) {
        [self.setArray removeObject:model];
    }
    self.inviteCount.text = self.setArray.count != 0 ? [NSString stringWithFormat:@"%@(%ld)",Localized(@"Invitation_register"),self.setArray.count]: [NSString stringWithFormat:@"%@",Localized(@"Invitation_register")];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchField resignFirstResponder];
}

- (void)openWhatsapp {
    NSString *url = [NSString stringWithFormat:@"whatsapp://send?text=%@", [Localized(@"down_app_link") stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSURL *whatsappURL = [NSURL URLWithString: url];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        // Cannot open whatsapp
    }
}

- (void)openWeChat {
    [self copyLink];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //创建一个url，这个url就是WXApp的url，记得加上：//
        NSURL *url = [NSURL URLWithString:@"weixin://"];
        //打开url
        [[UIApplication sharedApplication] openURL:url];
    });
}

- (void)copyLink {
    ShowWinMessage(Localized(@"Copied_link"));
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    [pab setString:Localized(@"down_app_link")];
}

#pragma mark - getter
- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor = RGB(248, 248, 248);
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.allowsMultipleSelection = YES;
        [_table registerClass:[InviteFriendTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([InviteFriendTableViewCell class])]];
        [_table registerClass:[InviteLinkTableViewCell class] forCellReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([InviteLinkTableViewCell class])]];
    }
    return _table;
}

- (UILabel *)inviteCount {
    if (!_inviteCount) {
        _inviteCount = [[UILabel alloc] init];
        _inviteCount.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _inviteCount.text = Localized(@"Invitation_register");
        _inviteCount.textAlignment = NSTextAlignmentCenter;
        _inviteCount.textColor = [UIColor ALKeyColor];
        _inviteCount.userInteractionEnabled = YES;
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[[tap rac_gestureSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            NSMutableArray *arry = [[NSMutableArray alloc] init];
            for (ALSysPerson *person in self.setArray) {
                ALSysPhone *phoneModel = person.phones.firstObject;
                [arry addObject:phoneModel.phone];
            }
            if (arry.count>0) {
                [self.viewModel.sendMessageSubject sendNext:arry];
            }
            
        }];
        [_inviteCount addGestureRecognizer:tap];
    }
    return _inviteCount;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.borderLineStyle = BorderLineStyleTop;
        _bottomView.borderLineColor = [UIColor ALLineColor].CGColor;
    }
    return _bottomView;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[Localized(@"Invitation_link"),Localized(@"Address_book")];
    }
    return _titleArray;
}

- (NSMutableSet *)setArray{
    if (!_setArray) {
        _setArray = [NSMutableSet set];
    }
    return _setArray;
}

- (SearchField *)searchField {
    if (!_searchField) {
        _searchField = [[SearchField alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-30, 30)];
        @weakify(self)
        [[_searchField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            if (x.length<1||[x isEqualToString:@""]) {
                [self searchResultReloadWithArray:self.viewModel.originArray];
            }else {
                [ZYPinYinSearch searchByPropertyName:@"fullName" withOriginalArray:self.viewModel.originArray searchText:x success:^(NSArray *results) {
                    @strongify(self)
                    [self searchResultReloadWithArray:results];
                } failure:nil];
            }
        }];
    }
    return _searchField;
}

- (void)searchResultReloadWithArray:(NSArray *)array {
    @weakify(self)
    [[ALContactManager sharedInstance] al_accessSectionContactsWithDataSource:array Complection:^(BOOL complection, NSArray<ALSectionPerson *> * sections, NSArray<NSString *> *keys) {
        @strongify(self);
        if (!complection) {
            [self.table reloadData];
            return;
        }
        [self.viewModel.addressArray removeAllObjects];
        [self.viewModel.addressArray addObjectsFromArray:sections];
        [self.table reloadData];
    }];
}
@end
