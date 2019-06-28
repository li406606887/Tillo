//
//  YMImageBrowser.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/13.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowser.h"
#import "YMImageBrowserView.h"
#import "YMIBTransitionManager.h"
#import "YMImageBrowser+Internal.h"
#import "YMIBUtilities.h"
#import "YMIBLayoutDirectionManager.h"
#import "YMImageBrowserViewLayout.h"

#import "YMImageBrowserPreviewTopBar.h"
#import "YMImageBrowserPreviewBottomBar.h"
#import "YMVideoBrowseCellData.h"
#import "TSImageHandler.h"

@interface YMImageBrowser ()<UIViewControllerTransitioningDelegate, YMImageBrowserViewDelegate, YMImageBrowserDataSource, YMImageBrowserPreviewTopBarDelegate, YMImageBrowserPreviewBottomBarDelegate> {
    BOOL _isFirstViewDidAppear;
    YMImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isRestoringDeviceOrientation;
    UIInterfaceOrientation _statusBarOrientationBefore;
    UIWindowLevel _windowLevelByDefault;
}

@property (nonatomic, strong) YMIBLayoutDirectionManager *layoutDirectionManager;
@property (nonatomic, strong) YMIBTransitionManager *transitionManager;
@property (nonatomic, assign) YMImageBrowserType type;

@end

@implementation YMImageBrowser

- (void)dealloc {
    // If the current instance is released (possibly uncontrollable release), we need to restore the changes to external business.
    self.hiddenSourceObject = nil;
    [self setStatusBarHide:NO];
    [self removeObserverForSystem];
}

- (instancetype)initWithType:(YMImageBrowserType)type {
    if (self = [super init]) {
        self.type = type;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self initVars];
        [self.layoutDirectionManager startObserve];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = YMImageBrowserTypeDefault;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self initVars];
        [self.layoutDirectionManager startObserve];
    }
    return self;
}

- (void)initVars {
    _isFirstViewDidAppear = NO;
    _isRestoringDeviceOrientation = NO;
    
    _currentIndex = 0;
    _supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    _backgroundColor = [UIColor blackColor];
    _enterTransitionType = YMImageBrowserTransitionTypeCoherent;
    _outTransitionType = YMImageBrowserTransitionTypeCoherent;
    _transitionDuration = 0.25;
    _autoHideSourceObject = YES;
    
    if (YMIBLowMemory()) {
        self.shouldPreload = NO;
        self.dataCacheCountLimit = 1;
    } else {
        self.shouldPreload = YES;
        self.dataCacheCountLimit = 8;
    }
    
    if (self.type == YMImageBrowserTypePreview) {
        YMImageBrowserPreviewTopBar *topBar = [YMImageBrowserPreviewTopBar new];
        YMImageBrowserPreviewBottomBar *bottomBar = [YMImageBrowserPreviewBottomBar new];
        
        topBar.delegate = self;
        bottomBar.delegate = self;
        _toolBars = @[topBar, bottomBar];
    }
    
    _shouldHideStatusBar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = _backgroundColor;
    [self addGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _windowLevelByDefault = self.view.window.windowLevel;
    [self setStatusBarHide:YES];
    
    if (!_isFirstViewDidAppear) {
        
        [self updateLayoutOfSubViewsWithLayoutDirection:[YMIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
        
        [self.browserView scrollToPageWithIndex:_currentIndex];
        
        [self addSubViews];
        
        _isFirstViewDidAppear = YES;
        
        [self addObserverForSystem];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHide:NO];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (void)setStatusBarHide:(BOOL)hide {
    if (self.shouldHideStatusBar) {
        self.view.window.windowLevel = hide ? UIWindowLevelStatusBar + 1 : _windowLevelByDefault;
    }
}

#pragma mark - 手势相关
- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ym_imageBrowser:respondsToLongPress:)]) {
            [self.delegate ym_imageBrowser:self respondsToLongPress:sender];
            return;
        }
        
        NSLog(@"长按");
        [self showSaveActionSheet];
    }
}

- (void)showSaveActionSheet {
    if (![[self currentData] isKindOfClass:[YMVideoBrowseCellData class]]) return;
    YMVideoBrowseCellData *videoCellData = (YMVideoBrowseCellData *)[self currentData];
    if (!videoCellData.extraData) return;
    
    MessageModel *msgModel = (MessageModel *)videoCellData.extraData;
    NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return;
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"imageBrowser_save_video_tip") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertC addAction:[UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }]];
    
    [alertC addAction:[UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [TSImageHandler saveVideoToSystemAlbum:filePath showTip:YES];
    }]];

    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - observe
- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > YMIB_HEIGHT_STATUSBAR) {
        self.view.frame = CGRectMake(0, 0, _containerSize.width, _containerSize.height);
    }
}

#pragma mark - 私有方法
- (void)addSubViews {
    [self.view addSubview:self.browserView];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YMImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:obj];
    }];
}

- (void)updateLayoutOfSubViewsWithLayoutDirection:(YMImageBrowserLayoutDirection)layoutDirection {
    _layoutDirection = layoutDirection;
    CGSize containerSize = layoutDirection == YMImageBrowserLayoutDirectionHorizontal ? CGSizeMake(YMIMAGEBROWSER_HEIGHT, YMIMAGEBROWSER_WIDTH) : CGSizeMake(YMIMAGEBROWSER_WIDTH, YMIMAGEBROWSER_HEIGHT);
    _containerSize = containerSize;
    
    [self.browserView updateLayoutWithDirection:layoutDirection containerSize:containerSize];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YMImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj ym_browserUpdateLayoutWithDirection:layoutDirection containerSize:containerSize];
    }];
}

- (void)pageIndexChanged:(NSUInteger)index {
    _currentIndex = index;
    
    id<YMImageBrowserCellDataProtocol> data = [self currentData];
    
    id sourceObj = nil;
    if ([data respondsToSelector:@selector(ym_browserCellSourceObject)]) {
        sourceObj = data.ym_browserCellSourceObject;
    }
    self.hiddenSourceObject = sourceObj;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ym_imageBrowser:pageIndexChanged:data:)]) {
        [self.delegate ym_imageBrowser:self pageIndexChanged:index data:data];
    }
    
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YMImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //页面滑动时候index改变
        if ([obj respondsToSelector:@selector(ym_browserPageIndexChanged:totalPage:data:)]) {
            [obj ym_browserPageIndexChanged:index totalPage:[self.dataSource ym_numberOfCellForImageBrowserView:self.browserView] data:data];
        }
    }];
}

#pragma mark - 公共方法
- (void)setDataSource:(id<YMImageBrowserDataSource>)dataSource {
    self.browserView.ym_dataSource = dataSource;
}

- (id<YMImageBrowserDataSource>)dataSource {
    return self.browserView.ym_dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex + 1 > [self.browserView.ym_dataSource ym_numberOfCellForImageBrowserView:self.browserView]) {
        NSLog(@"超出数组范围");
//        YBIBLOG_ERROR(@"The index out of range.");
    } else {
        _currentIndex = currentIndex;
        if (self.browserView.superview) {
            [self.browserView scrollToPageWithIndex:currentIndex];
        }
    }
}

- (void)reloadData {
    [self.browserView ym_reloadData];
    [self.browserView scrollToPageWithIndex:_currentIndex];
    [self pageIndexChanged:self.browserView.currentIndex];
}

- (id<YMImageBrowserCellDataProtocol>)currentData {
    return [self.browserView currentData];
}

- (void)show {
    if ([self.browserView.ym_dataSource ym_numberOfCellForImageBrowserView:self.browserView] <= 0) {
        return;
    }
    [self showFromController:YMIBGetTopController()];
}

- (void)showFromController:(UIViewController *)fromController {
    //Preload current data.
    if (self.shouldPreload) {
        id<YMImageBrowserCellDataProtocol> needPreloadData = [self.browserView dataAtIndex:self.currentIndex];
        if ([needPreloadData respondsToSelector:@selector(ym_preload)]) {
            [needPreloadData ym_preload];
        }
        
        if (self.currentIndex == 0) {
            [self.browserView preloadWithCurrentIndex:self.currentIndex];
        }
    }
    
    _statusBarOrientationBefore = [UIApplication sharedApplication].statusBarOrientation;
    self.browserView.statusBarOrientationBefore = _statusBarOrientationBefore;
    [fromController presentViewController:self animated:YES completion:nil];
}

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDistanceBetweenPages:(CGFloat)distanceBetweenPages {
    _distanceBetweenPages = distanceBetweenPages;
    ((YMImageBrowserViewLayout *)self.browserView.collectionViewLayout).distanceBetweenPages = distanceBetweenPages;
}

- (BOOL)transitioning {
    return self.transitionManager.transitioning;
}

- (void)setGiProfile:(YMIBGestureInteractionProfile *)giProfile {
    _giProfile = giProfile;
    self.browserView.giProfile = giProfile;
}

- (void)setDataCacheCountLimit:(NSUInteger)dataCacheCountLimit {
    _dataCacheCountLimit = dataCacheCountLimit;
    self.browserView.cacheCountLimit = dataCacheCountLimit;
}

