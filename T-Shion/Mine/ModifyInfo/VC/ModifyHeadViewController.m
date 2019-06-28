//
//  ModifyHeadViewController.m
//  T-Shion
//
//  Created by together on 2018/6/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ModifyHeadViewController.h"

@interface ModifyHeadViewController ()
@property (strong, nonatomic) UIImageView *headIcon;
@end

@implementation ModifyHeadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.headIcon];
}

- (void)viewDidLayoutSubviews {
    [self.headIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).with.offset(-64);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH));
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
- (UIImageView *)headIcon {
    if (!_headIcon) {
        _headIcon = [[UIImageView alloc] init];
        _headIcon.image = [UIImage imageNamed:@"Avatar_Deafult"];
//        _headIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headIcon;
}
@end
