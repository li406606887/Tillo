//
//  TakingPicturesViewController.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TakingPicturesViewController.h"
#import "TSImagePickerController.h"
#import "TSCameraViewController.h"

@interface TakingPicturesViewController ()

@property (strong, nonatomic) TSCameraViewController *camera;
@property (strong, nonatomic) UIButton *dissMissBtn;
//@property (strong, nonatomic) UIButton *flashButton;//闪光
@property (strong, nonatomic) UIButton *switchButton;//前后置转化
@property (strong, nonatomic) UIButton *snapButton;//拍照
@property (strong, nonatomic) UIImageView *captureImageView;//拍照拿到显示

@property (strong, nonatomic) UIButton *captureBackBtn;
@property (strong, nonatomic) UIButton *captureSendBtn;

@end

@implementation TakingPicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.camera start];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addChildView {
    
    [self.camera attachToViewController:self frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self cameraOperation];
    
    [self.view addSubview:self.captureImageView];
    [self.view addSubview:self.dissMissBtn];
//    [self.view addSubview:self.flashButton];
    [self.view addSubview:self.captureBackBtn];
    [self.view addSubview:self.captureSendBtn];
    [self.view addSubview:self.snapButton];
    [self.view addSubview:self.switchButton];
}

- (void)viewDidLayoutSubviews {
    [self.captureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.mas_offset(SCREEN_WIDTH);
        make.centerX.equalTo(self.view);
    }];
    
    [self.dissMissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_left).offset(((SCREEN_WIDTH - 80)/4));
        make.centerY.equalTo(self.snapButton);
    }];
    
    [self.captureSendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_right).offset(-((SCREEN_WIDTH - 80)/4));
        make.centerY.equalTo(self.snapButton);
    }];
    
    [self.captureBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_left).offset(((SCREEN_WIDTH - 80)/4));
        make.centerY.equalTo(self.snapButton);
    }];
    
    [self.snapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(80, 80));
        make.centerX.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-35);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view.mas_bottom).offset(-35);
        }
    }];
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_right).offset(-((SCREEN_WIDTH - 80)/4));
        make.centerY.equalTo(self.snapButton);
    }];
    

    [super viewDidLayoutSubviews];
}

#pragma mark - camera
- (void)cameraOperation {
    //前后置转换闪光灯按钮操作
    [_camera setOnDeviceChange:^(TSCameraViewController *camera, AVCaptureDevice *device) {
//        if([camera isFlashAvailable]) {
//            weakSelf.flashButton.hidden = NO;
//            weakSelf.flashButton.selected = camera.flash == TSCameraFlashOff ? NO : YES;
//        } else {
//            weakSelf.flashButton.hidden = YES;
//        }
    }];
    
    [_camera setOnError:^(TSCameraViewController *camera, NSError *error) {
        
    }];
}

- (void)takingPictures {
    @weakify(self)
    [self.camera capture:^(TSCameraViewController *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        @strongify(self)
        if(!error) {
            self.captureImageView.image = image;
            self.captureImageView.hidden = NO;
            [self setupBtnAfterCapture];
        } else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

#pragma mark captureSend
- (void)setupBtnAfterCapture {
//    self.dissMissBtn.hidden = YES;
//    self.flashButton.hidden = YES;
    self.switchButton.hidden = YES;
    self.snapButton.hidden = YES;
    self.dissMissBtn.hidden = YES;

    self.captureSendBtn.hidden = NO;
    self.captureBackBtn.hidden = NO;
    
    //    @weakify(self)
//    [UIView animateWithDuration:1 animations:^{
//        @strongify(self)
//        self.captureSendBtn.alpha = 1;
//        self.captureBackBtn.alpha = 1;
//
//        [self.captureSendBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.view).offset(90);
//        }];
//
//        [self.captureBackBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.view).offset(-90);
//        }];
//
//        [self.captureSendBtn layoutIfNeeded];
//        [self.captureBackBtn layoutIfNeeded];
//
//    } completion:^(BOOL finished) {
//
//    }];
}

- (void)setupBtnAfterCancleCapture {
//    self.dissMissBtn.hidden = NO;
//    self.flashButton.hidden = NO;
    self.switchButton.hidden = NO;
    self.snapButton.hidden = NO;
    self.dissMissBtn.hidden = NO;
    
    self.captureSendBtn.hidden = YES;
    self.captureBackBtn.hidden = YES;
//    self.captureBackBtn.alpha = 0;
//    self.captureSendBtn.alpha = 0;
    
    self.captureImageView.hidden = YES;
    self.captureImageView.image = nil;
}

#pragma mark - getter and setter
- (TSCameraViewController *)camera {
    if (!_camera) {
        _camera = [[TSCameraViewController alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                         position:TSCameraPositionRear
                                                     videoEnabled:YES];
        _camera.fixOrientationAfterCapture = NO;
    }
    return _camera;
}

- (UIImageView *)captureImageView {
    if (!_captureImageView) {
        _captureImageView = [[UIImageView alloc] init];
        _captureImageView.hidden = YES;
    }
    return _captureImageView;
}

- (UIButton *)dissMissBtn {
    if (!_dissMissBtn) {
        _dissMissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dissMissBtn setImage:[UIImage imageNamed:@"close_camera"] forState:UIControlStateNormal];
        @weakify(self)
        [[_dissMissBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _dissMissBtn;
}

//- (UIButton *)flashButton {
//    if (!_flashButton) {
//        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_flashButton setBackgroundColor:[UIColor yellowColor]];
//        @weakify(self)
//        [[_flashButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            @strongify(self)
//            if(self.camera.flash == TSCameraFlashOff) {
//                BOOL done = [self.camera updateFlashMode:TSCameraFlashOn];
//                if(done) {
//                    self.flashButton.selected = YES;
//                    self.flashButton.tintColor = [UIColor yellowColor];
//                }
//            }
//            else {
//                BOOL done = [self.camera updateFlashMode:TSCameraFlashOff];
//                if(done) {
//                    self.flashButton.selected = NO;
//                    self.flashButton.tintColor = [UIColor whiteColor];
//                }
//            }
//        }];
//    }
//    return _flashButton;
//}

- (UIButton *)snapButton {
    if (!_snapButton) {
        _snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_snapButton setBackgroundImage:[UIImage imageNamed:@"take_photo"] forState:UIControlStateNormal];
        _snapButton.layer.masksToBounds = YES;
        _snapButton.layer.cornerRadius = 40;
        @weakify(self)
        [[_snapButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self takingPictures];
        }];
    }
    return _snapButton;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:[UIImage imageNamed:@"camera_conversion"] forState:UIControlStateNormal];
        @weakify(self)
        [[_switchButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.camera togglePosition];
        }];
    }
    return _switchButton;;
}

- (UIButton *)captureBackBtn {
    if (!_captureBackBtn) {
        _captureBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _captureBackBtn.hidden = YES;
        [_captureBackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_captureBackBtn setImage:[UIImage imageNamed:@"take_photo_cancel"] forState:UIControlStateNormal];
        @weakify(self)
        [[_captureBackBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self setupBtnAfterCancleCapture];
        }];
    }
    
    return _captureBackBtn;
}

- (UIButton *)captureSendBtn {
    if (!_captureSendBtn) {
        _captureSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _captureSendBtn.hidden = YES;
        [_captureSendBtn setImage:[UIImage imageNamed:@"take_photo_sure_selected"] forState:UIControlStateNormal];
        @weakify(self)
        [[_captureSendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.takingPicturesBlock) {
                self.takingPicturesBlock(self.captureImageView.image);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    return _captureSendBtn;
}

@end
