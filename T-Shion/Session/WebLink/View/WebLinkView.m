//
//  WebLinkView.m
//  AilloTest
//
//  Created by together on 2019/2/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "WebLinkView.h"
#import <WebKit/WebKit.h>

@interface WebLinkView()<WKNavigationDelegate,WKUIDelegate>
@property (strong, nonatomic) WKWebView *webView;
@end

@implementation WebLinkView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.webView];
    }
    return self;
}

- (void)layoutSubviews {
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)setUrl:(NSURL *)url {
    _url = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            if (self.changeTitleBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.changeTitleBlock(self.webView.title);
                });
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"title"];
}
@end
