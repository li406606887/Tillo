//
//  AddMemberViewController.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddMemberViewController.h"
#import "CreatGroupTableViewCell.h"
#import "OperMemberView.h"
#import "AddMemberViewModel.h"
#import "YMEncryptionManager.h"

@interface AddMemberViewController ()
@property (strong, nonatomic) OperMemberView *mainView;
@property (strong, nonatomic) AddMemberViewModel *viewModel;
@property (weak, nonatomic) NSMutableDictionary *data;
@end

@implementation AddMemberViewController

- (instancetype)initWithGroupModel:(GroupModel *)model data:(NSMutableDictionary *)data {
    self = [super init];
    if (self) {
        self.viewModel.model = model;
        self.data = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Add_Member")];
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (UIBarButtonItem *)rightButton {
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    menu.frame = CGRectMake(0, 0, 70, 30);
    menu.layer.masksToBounds = YES;
    menu.layer.cornerRadius = 14;
    
    [menu setTitle:Localized(@"UserInfo_Done") forState:UIControlStateNormal];
    menu.titleLabel.font = [UIFont ALFontSize15];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
    [menu addTarget:self action:@selector(menuCellClick) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:menu];
}

- (void)menuCellClick {
    if (self.mainView.memberArray.count<1) {
        ShowWinMessage(Localized(@"Please_select_the_group_member_you_want_to_add"));
        return;
    }
    NSMutableArray *idArray = [NSMutableArray array];
    NSMutableArray *obArray = [NSMutableArray array];
    for (MemberModel *member in self.mainView.memberArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:member.userId forKey:@"userId"];
        [dic setObject:member.name forKey:@"name"];
        [dic setObject:[NSString stringWithFormat:@"%@",member.avatar] forKey:@"avatar"];
        [obArray addObject:dic];
        [idArray addObject:member.userId];
    }
    
    NSDictionary *param = @{@"userIds":idArray,
                            @"roomId":self.viewModel.model.roomId,
                            @"members":obArray,
                            @"operInfo":[SocketViewModel shared].userModel.name};
    
    [self.viewModel.addMemberCommand execute:param];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.addSuccessSucject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:0];
        NSString *content = [NSString stringWithFormat:@""];
        for (NSDictionary *data in x) {
            MemberModel *member = [MemberModel mj_objectWithKeyValues:data];
            member.delFlag = 0;
            [FMDBManager updateGroupMemberWithRoomId:member.roomId member:member];
            content = [NSString stringWithFormat:@"%@“%@”、",content,member.name];
            [userIds addObject:member.userId];
            MemberModel *mem = [FMDBManager selectedMemberWithRoomId:member.roomId memberID:member.userId];
            [self.data setObject:mem forKey:mem.userId];
        }
        if (content.length>1) {
            content = [content substringWithRange:NSMakeRange(0, [content length] - 1)];
        }
        MessageModel *model = [[MessageModel alloc] init];
        model.messageId = [NSUUID UUID].UUIDString;
        model.type = @"system";
        model.sender = [SocketViewModel shared].userModel.ID;
        model.timestamp = [NSDate getNowTimestamp];
        model.roomId = self.viewModel.model.roomId;
        if (self.viewModel.model.isCrypt)
            model.content = [NSString stringWithFormat:@"%@%@%@%@",Localized(@"You"),Localized(@"Invite"),Localized(content),Localized(@"crypt_join_group")];
        else
            model.content = [NSString stringWithFormat:@"%@%@%@%@",Localized(@"You"),Localized(@"Invite"),Localized(content),Localized(@"Join_Room")];
        [FMDBManager insertMessageWithContentModel:model];
        [[SocketViewModel shared].sendMessageSubject sendNext:model];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"groupMemberCountChange" object:nil];
        if (self.viewModel.model.isCrypt)
            [[YMEncryptionManager shareManager] getGroupUserKeys:userIds];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (OperMemberView *)mainView {
    if (!_mainView) {
        _mainView = [[OperMemberView alloc] initWithFrame:CGRectZero roomId:self.viewModel.model.roomId type:@"add"];
    }
    return _mainView;
}

- (AddMemberViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[AddMemberViewModel alloc] init];
    }
    return _viewModel;
}

@end
