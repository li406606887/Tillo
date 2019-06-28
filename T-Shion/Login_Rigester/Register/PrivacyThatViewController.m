//
//  PrivacyThatViewController.m
//  T-Shion
//
//  Created by together on 2018/8/23.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "PrivacyThatViewController.h"
#import <WebKit/WebKit.h>

@interface PrivacyThatViewController ()
@property (strong, nonatomic) WKWebView *webView;
@end

@implementation PrivacyThatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.webView];
}

- (void)viewDidLayoutSubviews {
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)setType:(int)type {
    _type = type;
    NSString *path;
    switch (type) {
        case 1:{
            path = [[NSBundle mainBundle] pathForResource:@"PrivacyStatement" ofType:@"pdf"];
           self.title = @"隐私说明";
        }
            break;
        case 2:{
            self.title = @"服务条款";
            path = [[NSBundle mainBundle] pathForResource:@"ServiceDescription" ofType:@"pdf"];
          
        }
            break;
        default:
            break;
    }
    
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [self.webView loadRequest:request];
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
    }
    return _webView;
}

@end
