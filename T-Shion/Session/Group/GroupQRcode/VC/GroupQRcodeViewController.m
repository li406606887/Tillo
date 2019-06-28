//
//  GroupQRcodeViewController.m
//  AilloTest
//
//  Created by together on 2019/4/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "GroupQRcodeViewController.h"
#import "GroupQRcodeViewModel.h"
#import "GroupQRcodeView.h"

@interface GroupQRcodeViewController ()
@property (strong, nonatomic) GroupQRcodeViewModel *viewModel;
@property (strong, nonatomic) GroupQRcodeView *mainView;
@property (strong, nonatomic) UIButton *saveBtn;
@property (weak, nonatomic) GroupModel *group;
@end

@implementation GroupQRcodeViewController
- (instancetype)initWithGroup:(GroupModel *)group {
    self = [super init];
    if (self) {
        self.group = group;
        self.viewModel.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:Localized(@"qr_code")];
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

- (UIBarButtonItem *)rightButton {
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    menu.frame = CGRectMake(0, 0, 70, 30);
    menu.layer.masksToBounds = YES;
    menu.layer.cornerRadius = 14;
    
    [menu setTitle:Localized(@"Save_picture") forState:UIControlStateNormal];
    menu.titleLabel.font = [UIFont ALFontSize15];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
    
    [menu setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
    [menu addTarget:self action:@selector(menuCellClick) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:menu];
}

- (void)menuCellClick {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(265,265), NO, 0.0);
    [self.mainView.qrcode.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    ShowWinMessage(Localized(@"UserInfo_QRCode_Success"));
}


#pragma mark - getter
- (GroupQRcodeView *)mainView {
    if (!_mainView) {
        _mainView = [[GroupQRcodeView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (GroupQRcodeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GroupQRcodeViewModel alloc] init];
    }
    return _viewModel;
}
@end