- (void)setShouldPreload:(BOOL)shouldPreload {
    _shouldPreload = shouldPreload;
    self.browserView.shouldPreload = shouldPreload;
}


#pragma mark - internal

- (void)setHiddenSourceObject:(id)hiddenSourceObject {
    if (!_autoHideSourceObject) return;
    if (_hiddenSourceObject && [_hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [_hiddenSourceObject setValue:@(NO) forKey:@"hidden"];
    }
    if (hiddenSourceObject && [hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [hiddenSourceObject setValue:@(YES) forKey:@"hidden"];
    }
    _hiddenSourceObject = hiddenSourceObject;
}

#pragma mark <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitionManager;
}

#pragma mark - <YMImageBrowserViewDelegate>

- (void)ym_imageBrowserViewDismiss:(YMImageBrowserView *)browserView {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YMImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    if ([UIApplication sharedApplication].statusBarOrientation != _statusBarOrientationBefore && [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        NSInteger val = _statusBarOrientationBefore;
        [invocation setArgument:&val atIndex:2];
        _isRestoringDeviceOrientation = YES;
        [invocation invoke];
    }
    
    [self hide];
}

- (void)ym_imageBrowserView:(YMImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration {
    void (^animationsBlock)(void) = ^{
        self.view.backgroundColor = [self->_backgroundColor colorWithAlphaComponent:alpha];
    };
    void (^completionBlock)(BOOL) = ^(BOOL x){
        if (alpha == 1) [self setStatusBarHide:YES];
        if (alpha < 1) [self setStatusBarHide:NO];
    };
    if (duration <= 0) {
        animationsBlock();
        completionBlock(YES);
    } else {
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }
}

- (void)ym_imageBrowserView:(YMImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index {
    [self pageIndexChanged:index];
}

- (void)ym_imageBrowserView:(YMImageBrowserView *)browserView hideTooBar:(NSInteger)hiddenType {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YMImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (hiddenType == 2) {
            obj.hidden = !obj.hidden;
        } else {
            obj.hidden = hiddenType == 1;
        }
    }];
}

#pragma mark - <YMImageBrowserDataSource>
- (NSUInteger)ym_numberOfCellForImageBrowserView:(YMImageBrowserView *)imageBrowserView {
    return self.dataSourceArray.count;
}

- (id<YMImageBrowserCellDataProtocol>)ym_imageBrowserView:(YMImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    return self.dataSourceArray[index];
}

#pragma mark - YMImageBrowserPreviewTopBarDelegate
- (void)ym_imageBrowserPreviewTopBar:(YMImageBrowserPreviewTopBar *)topBar clickBackButton:(UIButton *)button {
    [self hide];
}

#pragma mark - YMImageBrowserPreviewBottomBarDelegate
- (void)ym_imageBrowserPreviewBottomBar:(YMImageBrowserPreviewBottomBar *)topBar clickSendButton:(UIButton *)button {
    [self hide];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ym_imageBrowser:clickSendButton:)]) {
        [self.delegate ym_imageBrowser:self clickSendButton:button];
    }
}

#pragma mark - getter

- (YMImageBrowserView *)browserView {
    if (!_browserView) {
        _browserView = [YMImageBrowserView new];
        _browserView.ym_delegate = self;
        _browserView.ym_dataSource = self;
        YMIBGestureInteractionProfile *giProfile = [YMIBGestureInteractionProfile new];
        if (self.type == YMImageBrowserTypePreview) {
            giProfile.isPreviewType = YES;
            giProfile.disable = YES;
        }
        _browserView.giProfile = giProfile;
    }
    return _browserView;
}

- (YMIBLayoutDirectionManager *)layoutDirectionManager {
    if (!_layoutDirectionManager) {
        _layoutDirectionManager = [YMIBLayoutDirectionManager new];
        __weak typeof(self) wSelf = self;
        [_layoutDirectionManager setLayoutDirectionChangedBlock:^(YMImageBrowserLayoutDirection layoutDirection) {
            __strong typeof(wSelf) self = wSelf;
            if (layoutDirection == YMImageBrowserLayoutDirectionUnknown || self.transitionManager.transitioning || self->_isRestoringDeviceOrientation) return;
            
            [self updateLayoutOfSubViewsWithLayoutDirection:layoutDirection];
        }];
    }
    return _layoutDirectionManager;
}

- (YMIBTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [YMIBTransitionManager new];
        _transitionManager.imageBrowser = self;
    }
    return _transitionManager;
}


@end
