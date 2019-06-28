//
//  YMSecureCodeViewController.m
//  T-Shion
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "YMSecureCodeViewController.h"
#import "YMSecureCode.h"
#import "YMRecipientIdentity.h"
#import "YMIdentityManager.h"
#import "YMScanSecureCOdeViewController.h"

@interface YMSecureCodeViewController ()

@property (nonatomic, copy) NSString *myUserID;
@property (nonatomic, copy) NSData *myIdentityKey;
@property (nonatomic, copy) NSString *theirUserID;
@property (nonatomic, copy) NSData *theirIdentityKey;
@property (nonatomic, copy) NSString *theirNickName;

@property (nonatomic, strong) YMSecureCode *secureCode;
@property (nonatomic, assign) CGSize qrCodeSize;

@property (nonatomic, weak) UIImageView *qrCodeView;

@end

@implementation YMSecureCodeViewController

- (instancetype)initWithMyID:(NSString*)myUserID myIdentity:(NSData*)myIdentity theirUserID:(NSString*)theirUserID theirIdentity:(NSData*)theirIdentityKey theirNickName:(NSString*)theirNickName {
    if (self = [super init]) {
        self.myUserID = myUserID;
        self.myIdentityKey = myIdentity;
        self.theirUserID = theirUserID;
        self.theirIdentityKey = theirIdentityKey;
        self.theirNickName = theirNickName;
        CGFloat width = SCREEN_WIDTH-30-80;
        self.qrCodeSize = CGSizeMake(width, width);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = Localized(@"crypt_verify_code");
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor ALKeyBgColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, self.view.width-30, SCREEN_HEIGHT-79-88)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:whiteView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, whiteView.width-80, whiteView.width-80)];
    imageView.image = self.secureCode.image;
    [whiteView addSubview:imageView];
    self.qrCodeView = imageView;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.secureCode.displayableText;
    label.numberOfLines = 3;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor ALTextGrayColor];
    [label sizeToFit];
    [whiteView addSubview:label];
    label.centerX = whiteView.width*0.5;
    label.y = imageView.bottom+39;
    [whiteView addSubview:label];
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:Localized(@"crypt_verity_tip") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor blackColor]}];
    CGRect stringBounds = [attr boundingRectWithSize:CGSizeMake(whiteView.width-34, 150) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, label.bottom+18, whiteView.width-34, ceil(stringBounds.size.height))];
    tipLabel.preferredMaxLayoutWidth = tipLabel.width;
    tipLabel.attributedText = attr;
    tipLabel.numberOfLines = 0;
    [whiteView addSubview:tipLabel];
    
    whiteView.height = tipLabel.bottom+38;
    scrollView.contentSize = CGSizeMake(scrollView.width, whiteView.bottom+36+52);
    CGFloat height = (SCREEN_HEIGHT > 810) ? 52+34 : 52;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-0.5, self.view.height-height+0.5, self.view.width+1, height)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = RGB(223, 224, 228).CGColor;
    view.layer.borderWidth = 0.5;
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:view];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, whiteView.width, height);
    [button setTitle:Localized(@"crypt_scan_qrcode") forState:UIControlStateNormal];
    [button setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(scanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)scanButtonClicked {
    //调起扫码
    YMScanSecureCOdeViewController *controller = [[YMScanSecureCOdeViewController alloc] init];
    @weakify(self)
    controller.scanComplete = ^(NSData * _Nonnull result) {
        @strongify(self)
        BOOL b = [self.secureCode matchesLogicalFingerprintsData:result];
        if (b) {
            [self showVerifySuccess];
            return;
        }
        [self showVerifyFailed];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showVerifySuccess {
    self.qrCodeView.image = [UIImage imageNamed:@"crypt_verity_success"];
    CGRect rect = self.qrCodeView.frame;
    self.qrCodeView.frame = CGRectMake(rect.origin.x+(rect.size.width-150)/2, rect.origin.y+(rect.size.height-150)/2, 150, 150);
}

- (void)showVerifyFailed {
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    tipView.backgroundColor = RGB(248, 224, 222);
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 15, 15)];
    icon.image = [UIImage imageNamed:@"crypt_verify_fail"];
    [tipView addSubview:icon];
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:Localized(@"crypt_verify_code_fail") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor ALTextGrayColor]}];
    CGRect stringBounds = [attr boundingRectWithSize:CGSizeMake(self.view.width-47.5, 150) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 8.5, self.view.width-47.5, ceil(stringBounds.size.height))];
    tipLabel.attributedText = attr;
    [tipView addSubview:tipLabel];
    
    tipView.height = tipLabel.height + 17;
    [self.view addSubview:tipView];
}

//获取安全码
- (YMSecureCode*)secureCode {
    if (!_secureCode) {
        _secureCode = [YMSecureCode fingerprintWithMyStableId:self.myUserID myIdentityKey:self.myIdentityKey theirStableId:self.theirUserID theirIdentityKey:self.theirIdentityKey theirName:self.theirNickName];
        _secureCode.qrCodeSize = self.qrCodeSize;
    }
    return _secureCode;
}

@end
