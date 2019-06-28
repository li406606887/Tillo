//
//  SendInviteMsgController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SendInviteMsgController.h"
#import "MessageRoomViewController.h"

@interface SendInviteMsgController ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *msgFiled;
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation SendInviteMsgController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"UserInfo_Verification");
    [self setRightNavigation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.self.msgFiled];
}

- (void)viewDidLayoutSubviews {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(15);
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo(30);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.tipLabel.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    [self.msgFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.bgView);
        make.left.equalTo(self.bgView.mas_left).with.offset(10);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.sendBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.addFriendsSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x) {
            MessageRoomViewController *message = [[MessageRoomViewController alloc] initWithModel:x count:20 type:Loading_NO_NEW_MESSAGES];
            [self.navigationController pushViewController:message animated:YES];
            NSMutableArray *pageArray =  [self.navigationController.childViewControllers mutableCopy];
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, pageArray.count-2)];
            [pageArray removeObjectsAtIndexes:set];
            [self.navigationController setViewControllers:pageArray animated:NO];
        }else {
            ShowWinMessage(Localized(@"UserInfo_Verification_Success"));
            if (self.isNavPop) {
                UIViewController *tempVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
                [self.navigationController popToViewController:tempVC animated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}

#pragma mark - getter
- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(0, 0, 60, 28);
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.layer.cornerRadius = 14;
        
        [_sendBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_sendBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        [_sendBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_sendBtn setTitle:Localized(@"Send") forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont ALFontSize15];
        
        @weakify(self)
        [[_sendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:@"0" forKey:@"status"];//0表示申请加好友  1表示通过
            [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
            [param setObject:self.viewModel.model.uid forKey:@"receiver"];
            [param setObject:self.msgFiled.text forKey:@"remark"];
            [self.viewModel.addFriendsCommand execute:param];
        }];
    }
    return _sendBtn;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel constructLabel:CGRectZero
                                       text:Localized(@"UserInfo_Verification_Tip")
                                       font:[UIFont ALFontSize12]
                                  textColor:[UIColor ALTextGrayColor]];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _tipLabel;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UITextField *)msgFiled {
    if (!_msgFiled) {
        _msgFiled = [[UITextField alloc] init];
        _msgFiled.backgroundColor = [UIColor whiteColor];
        _msgFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _msgFiled.font = [UIFont ALFontSize15];
        _msgFiled.text = [NSString stringWithFormat:@"%@%@",Localized(@"UserInfo_Verification_IM"),[SocketViewModel shared].userModel.name];
        @weakify(self)
        [[_msgFiled rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            self.sendBtn.enabled = x.length > 0;
            
            if (x.length >= 30) {
                self.msgFiled.text = [x substringToIndex:30];
            }
            
        }];
        
    }
    return _msgFiled;
}

- (SendInviteViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SendInviteViewModel alloc] init];
    }
    return _viewModel;
}

@end
