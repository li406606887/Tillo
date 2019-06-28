//
//  ModifyInfoViewController.m
//  T-Shion
//
//  Created by together on 2018/6/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ModifyInfoViewController.h"
#import "ModifyInfoViewModel.h"

struct ALTitleInfo {
    NSInteger length;
    NSInteger number;
};
typedef struct ALTitleInfo ALTitleInfo;

@interface ModifyInfoViewController ()
@property (strong, nonatomic) UITextField *filed;
@property (strong, nonatomic) ModifyInfoViewModel *viewModel;

@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation ModifyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRightNavigation];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [IQKeyboardManager sharedManager].enable = YES;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setParam:(NSString *)param {
    self.viewModel.friendId = param;
    _param = param;
}

- (void)addChildView {
    [self.view addSubview:self.filed];
    [self.filed becomeFirstResponder];
}

- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.submitBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}

- (void)viewDidLayoutSubviews {
    [self.filed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(15);
        make.centerX.equalTo(self.view);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 50));
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)setFieldValue:(NSString *)fieldValue {
    _fieldValue = fieldValue;
    self.filed.text = fieldValue;
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.modifySuccessSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.type == 1) {
            self.successBlock(self.filed.text);
        }else {
            if ([self.param isEqualToString:@"name"]) {
                [SocketViewModel shared].userModel.name = self.filed.text;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ModifyName" object:nil];
                
            }else if ([self.param isEqualToString:@"introduce"]){
                [SocketViewModel shared].userModel.introduce = self.filed.text;
            } else if ([self.param isEqualToString:@"region"]){
                [SocketViewModel shared].userModel.region = self.filed.text;
            }
            [FMDBManager updateUserInfo:[SocketViewModel shared].userModel];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


//判断中英混合的的字符串长度及字符个数
- (ALTitleInfo)getInfoWithText:(NSString *)text maxLength:(NSInteger)maxLength
{
    ALTitleInfo title;
    int length = 0;
    int singleNum = 0;
    int totalNum = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            length++;
            if (length <= maxLength) {
                totalNum++;
            }
        }
        else {
            if (length <= maxLength) {
                singleNum++;
            }
        }
        p++;
    }
    
    title.length = length;
    title.number = (totalNum - singleNum) / 2 + singleNum;
    
    return title;
}


#pragma mark - getter
- (UITextField *)filed {
    if (!_filed) {
        _filed = [[UITextField alloc] init];
        _filed.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 34)];
        _filed.backgroundColor = [UIColor whiteColor];
        _filed.leftViewMode = UITextFieldViewModeAlways;
        _filed.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        @weakify(self)
        [[_filed rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self)
            self.submitBtn.enabled = YES;
            if (self.filed.text.length == 0) {
                if(self.type != 1) {
                    self.submitBtn.enabled = NO;
                }else if ([x isEqualToString:self.fieldValue]) {
                    self.submitBtn.enabled = NO;
                }
            } else if ([x isEqualToString:self.fieldValue]) {
                self.submitBtn.enabled = NO;
            }
            
            NSInteger maxLength = 30;
            
            ALTitleInfo title = [self getInfoWithText:x maxLength:maxLength];
            
            if (title.length > maxLength) {
                self.filed.text = [x substringToIndex:title.number];
            }
        }];
    }
    return _filed;
}

- (ModifyInfoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ModifyInfoViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.frame = CGRectMake(0, 0, 60, 28);
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.layer.cornerRadius = 14;
        
        [_submitBtn setTitle:Localized(@"UserInfo_Done") forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont ALFontSize15];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_submitBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        _submitBtn.enabled = NO;
        
        @weakify(self)
        [[_submitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.filed resignFirstResponder];
            if (self.type == 1) {
                [self.viewModel.modifyFriendInfoCommand execute:@{@"friendId":self.viewModel.friendId,@"friendRemark":self.filed.text}];
            } else {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:self.filed.text forKey:self.param];
                [self.viewModel.modifyInfoCommand execute:dic];
            }
        }];
    }
    return _submitBtn;
}

@end
