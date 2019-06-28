//
//  NewInviteConfirmViewController.m
//  T-Shion
//
//  Created by together on 2019/4/20.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NewInviteConfirmViewController.h"
#import "InviteMemberView.h"

@interface NewInviteConfirmViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) InviteMemberView *inviterView;
@property (strong, nonatomic) UILabel *inviteTitle;
@property (strong, nonatomic) UIButton *inviteBtn;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation NewInviteConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addChildView {
    [self.view addSubview:self.inviterView];
}

- (void)viewDidLayoutSubviews {
    [self.inviterView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(75, 110));
        make.top.equalTo(self.view).with.offset(30);
        make.centerX.equalTo(self.view);
    }];
    
    [self.inviteTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.inviterView.mas_bottom).with.offset(30);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 22));
    }];
    [super viewDidLayoutSubviews];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (InviteMemberView *)inviterView {
    if (!_inviterView) {
        _inviterView = [[InviteMemberView alloc] init];
        _inviterView.icon.layer.cornerRadius = 37.5;
        _inviterView.name.textColor = RGB(51, 51, 51);
        _inviterView.name.font = [UIFont ALFontSize15];
    }
    return _inviterView;
}

- (UIButton *)inviteBtn {
    if (!_inviteBtn) {
        _inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _inviteBtn.backgroundColor = RGB(95, 206, 173);
        [_inviteBtn.titleLabel setFont:[UIFont ALBoldFontSize17]];
        [_inviteBtn setTitle:@"" forState:UIControlStateNormal];
        [_inviteBtn setTitle:@"" forState:UIControlStateSelected];
        _inviteBtn.layer.cornerRadius = 20;
        _inviteBtn.layer.masksToBounds = YES;
    }
    return _inviteBtn;
}

- (UILabel *)inviteTitle {
    if (!_inviteTitle) {
        _inviteTitle = [[UILabel alloc] init];
        [_inviteTitle setFont:[UIFont ALBoldFontSize18]];
        _inviteTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _inviteTitle;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
    }
    return _scrollView;
}
@end
