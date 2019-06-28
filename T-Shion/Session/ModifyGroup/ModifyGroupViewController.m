//
//  ModifyGroupViewController.m
//  T-Shion
//
//  Created by together on 2018/7/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ModifyGroupViewController.h"

@interface ModifyGroupViewController ()
@property (strong, nonatomic) UITextField *filed;
@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation ModifyGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.modifyType == 0 ? Localized(@"Edit_Group_Name") : @"修改我在本群昵称";
    [self setRightNavigation];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [IQKeyboardManager sharedManager].enable = YES;
    [super viewWillDisappear:animated];
}

- (void)setModel:(GroupModel *)model {
    _model = model;
    self.filed.text = self.modifyType == 0 ? model.name : model.nickNameInGroup;
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

- (void)addChildView {
    [self.view addSubview:self.filed];
    [self.filed becomeFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [self.filed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(15);
        make.centerX.equalTo(self.view);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 50));
    }];
    [super viewDidLayoutSubviews];
}

- (void)modifyGroupNameWithParam:(NSDictionary *)param {
    if (self.filed.text.length < 1) {
        ShowWinMessage(Localized(@"Please_enter_the_correct_group_name"));
        return;
    }
    [self.filed isFirstResponder];
    LoadingView(@"");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        RequestModel *model = [TSRequest putRequetWithApi:api_put_modify_group_name withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            HiddenHUD
            if (!error) {
                self.model.name = self.filed.text;
                [FMDBManager updateGroupListWithModel:self.model];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                if (model!=nil) {
                    if (model.message.length>0) {
                        ShowWinMessage(model.message);
                    }
                }
            }
        });
    });
}


- (void)modifyNickNameInGroupWithParam:(NSDictionary *)param {
    [self.filed isFirstResponder];
    LoadingView(@"");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        RequestModel *model = [TSRequest putRequetWithApi:api_put_modify_nickNameInGroup withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            HiddenHUD
            if (!error) {
                self.model.nickNameInGroup = self.filed.text;
                MemberModel *member = [FMDBManager selectedGroupMemberWithRoomId:self.model.roomId memberId:[SocketViewModel shared].userModel.ID];
                member.groupName = self.filed.text;
                [FMDBManager updateGroupMemberWithRoomId:self.model.roomId member:member];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                if (model!=nil) {
                    if (model.message.length>0) {
                        ShowWinMessage(model.message);
                    }
                }
            }
        });
    });
}

#pragma mark - getter
- (UITextField *)filed {
    if (!_filed) {
        _filed = [[UITextField alloc] init];
        _filed.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 34)];
        _filed.backgroundColor = [UIColor whiteColor];
        _filed.leftViewMode = UITextFieldViewModeAlways;
        _filed.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        @weakify(self)
        [[_filed rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            if (self.modifyType == 0) {
                if (self.filed.text.length == 0) {
                    self.submitBtn.enabled = NO;
                } else if ([x isEqualToString:self.model.name]) {
                    self.submitBtn.enabled = NO;
                } else {
                    self.submitBtn.enabled = YES;
                }
            } else {
                if (self.filed.text.length == 0) {
                    self.submitBtn.enabled = NO;
                } else if ([x isEqualToString:self.model.nickNameInGroup]) {
                    self.submitBtn.enabled = NO;
                } else {
                    self.submitBtn.enabled = YES;
                }
            }
            
            if (x.length >= 30) {
                self.filed.text = [x substringToIndex:30];
            }
            
        }];
    }
    return _filed;
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
            if (self.modifyType == 0) {
                [self modifyGroupNameWithParam:@{@"groupName":self.filed.text,
                                                 @"roomId":self.model.roomId,
                                                 @"operInfo":[SocketViewModel shared].userModel.name}];
            } else {
                [self modifyNickNameInGroupWithParam:@{@"nickName":self.filed.text,
                                                       @"roomId":self.model.roomId}];
            }
        }];
    }
    return _submitBtn;
}

@end
