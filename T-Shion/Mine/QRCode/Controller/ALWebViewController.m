//
//  ALWebViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/24.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALWebViewController.h"
#import <WebKit/WebKit.h>

@interface ALWebViewController () <WKUIDelegate,WKNavigationDelegate>{
    WKUserContentController *userContentController;
}

@property (strong , nonatomic)WKWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation ALWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.progressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    self.progressView.hidden = NO;
    
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    
    [self.view bringSubviewToFront:self.progressView];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    self.title = webView.title;
    self.progressView.hidden = YES;
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    self.progressView.hidden = YES;
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    if (navigationAction.request.URL) {
        
        NSURL *url = navigationAction.request.URL;
        NSString *urlPath = url.absoluteString;
        if ([urlPath rangeOfString:@"https://"].location != NSNotFound || [urlPath rangeOfString:@"http://"].location != NSNotFound) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }
    return nil;
}


// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}

// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            NSString *title = self.webView.title;
            
            if ([self.title isEqualToString:@"加载中"]) {
                if ([title isEqualToString:@""]) {
                    title = self.self.webView.URL.absoluteString;
                    title = [title stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                    title = [title stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                }
            }
            
            if (![title isEqualToString:@""]) {
                
                self.title = title;
            }
            
        }
        
        // ... ...
    } else if([keyPath isEqualToString:@"estimatedProgress"]) {
        double progress = [change[NSKeyValueChangeNewKey] doubleValue];
        
        [self.progressView setProgress:progress animated:YES];
//        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (WKWebView *)webView
{
    if (!_webView) {
        
        //配置环境
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
        userContentController =[[WKUserContentController alloc]init];
        configuration.userContentController = userContentController;
        _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuration];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        //进度条初始化
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        _progressView.progressTintColor = [UIColor ALKeyColor];
        _progressView.trackTintColor = [UIColor whiteColor];
    }
    return _progressView;
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
