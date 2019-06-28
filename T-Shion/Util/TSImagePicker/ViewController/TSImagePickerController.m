//
//  TSImagePickerController.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSImagePickerController.h"
#import "TSImageGroupController.h"
#import "UINavigationBar+TS.h"

static NSString *const kPushToCollectionPageNotification = @"kPushToCollectionPageNotification";

@interface TSImagePickerController ()

@property (nonatomic, copy, readwrite) PHAssetsBlock phAssetsBlock;

@end

@implementation TSImagePickerController

- (instancetype)init {
    self = [super initWithRootViewController:[[TSImageGroupController alloc] init]];
    if (self) {

        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ALTextDarkColor],
                                                    NSFontAttributeName:[UIFont ALBoldFontSize18]}];

        self.allowSelectReturnType = YES;
        @weakify(self)
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"GetImageNotify" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self)
            NSArray *array = x.object;
            if (self.getSelectedBlock) {
                self.getSelectedBlock(array);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
        }];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)backButtonClick {
    NSLog(@"123");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAutoJumpToPhotoSelectPage:(BOOL)autoJumpToPhotoSelectPage {
    _autoJumpToPhotoSelectPage = autoJumpToPhotoSelectPage;
    if (autoJumpToPhotoSelectPage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushToCollectionPageNotification object:nil];
    }
}

- (void)getSelectedPHAssetsWithBlock:(PHAssetsBlock)block {
    
}

@end
