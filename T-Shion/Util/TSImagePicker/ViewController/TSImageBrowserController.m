//
//  TSImageBrowserController.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSImageBrowserController.h"
#import "TSBrowserCollectionCell.h"
#import "TSImageBrowserNavBar.h"
#import "TSImageBrowserToolBar.h"
#import "TSImageSelectedHandler.h"
#import "ALAssetSource.h"

@interface TSImageBrowserController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic , strong) TSImageBrowserNavBar *customNavBar;
@property (nonatomic , strong) TSImageBrowserToolBar *bottomToolBar;
@property (nonatomic , strong) UIButton *backBtn;
@property (nonatomic , assign) CGFloat bottomBarY;
@end

@implementation TSImageBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"View");
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
//    [self.view addSubview:self.customNavBar];
    [self.view addSubview:self.bottomToolBar];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * self.collectionView.width, 0) animated:NO];
    
    [self resetNavbarSelectedBtn];
    [self setLeftNavigation];
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLeftNavigation {
    NSString *imageName = @"NavigationBar_Back";
    
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(backButtonClick)];
    backBtn.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        spaceRight.width = -100;
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        spaceLeft.width = -25;
        backBtn.imageInsets = UIEdgeInsetsMake(0, 22, 0, -22);
        spaceRight.width = 15;
        self.navigationItem.leftBarButtonItems = @[spaceLeft, backBtn, spaceRight];
    }
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetNavbarSelectedBtn {
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    
    if ([[TSImageSelectedHandler shareInstance] containsIndex:currentIndexPath]) {
        NSInteger navIndex = [[[TSImageSelectedHandler shareInstance] selectedIndexs] indexOfObject:currentIndexPath];
        [self.customNavBar resetSelectBtn:navIndex isSelected:YES];
    } else {
        [self.customNavBar resetSelectBtn:0 isSelected:NO];
    }
}

- (void)viewDidLayoutSubviews {
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 50 + self.view.safeAreaInsets.bottom));
        } else {
            // Fallback on earlier versions
            make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 50 ));
        }
    }];
    
    self.bottomBarY = self.bottomToolBar.y;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.phAssetsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSBrowserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([TSBrowserCollectionCell class])] forIndexPath:indexPath];
    cell.phAsset = self.phAssetsArray[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    
    [cell handleSingleTapActionWithBlock:^{
        if (weakSelf.customNavBar.isShow) {
            [UIView animateWithDuration:0.2 animations:^{
//                weakSelf.customNavBar.origin = CGPointMake(0, -64);
                [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
                [UIApplication sharedApplication].statusBarHidden = YES;
                weakSelf.bottomToolBar.origin = CGPointMake(0, SCREEN_HEIGHT + 1);
            }];
            weakSelf.customNavBar.isShow = NO;
        } else {
            [UIView animateWithDuration:0.2 animations:^{
//                weakSelf.customNavBar.origin = CGPointMake(0, 0);
                [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                [UIApplication sharedApplication].statusBarHidden = NO;
                weakSelf.bottomToolBar.origin = CGPointMake(0, self.bottomBarY);
            }];
            weakSelf.customNavBar.isShow = YES;
        }
    }];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = round(scrollView.contentOffset.x / scrollView.width);
    [self resetNavbarSelectedBtn];
    
//    [self setOriginSize];
}

- (void)setOriginSize {

}

- (void)accessToImageAccordingToTheAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void(^)(ALAssetSource *image,NSDictionary *info))completion {
    static PHImageRequestID requestID = -1;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, 500);
    if (requestID >= 1 && size.width / width == scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.resizeMode = resizeMode;
    option.synchronous = YES;
    
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        /** 必须做判断，要不然将走多次完成的completion的block */
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            ALAssetSource *imageModel = [ALAssetSource new];
            imageModel.originalImage = result;
            completion(imageModel,info);
        }
    }];
}

- (void)accessToGifAccordingToTheAsset:(PHAsset *)asset completion:(void(^)(ALAssetSource *gifData, NSDictionary *info))completion {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && imageData) {
                ALAssetSource *gifModel = [ALAssetSource new];
                gifModel.sourceType = ALAssetSourceType_GIF;
                gifModel.sourceData = imageData;
                gifModel.originalImage = [UIImage imageWithData:imageData];
                completion(gifModel,info);
            }
        }
    }];
}

