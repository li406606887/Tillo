//
//  ScanViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/23.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ScanViewController.h"
#import "SGQRCode.h"
#import "ScanQRViewModel.h"
#import "OtherInformationViewController.h"
#import "StrangerViewController.h"
#import "AddFriendsModel.h"
#import "ALWebViewController.h"
#import "ScanResultOfGroupViewController.h"
#import "GroupMessageRoomController.h"

static NSString *kScanGroupResultKey = @"AilloGroup&";
static NSString *kScanGroupJoinKey = @"join?";


@interface ScanViewController () {
    SGQRCodeObtain *obtain;
}

@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) ScanQRViewModel *viewModel;

@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) NSMutableDictionary *joinGroupParams;


@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"scan_title");
    self.view.backgroundColor = [UIColor blackColor];
    [self setRightNavigation];
    obtain = [SGQRCodeObtain QRCodeObtain];
    [self setupQRCodeScan];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.tipLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /// 二维码开启方法
    [obtain startRunningWithBefore:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
//    [self removeFlashlightBtn];
    [obtain stopRunning];
}

- (void)dealloc {
    NSLog(@"WCQRCodeVC - dealloc");
    [self removeScanningView];
}

- (void)bindViewModel {
    @weakify(self);
    [[self.viewModel.searchFriendsSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(AddFriendsModel *model) {
        @strongify(self)//不明白为什么要用强引用self 并没用到self对象指针
        if (!model) {
            ShowWinMessage(Localized(@"scan_error"));
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)//不明白为什么要用强引用self 并没用到self对象指针
                [obtain startRunningWithBefore:nil completion:nil];
            });
            return;
        }
        if (model.roomId.length >0) {
            OtherInformationViewController *otherVC = [[OtherInformationViewController alloc] init];
            FriendsModel *friendsModel = [FMDBManager selectFriendTableWithRoomId:model.roomId];
            
            otherVC.model = friendsModel;
            [self.navigationController pushViewController:otherVC animated:YES];
   
        } else {
            StrangerViewController *strangerVC = [[StrangerViewController alloc] init];
            strangerVC.model = model;
            strangerVC.isNavPop = YES;
            [self.navigationController pushViewController:strangerVC animated:YES];
        }
    }];
    
    [[self.viewModel.searchGroupEndSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RequestModel *model) {
        @strongify(self);
        
        ScanResultOfGroupType type;
        
        switch ([model.status integerValue]) {
            case 200:
                type = ScanResultOfGroupTypeDefault;
                break;
                
            case -10006:
                type = ScanResultOfGroupTypeVerify;
                break;
                
            case -10007:
                type = ScanResultOfGroupTypePastDue;
                break;
                
            case -10008:
                type = ScanResultOfGroupTypeLeave;
                break;
                
            default: {
                ShowWinMessage(Localized(@"scan_error"));
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self->obtain startRunningWithBefore:nil completion:nil];
                });
                return;
            }
                break;
        }
        
        //如果已经存在该群就跳转到会话
        NSString *roomId = model.data[@"roomId"];
        GroupModel *groupModel = [FMDBManager selectGroupModelWithRoomId:roomId];
        if (groupModel && ![groupModel.deflag isEqualToString:@"1"]) {
            GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:groupModel count:20 type:Loading_NO_NEW_MESSAGES];
            [self.navigationController pushViewController:group animated:YES];
            return;
        }
        
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] initWithDictionary:model.data];
        
        [dataDict setObject:self.joinGroupParams[@"random"] forKey:@"random"];
        [dataDict setObject:self.joinGroupParams[@"createUserId"] forKey:@"createUserId"];
        
        ScanResultOfGroupViewController *resultVC = [[ScanResultOfGroupViewController alloc] initWithType:type resultData:dataDict];
        [self.navigationController pushViewController:resultVC animated:YES];
    }];
}

- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.photoBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}


- (void)setupQRCodeScan {

    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.sampleBufferDelegate = YES;
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    
    @weakify(self);
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        @strongify(self);
        if (!result) {
            ShowWinMessage(Localized(@"scan_error"));
            return;
        }
        
        if ([self isUrlAddress:result]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
            return;
        }
        
        [obtain stopRunning];
        [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
        [self operateScanResult:result];
//        [self.viewModel.searchFriendsCommand execute:@{@"userId":[SocketViewModel shared].userModel.ID,@"friendId":result}];
    }];
    
