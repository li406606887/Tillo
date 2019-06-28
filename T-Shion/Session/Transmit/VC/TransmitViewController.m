//
//  TransmitRecentlyViewController.m
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "TransmitViewController.h"
#import "TransmitView.h"

@interface TransmitViewController ()

@property (nonatomic, assign) TransmitViewType type;

@property (nonatomic, weak) UIButton *navbarRightButton;

@property (nonatomic, weak) UIBarButtonItem *rightItem;

@property (nonatomic, strong) TransmitViewModel *viewModel;

@property (nonatomic, strong) TransmitView *mainView;
@end

@implementation TransmitViewController

- (instancetype)initWithType:(TransmitViewType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"Select_contacts")];
    if (self.type == TransmitViewTypeRecentlySession)
        [self setlefNavButton];
    [self setRightButtron];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)addChildView {
    [self.viewModel getDataArrayWithSelectedArray:self.selectedArray];
    [self.view addSubview:self.mainView];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.selectedChangeSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.rightItem.enabled = self.navbarRightButton.enabled = (self.viewModel.selectedArray.count > 0);
    }];
    
    
    [self.viewModel.clickFriendSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        TransmitViewController *vc = [[TransmitViewController alloc] initWithType:TransmitViewTypeFriend];
        vc.selectedArray = self.viewModel.selectedArray;
        vc.completeBlock = ^(NSArray *selectArray) {
            [self.viewModel addSelectedArrayFromArray:selectArray];
            [self.viewModel getDataArrayWithSelectedArray:self.viewModel.selectedArray];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [self.viewModel.clickGroupSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        TransmitViewController *vc = [[TransmitViewController alloc] initWithType:TransmitViewTypeGroup];
        vc.selectedArray = self.viewModel.selectedArray;
        vc.completeBlock = ^(NSArray *selectArray) {
            [self.viewModel addSelectedArrayFromArray:selectArray];
            [self.viewModel getDataArrayWithSelectedArray:self.viewModel.selectedArray];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)setlefNavButton {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:Localized(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick)];
    backBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        spaceRight.width = -100;
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        
        spaceLeft.width = -25;
        backBtn.imageInsets = UIEdgeInsetsMake(0, 22, 0, -22);
        spaceRight.width = 15;
        self.navigationItem.leftBarButtonItems = @[spaceLeft, backBtn, spaceRight];
    }
}

- (void)cancelClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setRightButtron {
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, 0, 70, 28);
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 14;
    
    [submitBtn setTitle:Localized(@"UserInfo_Done") forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont ALFontSize15];
    [submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
    
    [submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
    
    [submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
    
    submitBtn.enabled = NO;
    
    [submitBtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: submitBtn];
    submitItem.enabled = NO;
    self.rightItem = submitItem;
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
    
    self.navbarRightButton = submitBtn;
}

- (void)doneClick {
    NSArray *array = [self.viewModel.selectedArray copy];
    self.completeBlock(array);
    if (self.type == TransmitViewTypeRecentlySession) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (TransmitViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [[TransmitViewModel alloc] initWithType:self.type];
    }
    return _viewModel;
}

- (TransmitView *)mainView {
    if (!_mainView) {
        _mainView = [[TransmitView alloc] initWithViewModel:self.viewModel type:self.type];
    }
    return _mainView;
}
@end
