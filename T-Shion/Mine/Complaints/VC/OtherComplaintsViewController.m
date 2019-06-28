//
//  OtherComplaintsViewController.m
//  T-Shion
//
//  Created by together on 2019/4/26.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "OtherComplaintsViewController.h"

@interface OtherComplaintsViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *submitBtn;
@end

@implementation OtherComplaintsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addChildView {
    [self.view addSubview:self.textView];
    [self.view addSubview:self.submitBtn];
}

- (void)viewDidLayoutSubviews {
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-40, 200));
    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).with.offset(40);
        make.centerX.equalTo(self.view);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH-60, 45));
    }];
    [super viewDidLayoutSubviews];
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.textView.text = content;
}

- (void)complaintsContentWithString:(NSString*)string {
    __block NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:string forKey:@"complaint"];
    [param setObject:@(self.type) forKey:@"type"];
    [param setObject:self.targerId forKey:@"friendId"];
    LoadingView(@"");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        RequestModel *model = [TSRequest postRequetWithApi:api_post_complaintFriend withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            HiddenHUD;
            if (error==nil&&[model.status intValue]==200) {
                ShowWinMessage(Localized(@"Complaint_successful"));
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitBtn setTitle:Localized(@"Report") forState:UIControlStateNormal];
        _submitBtn.layer.cornerRadius = 25;
        @weakify(self)
        [[_submitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.textView.text.length>0) {
                [self complaintsContentWithString:self.textView.text];
            }else {
                ShowWinMessage(Localized(@"Please_select_what_you_want_to_report"));
            }
            
        }];
        _submitBtn.layer.masksToBounds = YES;
        [_submitBtn.titleLabel setFont:[UIFont ALFontSize17]];
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
    }
    return _submitBtn;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 5;
        _textView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
        _textView.font = [UIFont systemFontOfSize:15];
    }
    return _textView;
}


@end