//    [obtain setBlockWithQRCodeObtainScanBrightness:^(SGQRCodeObtain *obtain, CGFloat brightness) {
////        if (brightness < - 1) {
////            [weakSelf.view addSubview:weakSelf.flashlightBtn];
////        } else {
////            if (weakSelf.isSelectedFlashlightBtn == NO) {
////                [weakSelf removeFlashlightBtn];
////            }
////        }
//    }];
}

- (void)rightBarButtonItenAction {
    
    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    
    @weakify(self);
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        @strongify(self);
        [self.view addSubview:self.scanView];
    }];
    
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        @strongify(self);
        if (!result) {
            ShowWinMessage(Localized(@"scan_error"));
            return;
        }
        
        if ([self isUrlAddress:result]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
            return;
        }
        
        [obtain stopRunning];
        [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
        
        [self operateScanResult:result];
//        [self.viewModel.searchFriendsCommand execute:@{@"userId":[SocketViewModel shared].userModel.ID,@"friendId":result}];
    }];
}

- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

//判断是否是网址
- (BOOL)isUrlAddress:(NSString*)url {
    NSString *reg = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    return[urlPredicate evaluateWithObject:url];
}


#pragma mark - 扫描结果相关
- (void)operateScanResult:(NSString *)resultUrlStr {
    if ([resultUrlStr hasPrefix:kScanGroupResultKey]) {
        [self operateGroupScanResult:resultUrlStr];
    } else {
        [self.viewModel.searchFriendsCommand execute:@{@"userId":[SocketViewModel shared].userModel.ID,@"friendId":resultUrlStr}];
    }
}

- (void)operateGroupScanResult:(NSString *)resultUrlStr {
    NSString *tempurlStr = [resultUrlStr substringFromIndex:kScanGroupResultKey.length];
    
    NSRange joinRange = [tempurlStr rangeOfString:kScanGroupJoinKey];//匹配得到的下标
    
    tempurlStr = [tempurlStr substringFromIndex:joinRange.location + joinRange.length];
    
    NSArray *array = [tempurlStr componentsSeparatedByString:@"&"];
    
    __block NSMutableDictionary *joinGroupParams = [NSMutableDictionary dictionary];
    
    [array enumerateObjectsUsingBlock:^(NSString *dataStr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange segmentRang = [dataStr rangeOfString:@"="];
        if (segmentRang.location != NSNotFound) {
            NSString *key = [dataStr substringToIndex:segmentRang.location];
            NSString *valueStr = [dataStr substringFromIndex:segmentRang.location + 1];
            
            [joinGroupParams setObject:valueStr forKey:key];
        }
    }];
    
    [joinGroupParams setObject:@(NO) forKey:@"isJoin"];
    self.joinGroupParams = joinGroupParams;
    NSLog(@"%@",joinGroupParams);
    
    [self.viewModel.searchGroupCommand execute:joinGroupParams];
}


#pragma mark - getter
- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        _scanView.cornerColor = [UIColor ALKeyColor];
    }
    return _scanView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        
        CGFloat scanHeight = SCREEN_HEIGHT - 64;
        CGFloat scanBorderW = SCREEN_WIDTH * 0.7;
        
        CGFloat scanBorderY = 0.5 * (scanHeight - scanBorderW);
        _tipLabel = [UILabel constructLabel:CGRectMake(0, scanBorderY - 35, SCREEN_WIDTH, 20)
                                       text:Localized(@"scan_tip")
                                       font:[UIFont ALFontSize11]
                                  textColor:[UIColor whiteColor]];
    }
    return _tipLabel;
}

- (ScanQRViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ScanQRViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoBtn.frame = CGRectMake(0, 0, 60, 28);
        _photoBtn.layer.masksToBounds = YES;
        _photoBtn.layer.cornerRadius = 14;
        
        [_photoBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnNormalColor]] forState:UIControlStateNormal];
        
        [_photoBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnHightLightColor]] forState:UIControlStateHighlighted];
        
        [_photoBtn setBackgroundImage:[UIImage imageWithColor:[UIColor ALBtnDisableColor]] forState:UIControlStateDisabled];
        
        [_photoBtn setTitle:Localized(@"scan_photo") forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _photoBtn.titleLabel.font = [UIFont ALFontSize15];
        
        @weakify(self)
        [[_photoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self rightBarButtonItenAction];
            
        }];
    }
    return _photoBtn;
}

@end
