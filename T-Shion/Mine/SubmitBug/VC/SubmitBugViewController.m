//
//  SubmitBugViewController.m
//  T-Shion
//
//  Created by together on 2018/8/24.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SubmitBugViewController.h"

@interface SubmitBugViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (strong, nonatomic) UIButton *submit;
@end

@implementation SubmitBugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"Feedback")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.textView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.submit];
}

- (void)viewDidLayoutSubviews {
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(20);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.height.mas_equalTo(200);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textView.mas_left);
        make.top.equalTo(self.textView.mas_bottom).with.offset(15);
    }];
    
    [self.submit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLabel.mas_bottom).with.offset(40);
        make.left.equalTo(self.view.mas_left).with.offset(30);
        make.right.equalTo(self.view.mas_right).with.offset(-30);
        make.height.mas_equalTo(50);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)submitBug {
    __block NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:self.textView.text forKey:@"content"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        RequestModel *model = [TSRequest postRequetWithApi:api_post_feedback withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil&&[model.status intValue]==200) {
                ShowWinMessage(Localized(@"Feedback_Success"));
                self.textView.text = nil;
            }
        });
    });
}

#pragma mark - getter
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont ALFontSize15];
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 5;
        _textView.layer.borderColor = [UIColor ALLineColor].CGColor;
        _textView.layer.borderWidth = 1;
        
        @weakify(self)
        [[_textView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            self.submit.enabled = self.textView.text.length > 0;
        }];
    }
    return _textView;
}

- (UIButton *)submit {
    if (!_submit) {
        _submit = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submit setTitle:Localized(@"Submit") forState:UIControlStateNormal];
        _submit.layer.cornerRadius = 25;
        _submit.layer.masksToBounds = YES;
        _submit.enabled = NO;
        
        [_submit.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_submit setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_submit setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        [_submit setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        @weakify(self)
        [[_submit rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.textView.text.length>0) {
                [self submitBug];
            } else {
                ShowWinMessage(Localized(@"Please_enter_what_you_want_to_feedback"));
            }
        }];
    }
    return _submit;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel constructLabel:CGRectZero
                                       text:Localized(@"Feedback_Tip")
                                       font:[UIFont ALFontSize13]
                                  textColor:[UIColor ALKeyColor]];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _tipLabel;
}

@end
