//
//  TSImageCollectionController.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSImageCollectionController.h"
#import "TSImageHandler.h"
#import "UIScrollView+TS.h"
#import "TSImageCollectionCell.h"
#import "TSImageSelectedHandler.h"
#import "TSImageBrowserController.h"
#import "TSImageBrowserToolBar.h"
#import "ALAssetSource.h"
#import "YMImageBrowser.h"
#import "YMImageBrowseCellData.h"
#import "YMVideoBrowseCellData.h"

@interface TSImageCollectionController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YMImageBrowserDataSource, YMImageBrowserDelegate>

@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic , strong) UIButton *cancleBtn;
@property (nonatomic , strong) UIButton *backBtn;

@property (nonatomic , assign) BOOL needOriginal;
@property (nonatomic , copy) NSArray <PHAsset *>*phAssetsArray;
@property (nonatomic , copy) NSMutableArray <PHAsset *>*selectPhAssetsArray;
@property (nonatomic , assign) NSInteger lastSelectedIndex;
@property (nonatomic , strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic , strong) TSImageHandler *imageHandler;
@property (nonatomic , strong) TSImageBrowserToolBar *toolBar;

//@property (nonatomic, strong) dispatch_semaphore_t sendSemaphore;//发送时候的信号量

@end

@implementation TSImageCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver];
    [self addChildView];
    [self loadPhotos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //预览回来进行刷新
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[TSImageSelectedHandler shareInstance] removeAllAssets];
    [[TSImageSelectedHandler shareInstance] removeAllIndexs];
    self.selectPhAssetsArray = nil;
}

- (void)addChildView {
    self.title = [NSString replaceEnglishAssetCollectionNamme:self.assetCollection.localizedTitle];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.toolBar];
    self.view.userInteractionEnabled = YES;
   
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.cancleBtn];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    [self setLeftNavigation];
    [self setRightNavigation];
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
    
- (void)setRightNavigation {
    UIBarButtonItem *spaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithCustomView: self.cancleBtn];
    
    UIBarButtonItem *spaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.rightBarButtonItems = @[submitItem];
    } else {
        
        spaceLeft.width = 0;
        spaceRight.width = 15;
        self.navigationItem.rightBarButtonItems = @[spaceLeft, submitItem, spaceRight];
    }
}
    
- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadPhotos {
    @weakify(self)
    [self.imageHandler enumerateAssetsInAssetCollection:self.assetCollection finishBlock:^(NSArray <PHAsset *>*result) {
        @strongify(self)
        self.phAssetsArray = [NSArray arrayWithArray:result];
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.collectionView scrollsToBottomAnimated:NO];
        });
    }];
}

- (void)viewDidLayoutSubviews {
    [self.toolBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 50 + self.view.safeAreaInsets.bottom));
        } else {
            // Fallback on earlier versions
            make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 50 ));
        }
    }];
    
    [self.collectionView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self.view);
        make.width.mas_offset(SCREEN_WIDTH);
        make.bottom.equalTo(self.toolBar.mas_top);
    }];
    
    [super viewDidLayoutSubviews];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectAssetsAddNotification:) name:kSelectAssetsAddNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectAssetsRemoveNotification:) name:kSelectAssetsRemoveNotification object:nil];
}

- (void)selectAssetsAddNotification:(NSNotification *)notification {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:[[TSImageSelectedHandler shareInstance] selectedIndexs]];
    [array removeLastObject];
    [self.collectionView reloadItemsAtIndexPaths:array];
    [_toolBar resetSelectPhotosNumber:[[TSImageSelectedHandler shareInstance] selectedIndexs].count];
}

- (void)selectAssetsRemoveNotification:(NSNotification *)notification {
     [self.collectionView reloadItemsAtIndexPaths:[[TSImageSelectedHandler shareInstance] selectedIndexs]];
    [_toolBar resetSelectPhotosNumber:[[TSImageSelectedHandler shareInstance] selectedIndexs].count];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.phAssetsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([TSImageCollectionCell class])] forIndexPath:indexPath];
    cell.phAsset = self.phAssetsArray[indexPath.row];
    cell.indexPath = indexPath;
    @weakify(self)
    cell.cellSelectedBlock = ^(BOOL state) {
        @strongify(self)
        PHAsset *phAsset = self.phAssetsArray[indexPath.row];
        if (state) {
            [self.selectPhAssetsArray addObject:phAsset];
        }else {
            [self.selectPhAssetsArray removeObject:phAsset];
        }
    };
    [cell resetSelected:[[TSImageSelectedHandler shareInstance] containsAsset:cell.phAsset]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TSImageCollectionCell *cell = (TSImageCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    @weakify(self)
    cell.cellSelectedBlock = ^(BOOL state) {
        @strongify(self)
        PHAsset *phAsset = self.phAssetsArray[indexPath.row];
        if (state) {
            [self.selectPhAssetsArray addObject:phAsset];
        }else {
            [self.selectPhAssetsArray removeObject:phAsset];
        }
    };
    [cell selectedBtnClick:cell.selectedBtn];
}

#pragma mark - <  根据PHAsset获取图片信息  >
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
        
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        if (downloadFinined && imageData) {
            ALAssetSource *gifModel = [ALAssetSource new];
            gifModel.sourceType = ALAssetSourceType_GIF;
            gifModel.sourceData = imageData;
            gifModel.originalImage = [UIImage imageWithData:imageData];
            completion(gifModel,info);
        }
    }];
}


