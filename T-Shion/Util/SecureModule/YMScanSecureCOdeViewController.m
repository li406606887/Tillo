//
//  YMScanSecureCOdeViewController.m
//  AilloTest
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "YMScanSecureCOdeViewController.h"
#import "SGQRCodeScanView.h"
#import "ZXingObjC.h"

@interface YMScanSecureCOdeViewController ()<ZXCaptureDelegate>

@property (atomic) ZXCapture *capture;
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation YMScanSecureCOdeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = Localized(@"scan_title");
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.tipLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
    [self startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
}

- (void)startCapture
{
    if (!self.capture) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.capture = [[ZXCapture alloc] init];
            self.capture.camera = self.capture.back;
            self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            self.capture.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.capture.layer.frame = self.view.bounds;
                [self.view.layer addSublayer:self.capture.layer];
                [self.view bringSubviewToFront:self.scanView];
                [self.view bringSubviewToFront:self.tipLabel];
                [self.capture start];
            });
        });
    } else {
        [self.capture start];
    }
}

- (void)stopCapture
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.capture stop];
    });
}

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result
{
    [self stopCapture];
    
    // Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    ZXByteArray *byteArray = result.resultMetadata[@(kResultMetadataTypeByteSegments)][0];
    NSData *decodedData = [NSData dataWithBytes:byteArray.array length:byteArray.length];
    if (self.scanComplete) {
        self.scanComplete(decodedData);
    }
    [self.navigationController popViewControllerAnimated:NO];
}

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

@end
