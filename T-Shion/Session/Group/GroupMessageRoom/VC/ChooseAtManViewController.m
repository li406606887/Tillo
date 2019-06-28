//
//  ChooseAtManViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ChooseAtManViewController.h"
#import "ChooseAtManViewModel.h"
#import "ChooseAtManView.h"

@interface ChooseAtManViewController ()

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) ChooseAtManViewModel *viewModel;
@property (nonatomic, strong) ChooseAtManView *mainView;

@end

@implementation ChooseAtManViewController

- (instancetype)initWithRoomID:(NSString *)roomID {
    if (self = [super init]) {
        self.viewModel.roomID = roomID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择提醒的成员";
    [self setRightNavigation];
}

- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancelBtn];
    
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
    [self.view addSubview:self.mainView];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self);
    [self.viewModel.chooseEndSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
    
        [self dismissViewControllerAnimated:YES completion:^{
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseAtUserWithData:)]) {
                [self.delegate didChooseAtUserWithData:x];
            }
        }];
    }];
    
}


#pragma mark - getter
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, 0, 60, 28);
        _cancelBtn.layer.masksToBounds = YES;
        _cancelBtn.layer.cornerRadius = 14;
        
        [_cancelBtn setTitle:Localized(@"Cancel") forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont ALFontSize15];
        
        [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        @weakify(self)
        [[_cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _cancelBtn;
}

- (ChooseAtManView *)mainView {
    if (!_mainView) {
        _mainView = [[ChooseAtManView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (ChooseAtManViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ChooseAtManViewModel alloc] init];
    }
    return _viewModel;
}

@end
