//
//  InviteFriendViewController.m
//  T-Shion
//
//  Created by together on 2018/12/19.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "InviteFriendView.h"
#import "InviteFriendViewModel.h"
#import <ContactsUI/ContactsUI.h>
#import "InviteFriendModel.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

typedef void (^WeChatShareCallBackBlock)(BOOL result);


@interface InviteFriendViewController ()<CNContactPickerDelegate,MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) InviteFriendView *mainView;
@property (strong, nonatomic) InviteFriendViewModel *viewModel;
@property (strong, nonatomic) UIButton *leftBtn;

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation InviteFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = Localized(@"Invite_friends");
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.sendMessageSubject subscribeNext:^(NSArray*  _Nullable x) {
        @strongify(self)
        [self showMessageView:x body:Localized(@"down_app_link")];
    }];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}


- (void)showMessageView:(NSArray *)phones body:(NSString *)body {
    @weakify(self)
    if([MFMessageComposeViewController canSendText]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
            // --设置代理
            controller.messageComposeDelegate = self;
            // --phones发短信的手机号码的数组，数组中是一个即单发,多个即群发。
            controller.recipients = phones;
            // --短信界面 BarButtonItem (取消按钮) 颜色
            controller.navigationBar.tintColor = [UIColor redColor];
            // --短信内容
            controller.body = body;
            [self presentViewController:controller animated:YES completion:nil];
        });
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:@"该设备不支持短信功能"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"取消发送");
            break;
            
        case MessageComposeResultSent:
            NSLog(@"已发送");
            break;
            
        case MessageComposeResultFailed:
            NSLog(@"发送失败");
            break;
            
        default:
            break;
    }
}

#pragma mark - getter
- (InviteFriendViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[InviteFriendViewModel alloc] init];
    }
    return _viewModel;
}

- (InviteFriendView *)mainView {
    if (!_mainView) {
        _mainView = [[InviteFriendView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}
@end
