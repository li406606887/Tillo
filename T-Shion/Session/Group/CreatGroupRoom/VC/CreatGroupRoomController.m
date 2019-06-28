//
//  CreatGroupRoomController.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "CreatGroupRoomController.h"
#import "CreatGroupRoomViewModel.h"
#import "OperMemberView.h"
#import "GroupMessageRoomController.h"

@interface CreatGroupRoomController ()
@property (strong, nonatomic) OperMemberView *mainView;
@property (strong, nonatomic) CreatGroupRoomViewModel *viewModel;
@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation CreatGroupRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Select_contacts")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self setRightNavigation];
    [self.view addSubview:self.mainView];
}

- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.submitBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.creatSuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        GroupModel *model = (GroupModel *)x;
        GroupMessageRoomController *room = [[GroupMessageRoomController alloc] initWithModel:model count:20 type:Loading_NO_NEW_MESSAGES];
        
        //add by wsp:创建群聊成功后返回会回到选择创建的页面 ， 2019.4.30
        [UIView animateWithDuration:0 animations:^{
            [self.navigationController pushViewController:room animated:YES];
        } completion:^(BOOL finished) {
            NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [vcArray removeObjectAtIndex:vcArray.count - 2];
            self.navigationController.viewControllers = vcArray;
        }];
        //end
    }];
}

- (void)menuCellClick {
    if (self.mainView.memberArray.count<2) {
        ShowWinMessage(Localized(@"Please_select_at_least_two_members"));
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
    
    NSString *name = [NSString stringWithFormat:@"%@%@",[SocketViewModel shared].userModel.name,Localized(@"Group")];
    
    UserInfoModel *userInfo = [SocketViewModel shared].userModel;
    NSDictionary *oper = @{@"name":userInfo.name,
                           @"avatar":[NSString stringWithFormat:@"%@",userInfo.avatar],
                           @"userId":userInfo.ID};
    
    NSDictionary *param = @{@"name":name,
                            @"memberIds":idArray,
                            @"members":obArray,
                            @"operInfo":oper,
                            @"isEncrypt":(self.isCrypt?@"1":@"0")};
    self.viewModel.memberArray = self.mainView.memberArray;
    [self.viewModel.creatGroupCommand execute:param];
}


#pragma mark - getter
- (CreatGroupRoomViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CreatGroupRoomViewModel alloc] init];
        _viewModel.isCrypt = self.isCrypt;
    }
    return _viewModel;
}

- (OperMemberView *)mainView {
    if (!_mainView) {
        _mainView = [[OperMemberView alloc] initWithFrame:CGRectZero roomId:@"" type:@"creat"];
    }
    return _mainView;
}

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.frame = CGRectMake(0, 0, 60, 28);
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.layer.cornerRadius = 14;
        
        [_submitBtn setTitle:Localized(@"UserInfo_Done") forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont ALFontSize15];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        _submitBtn.enabled = NO;
        
        @weakify(self)
        [[_submitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self menuCellClick];
        }];
    }
    return _submitBtn;
}

@end
