//
//  WebLinkViewController.m
//  AilloTest
//
//  Created by together on 2019/2/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "WebLinkViewController.h"
#import "WebLinkView.h"

@interface WebLinkViewController ()
@property (strong, nonatomic) WebLinkView *mainView;
@end

@implementation WebLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)setUrl:(NSURL *)url {
    _url = url;
    self.mainView.url = url;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (WebLinkView *)mainView {
    if (!_mainView) {
        _mainView = [[WebLinkView alloc] init];
        @weakify(self)
        _mainView.changeTitleBlock = ^(NSString * _Nonnull title) {
          @strongify(self)
            self.title = title;
        };
    }
    return _mainView;
}
@end
