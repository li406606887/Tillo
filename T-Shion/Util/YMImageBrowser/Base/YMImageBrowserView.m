//
//  YMImageBrowserView.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowserView.h"
#import "YMImageBrowserViewLayout.h"
#import "YMImageBrowseCellData.h"


static NSInteger const preloadCount = 2;

@interface YMImageBrowserView () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableSet *_reuseIdentifierSet;
    YMImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isDealingScreenRotation;
    BOOL _bodyIsInCenter;
    BOOL _isDealedSELInitializeFirst;
    NSCache *_dataCache;
}

@property (nonatomic, assign) NSUInteger currentIndex;

@end

@implementation YMImageBrowserView

#pragma mark - 生命周期
- (void)dealloc {
    _dataCache = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame collectionViewLayout:[YMImageBrowserViewLayout new]];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initVars];
        
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = NO;
        self.delegate = self;
        self.dataSource = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)initVars {
    _layoutDirection = YMImageBrowserLayoutDirectionUnknown;
    _reuseIdentifierSet = [NSMutableSet set];
    _isDealingScreenRotation = NO;
    _bodyIsInCenter = YES;
    _currentIndex = NSUIntegerMax;
    _isDealedSELInitializeFirst = NO;
    _cacheCountLimit = 8;
}

#pragma mark - 公用方法
- (void)updateLayoutWithDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    if (_layoutDirection == layoutDirection) return;
    _isDealingScreenRotation = YES;
    
    _containerSize = containerSize;
    self.frame = CGRectMake(0, 0, _containerSize.width, _containerSize.height);
    _layoutDirection = layoutDirection;
    
    if (self.superview) {
        // Notice 'visibleCells' layout direction changed, can't use '-reloadData' because it will triggering '-prepareForReuse' of cell.
        NSArray<UICollectionViewCell<YMImageBrowserCellProtocol> *> *cells = [self visibleCells];
        [cells enumerateObjectsUsingBlock:^(UICollectionViewCell<YMImageBrowserCellProtocol> * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell respondsToSelector:@selector(ym_browserLayoutDirectionChanged:containerSize:)]) {
                [cell ym_browserLayoutDirectionChanged:self->_layoutDirection containerSize:self->_containerSize];
            }
        }];
        [self scrollToPageWithIndex:self.currentIndex];
    }
    
    [self layoutIfNeeded];
    _isDealingScreenRotation = NO;
}

- (void)scrollToPageWithIndex:(NSInteger)index {
    if (index >= [self.ym_dataSource ym_numberOfCellForImageBrowserView:self]) {
        // If index overstep the boundary, maximum processing.
        self.currentIndex = [self.ym_dataSource ym_numberOfCellForImageBrowserView:self] - 1;
        self.contentOffset = CGPointMake(self.bounds.size.width * self.currentIndex, 0);
    } else {
        CGPoint targetPoint = CGPointMake(self.bounds.size.width * index, 0);
        if (CGPointEqualToPoint(self.contentOffset, targetPoint)) {
            [self scrollViewDidScroll:self];
        } else {
            self.contentOffset = targetPoint;
        }
    }
}

- (void)ym_reloadData {
    _dataCache = nil;
    [self reloadData];
}

- (id<YMImageBrowserCellDataProtocol>)currentData {
    return [self dataAtIndex:self.currentIndex];
}

- (id<YMImageBrowserCellDataProtocol>)dataAtIndex:(NSUInteger)index {
    if (index < 0 || index >= [self.ym_dataSource ym_numberOfCellForImageBrowserView:self]) return nil;
    
    if (!_dataCache) {
        _dataCache = [NSCache new];
        _dataCache.countLimit = self.cacheCountLimit;
    }
    
    id<YMImageBrowserCellDataProtocol> data;
    if (_dataCache && [_dataCache objectForKey:@(index)]) {
        data = [_dataCache objectForKey:@(index)];
    } else {
        data = [self.ym_dataSource ym_imageBrowserView:self dataForCellAtIndex:index];
        [_dataCache setObject:data forKey:@(index)];
    }
    return data;
}

