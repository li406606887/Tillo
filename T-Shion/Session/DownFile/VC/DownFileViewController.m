//
//  DownFileViewController.m
//  T-Shion
//
//  Created by together on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "DownFileViewController.h"
#import "DownFileView.h"
#import "DownFileViewModel.h"

@interface DownFileViewController ()<UIDocumentInteractionControllerDelegate>
@property (strong, nonatomic) DownFileView *mainView;
@property (strong, nonatomic) DownFileViewModel *viewModel;
@property (strong, nonatomic) UIDocumentInteractionController *documentVC;
@end

@implementation DownFileViewController
- (instancetype)initWithMessage:(MessageModel *)message {
    self = [super init];
    if (self) {
        self.viewModel.message = message;
        [self addChildView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = Localized(@"Down_link");
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
    @weakify(self)
    [[self.viewModel.opernFileSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
     @strongify(self)
        [self showDocumentVC];
    }];
}

#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {
    return self.view.frame;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - getter
- (DownFileView *)mainView {
    if (!_mainView) {
        _mainView = [[DownFileView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (DownFileViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[DownFileViewModel alloc] init];
    }
    return _viewModel;
}

- (void)showDocumentVC {
    NSString *path = [[FMDBManager getMessagePathWithMessage:self.viewModel.message] stringByAppendingPathComponent:self.viewModel.message.content];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[FMDBManager getMessagePathWithMessage:self.viewModel.message] stringByAppendingPathComponent:self.viewModel.message.fileName];
    }
    self.documentVC = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    [self.documentVC setName:self.viewModel.message.fileName];
    self.documentVC.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL b = [self.documentVC presentPreviewAnimated:YES];
        if (!b) {
            [self.documentVC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        }
    });
    
}
@end