- (BOOL)isGif:(PHAsset *)asset {
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    return [orgFilename containsString:@"GIF"] || [orgFilename containsString:@"gif"];
}

#pragma mark - getter and setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[TSBrowserCollectionCell class] forCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([TSBrowserCollectionCell class])]];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if (!_collectionViewFlowLayout) {
        CGFloat const kLineSpacing = 0;
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewFlowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, kLineSpacing);
        _collectionViewFlowLayout.minimumLineSpacing = kLineSpacing;
        _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionViewFlowLayout;
}

- (TSImageBrowserNavBar *)customNavBar {
    if (!_customNavBar) {
        @weakify(self)
        _customNavBar = [[TSImageBrowserNavBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        [_customNavBar handleBackActionWithBlock:^{
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [_customNavBar handleSelectedActionWithBlock:^(UIButton *sender, BOOL isSelected) {
            @strongify(self)
             NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            if (isSelected)
            {
                [[TSImageSelectedHandler shareInstance] addAsset:self.phAssetsArray[self.currentIndex]];
                [[TSImageSelectedHandler shareInstance] addIndex:currentIndexPath];
                
            }
            else
            {
                [[TSImageSelectedHandler shareInstance] removeAsset:self.phAssetsArray[self.currentIndex]];
                [[TSImageSelectedHandler shareInstance] removeIndex:currentIndexPath];
            }
            
            [self.bottomToolBar resetSelectPhotosNumber:[[TSImageSelectedHandler shareInstance] selectedIndexs].count];
            [self resetNavbarSelectedBtn];
        }];
    }
    return _customNavBar;
}

- (TSImageBrowserToolBar *)bottomToolBar {
    if (!_bottomToolBar) {
        _bottomToolBar = [[TSImageBrowserToolBar alloc] initWithFrame:CGRectZero barStyle:UIBarStyleBlack];
        [_bottomToolBar layoutIfNeeded];
        [_bottomToolBar resetSelectPhotosNumber:[[TSImageSelectedHandler shareInstance] selectedIndexs].count];
        @weakify(self)
        [_bottomToolBar handleFinishedButtonWithBlock:^{
            LoadingWin(@"")
            dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
            
            dispatch_async(serialQueue, ^{
                __block NSMutableArray *array = [NSMutableArray array];
                @strongify(self)
                [self.phAssetsArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull phAsset, NSUInteger idx, BOOL * _Nonnull stop) {
                    @strongify(self)
                    dispatch_semaphore_t sendSemaphore = dispatch_semaphore_create(0);
                    if ([ALAssetSource isVideo:phAsset]) {
                        [ALAssetSource videoInfoWithAsset:phAsset completion:^(ALAssetSource *videoData) {
                            NSLog(@"----dwada----");
                            [array addObject:videoData];
                            dispatch_semaphore_signal(sendSemaphore);
                        }];
                        
                    } else if ([ALAssetSource isGif:phAsset]) {
                        [self accessToGifAccordingToTheAsset:phAsset completion:^(ALAssetSource *gifData, NSDictionary *info) {
                            [array addObject:gifData];
                            dispatch_semaphore_signal(sendSemaphore);
                        }];
                    } else {
                        [self accessToImageAccordingToTheAsset:phAsset size:CGSizeZero resizeMode:PHImageRequestOptionsResizeModeFast completion:^(ALAssetSource *image, NSDictionary *info) {
                            [array addObject:image];
                            dispatch_semaphore_signal(sendSemaphore);
                        }];
                    }
                    
                    dispatch_semaphore_wait(sendSemaphore, DISPATCH_TIME_FOREVER);
                }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetImageNotify" object:array];
                dispatch_async(dispatch_get_main_queue(), ^{
                    HiddenHUD;
                });
                
            });
        }];
    }
    return _bottomToolBar;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backBtn setImage:[UIImage imageNamed:@"NavigationBar_Back"] forState:UIControlStateNormal];
        _backBtn.frame = CGRectMake(0, 0, 50, 34);
        @weakify(self)
        [[_backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _backBtn;
}

@end