- (void)preloadWithCurrentIndex:(NSInteger)index {
    for (NSInteger i = -preloadCount; i <= preloadCount; ++i) {
        if (i == 0) continue;
        id<YMImageBrowserCellDataProtocol> needPreloadData = [self dataAtIndex:index + i];
        if ([needPreloadData respondsToSelector:@selector(ym_preload)]) {
            [needPreloadData ym_preload];
        }
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.ym_dataSource || ![self.ym_dataSource respondsToSelector:@selector(ym_numberOfCellForImageBrowserView:)]) return 0;
    return [self.ym_dataSource ym_numberOfCellForImageBrowserView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.ym_dataSource || ![self.ym_dataSource respondsToSelector:@selector(ym_imageBrowserView:dataForCellAtIndex:)]) {
        return [UICollectionViewCell new];
    }
    
    id<YMImageBrowserCellDataProtocol> data = [self dataAtIndex:indexPath.row];
    
    NSAssert(data && [data respondsToSelector:@selector(ym_classOfBrowserCell)], @"your custom data must conforms '<YMImageBrowserCellDataProtocol>' and implement '-ym_classOfBrowserCell'");
    Class cellClass = data.ym_classOfBrowserCell;
    NSAssert(cellClass, @"the class get from '-ym_classOfBrowserCell' is invalid");
    
    NSString *identifier = NSStringFromClass(cellClass);
    if (![_reuseIdentifierSet containsObject:cellClass]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:identifier ofType:@"nib"];
        if (path) {
            [collectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
        } else {
            [collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
        }
        [_reuseIdentifierSet addObject:cellClass];
    }
    UICollectionViewCell<YMImageBrowserCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSAssert(cell, @"your custom cell must be subclass of 'UICollectionViewCell'");
    
    NSAssert([cell respondsToSelector:@selector(ym_initializeBrowserCellWithData:layoutDirection:containerSize:)], @"your custom cell must conforms '<YMImageBrowserCellProtocol>' and implement '-ym_initializeBrowserCellWithData:layoutDirection:containerSize:'");
    [cell ym_initializeBrowserCellWithData:data layoutDirection:_layoutDirection containerSize:_containerSize];
    
    if ([cell respondsToSelector:@selector(ym_browserStatusBarOrientationBefore:)]) {
        [cell ym_browserStatusBarOrientationBefore:self.statusBarOrientationBefore];
    }
    
    if ([cell respondsToSelector:@selector(setYm_browserDismissBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setYm_browserDismissBlock:^{
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf.ym_delegate ym_imageBrowserViewDismiss:sSelf];
        }];
    }
    
    if ([cell respondsToSelector:@selector(setYm_browserScrollEnabledBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setYm_browserScrollEnabledBlock:^(BOOL enabled) {
            __strong typeof(wSelf) sSelf = wSelf;
            sSelf.scrollEnabled = enabled;
        }];
    }
    
    if ([cell respondsToSelector:@selector(setYm_browserChangeAlphaBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setYm_browserChangeAlphaBlock:^(CGFloat alpha, CGFloat duration) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf.ym_delegate ym_imageBrowserView:sSelf changeAlpha:alpha duration:duration];
        }];
    }
    
    if ([cell respondsToSelector:@selector(ym_browserSetGestureInteractionProfile:)]) {
        [cell ym_browserSetGestureInteractionProfile:self.giProfile];
    }
    
    if ([cell respondsToSelector:@selector(setYm_browserToolBarHiddenBlock:)]) {
        __weak typeof(self) wSelf = self;
        [cell setYm_browserToolBarHiddenBlock:^(NSInteger hiddenType) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf.ym_delegate ym_imageBrowserView:sSelf hideTooBar:hiddenType];
        }];
    }
    
    if ([cell respondsToSelector:@selector(ym_browserInitializeFirst:)] && !_isDealedSELInitializeFirst) {
        _isDealedSELInitializeFirst = YES;
        [cell ym_browserInitializeFirst:_currentIndex == indexPath.row];
    }
    
    if (collectionView.window && self.shouldPreload) {
        [self preloadWithCurrentIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat indexF = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSUInteger index = (NSUInteger)(indexF + 0.5);
    
    BOOL isInCenter = indexF <= (NSInteger)indexF + 0.001 && indexF >= (NSInteger)indexF - 0.001;
    if (_bodyIsInCenter != isInCenter) {
        _bodyIsInCenter = isInCenter;
        
        NSArray<UICollectionViewCell<YMImageBrowserCellProtocol> *> *cells = [self visibleCells];
        [cells enumerateObjectsUsingBlock:^(UICollectionViewCell<YMImageBrowserCellProtocol> * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell respondsToSelector:@selector(ym_browserBodyIsInTheCenter:)]) {
                [cell ym_browserBodyIsInTheCenter:self->_bodyIsInCenter];
            }
        }];
    }
    
    if (index >= [self.ym_dataSource ym_numberOfCellForImageBrowserView:self]) return;
    if (self.currentIndex != index && !_isDealingScreenRotation) {
        self.currentIndex = index;
        
        [self.ym_delegate ym_imageBrowserView:self pageIndexChanged:self.currentIndex];
        
        // Notice 'visibleCells' page index changed.
        NSArray<UICollectionViewCell<YMImageBrowserCellProtocol> *> *cells = [self visibleCells];
        [cells enumerateObjectsUsingBlock:^(UICollectionViewCell<YMImageBrowserCellProtocol> * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell respondsToSelector:@selector(ym_browserPageIndexChanged:ownIndex:)]) {
                [cell ym_browserPageIndexChanged:self.currentIndex ownIndex:[self indexPathForCell:cell].row];
            }
        }];
    }
}

#pragma mark - hit-test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    // When the hit-test view is 'UISlider', set '_scrollEnabled' to 'NO', avoid gesture conflicts.
    self.scrollEnabled = ![view isKindOfClass:UISlider.class];
    return view;
}


@end