- (void)accessToVideoAccordingToTheAsset:(PHAsset *)asset completion:(void(^)(ALAssetSource *gifData, NSDictionary *info))completion {
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
//    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (progressHandler) {
//                progressHandler(progress, error, stop, info);
//            }
//        });
//    };
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
    }];

}

- (BOOL)isGif:(PHAsset *)asset {
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    return [orgFilename containsString:@"GIF"] || [orgFilename containsString:@"gif"];
}

#pragma mark - YMImageBrowser
- (void)showBrowserForSystemAlbumWithIndex:(NSInteger)index {
    YMImageBrowser *browser = [[YMImageBrowser alloc] initWithType:YMImageBrowserTypePreview];
    browser.dataSource = self;
    browser.delegate = self;
    browser.currentIndex = index;
    [browser show];
}

- (NSUInteger)ym_numberOfCellForImageBrowserView:(YMImageBrowserView *)imageBrowserView {
    return self.selectPhAssetsArray.count;
}

- (id<YMImageBrowserCellDataProtocol>)ym_imageBrowserView:(YMImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    PHAsset *asset = (PHAsset *)self.selectPhAssetsArray[index];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        
        // Type 1 : 系统相册的视频 / Video of system album
        YMVideoBrowseCellData *data = [YMVideoBrowseCellData new];
        data.phAsset = asset;
        data.sourceObject = [self sourceObjAtIdx:index];
        
        return data;
    } else if (asset.mediaType == PHAssetMediaTypeImage) {
        
        // Type 2 : 系统相册的图片 / Image of system album
        YMImageBrowseCellData *data = [YMImageBrowseCellData new];
        data.phAsset = asset;
        data.sourceObject = [self sourceObjAtIdx:index];
        
        return data;
    }
    return nil;
}

- (id)sourceObjAtIdx:(NSInteger)idx {
    TSImageCollectionCell *cell = (TSImageCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    return cell ? cell.imageView : nil;
}

- (void)ym_imageBrowser:(YMImageBrowser *)imageBrowser clickSendButton:(UIButton *)button {
    LoadingWin(@"")
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    @weakify(self)
    dispatch_async(serialQueue, ^{
        __block NSMutableArray *array = [NSMutableArray array];
        @strongify(self)
        [self.selectPhAssetsArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull phAsset, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self)
            dispatch_semaphore_t sendSemaphore = dispatch_semaphore_create(0);
            if ([ALAssetSource isVideo:phAsset]) {
                [ALAssetSource videoInfoWithAsset:phAsset completion:^(ALAssetSource *videoData) {
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
}

#pragma mark - getter and setter;
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
        _collectionView.backgroundColor = [UIColor ALKeyBgColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[TSImageCollectionCell class] forCellWithReuseIdentifier:[NSString stringWithUTF8String:object_getClassName([TSImageCollectionCell class])]];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if (!_collectionViewFlowLayout) {
        CGFloat kPadding = 3.f;
        CGFloat kWidth = (SCREEN_WIDTH - 5 * kPadding) / 4;
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewFlowLayout.itemSize = CGSizeMake(kWidth, kWidth);
        _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding , kPadding);
        _collectionViewFlowLayout.minimumInteritemSpacing = kPadding;
        _collectionViewFlowLayout.minimumLineSpacing = kPadding;
        _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _collectionViewFlowLayout;
}

- (UIButton *)cancleBtn {
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancleBtn setTitle:Localized(@"Cancel") forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont ALBoldFontSize16];
        _cancleBtn.frame = CGRectMake(0, 0, 50, 34);
        @weakify(self)
        [[_cancleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _cancleBtn;
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

- (TSImageBrowserToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[TSImageBrowserToolBar alloc] initWithFrame:CGRectZero barStyle:UIBarStyleDefault];
        _toolBar.backgroundColor = [UIColor whiteColor];
        [_toolBar layoutIfNeeded];
        [_toolBar resetSelectPhotosNumber:[[TSImageSelectedHandler shareInstance] selectedIndexs].count];
        @weakify(self)
        [_toolBar handlePreviewButtonWithBlock:^{
            @strongify(self)
            [self showBrowserForSystemAlbumWithIndex:0];
//            TSImageBrowserController *browserVC = [[TSImageBrowserController alloc] init];
//            browserVC.phAssetsArray = self.selectPhAssetsArray;
//            NSIndexPath *tempIndexPath = [[TSImageSelectedHandler shareInstance] selectedIndexs][0];
//            browserVC.currentIndex = tempIndexPath.row;
//            [self.navigationController pushViewController:browserVC animated:YES];
        }];
        
        [_toolBar handleFinishedButtonWithBlock:^{
            LoadingWin(@"")
            dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
            
            dispatch_async(serialQueue, ^{
                __block NSMutableArray *array = [NSMutableArray array];
                @strongify(self)
                [self.selectPhAssetsArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull phAsset, NSUInteger idx, BOOL * _Nonnull stop) {
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
    return _toolBar;
}

- (TSImageHandler *)imageHandler {
    if (!_imageHandler) {
        _imageHandler = [[TSImageHandler alloc] init];
    }
    return _imageHandler;
}

- (PHCachingImageManager *)cachingImageManager {
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

- (NSMutableArray<PHAsset *> *)selectPhAssetsArray {
    if (!_selectPhAssetsArray) {
        _selectPhAssetsArray = [NSMutableArray array];
    }
    return _selectPhAssetsArray;
}
@end
