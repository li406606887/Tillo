//
//  DeleteGroupMemberViewController.m
//  T-Shion
//
//  Created by together on 2018/8/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "DeleteGroupMemberViewController.h"
#import "OperMemberView.h"
#import "DeleteGroupMemberViewModel.h"

@interface DeleteGroupMemberViewController ()
@property (strong, nonatomic) DeleteGroupMemberViewModel *viewModel;
@property (strong, nonatomic) OperMemberView *mainView;
@property (weak, nonatomic) NSMutableDictionary *data;
@property (copy, nonatomic) GroupModel *model;
@end

@implementation DeleteGroupMemberViewController
- (instancetype)initWithGroupModel:(GroupModel *)model data:(NSMutableDictionary *)data {
    self = [super init];
    if (self) {
        self.data = data;
        self.model = model;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Delete_Member")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)rightButton {
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    menu.frame = CGRectMake(0, 0, 70, 30);
    menu.frame = CGRectMake(0, 0, 70, 30);
    menu.layer.masksToBounds = YES;
    menu.layer.cornerRadius = 14;
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
    [menu setTitle:Localized(@"Delete") forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(deleteMember) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:menu];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)setModel:(GroupModel *)model {
    _model = model;
    [self.view addSubview:self.mainView];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.deleteSuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSString *content = [NSString stringWithFormat:@""];
        for (MemberModel *member in self.viewModel.memberArray) {
            [FMDBManager updateGroupMemberDeflagWithRoomId:self.model.roomId memberId:member.userId];
            content = [NSString stringWithFormat:@"%@“%@”、",content,member.name];
            MemberModel *model = [self.data objectForKey:member.userId];
            model.delFlag = 1;
        }
        if (content.length>1) {
            content = [content substringWithRange:NSMakeRange(0, [content length] - 1)];
        }
        MessageModel *model = [[MessageModel alloc] init];
        model.messageId = [NSUUID UUID].UUIDString;
        model.type = @"system";
        model.sender = [SocketViewModel shared].userModel.ID;
        model.timestamp = [NSDate getNowTimestamp];
        model.roomId = self.model.roomId;
        model.content = [NSString stringWithFormat:@"%@%@%@",Localized(@"I_removed"),content,Localized(@"from_the_group")];
        [FMDBManager insertMessageWithContentModel:model];
        [[SocketViewModel shared].sendMessageSubject sendNext:model];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"groupMemberCountChange" object:nil];
    }];
}

- (void)deleteMember {
    if (self.mainView.memberArray.count<1) {
        ShowWinMessage(Localized(@"Please_select_the_person_you_want_to_delete"));
        return;
    }
    self.viewModel.memberArray = self.mainView.memberArray;
    NSMutableArray *idAry = [NSMutableArray array];
    for (MemberModel *member in self.mainView.memberArray) {
        [idAry addObject:member.userId];
    }

    NSDictionary *param = @{@"userIds":idAry,@"roomId":self.model.roomId,@"operInfo":[SocketViewModel shared].userModel.name};
    [self.viewModel.deleteMemberCommand execute:param];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (OperMemberView *)mainView {
    if (!_mainView) {
        _mainView = [[OperMemberView alloc] initWithFrame:CGRectZero roomId:self.model.roomId type:@"delete"];
    }
    return _mainView;
}

- (DeleteGroupMemberViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[DeleteGroupMemberViewModel alloc] init];
    }
    return _viewModel;
}
@end
