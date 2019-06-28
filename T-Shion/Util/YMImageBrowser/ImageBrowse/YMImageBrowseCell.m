//
//  YMImageBrowseCell.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/14.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowseCell.h"
#import <objc/runtime.h>

#import "YMImageBrowseCellData.h"
#import "YMImageBrowserCellProtocol.h"
#import "YMIBPhotoAlbumManager.h"
#import "YMIBGestureInteractionProfile.h"
#import "YMImageBrowseCellData+Internal.h"
#import "YMImageBrowserProgressView.h"

@interface YMImageBrowseCell ()<YMImageBrowserCellProtocol, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    YMImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _zooming;
    BOOL _dragging;
    BOOL _bodyInCenter;
    BOOL _outTransitioning;
    
    CGPoint _gestureInteractionStartPoint;
    BOOL _gestureInteracting;
    
    YMIBGestureInteractionProfile *_giProfile;
    UIInterfaceOrientation _statusBarOrientationBefore;
}

@property (nonatomic, strong) UIScrollView *mainContentView;
@property (nonatomic, strong) YYAnimatedImageView *mainImageView;
@property (nonatomic, strong) UIImageView *tailoringImageView;
@property (nonatomic, strong) YMImageBrowserProgressView *progressView;
@property (nonatomic, strong) YMImageBrowseCellData *cellData;

@end


@implementation YMImageBrowseCell

@synthesize ym_browserDismissBlock = _ym_browserDismissBlock;
@synthesize ym_browserScrollEnabledBlock = _ym_browserScrollEnabledBlock;
@synthesize ym_browserChangeAlphaBlock = _ym_browserChangeAlphaBlock;
@synthesize ym_browserToolBarHiddenBlock = _ym_browserToolBarHiddenBlock;


#pragma mark - 生命周期
- (void)dealloc {
    [self removeObserverForDataState];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVars];
        
        [self.contentView addSubview:self.mainContentView];
        [self.mainContentView addSubview:self.mainImageView];
        [self addGesture];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    _outTransitioning = NO;
}

- (void)prepareForReuse {
    [self initVars];
    [self removeObserverForDataState];
    
    self.mainContentView.zoomScale = 1;
    self.mainImageView.image = nil;
    [self.contentView ym_hideProgressView];
    [self hideTailoringImageView];
    
    [super prepareForReuse];
}

- (void)initVars {
    _zooming = NO;
    _dragging = NO;
    _bodyInCenter = YES;
    _outTransitioning = NO;
    _layoutDirection = YMImageBrowserLayoutDirectionUnknown;
    _containerSize = CGSizeMake(1, 1);
    
    _gestureInteractionStartPoint = CGPointZero;
    _gestureInteracting = NO;
}


#pragma mark - YMImageBrowserCellProtocol
- (void)ym_initializeBrowserCellWithData:(id<YMImageBrowserCellDataProtocol>)data layoutDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    _containerSize = containerSize;
    _layoutDirection = layoutDirection;
    
    if (![data isKindOfClass:YMImageBrowseCellData.class]) return;
    self.cellData = data;
    
    [self addObserverForDataState];
    
    [self updateLayoutWithContainerSize:containerSize];
}

- (void)ym_browserLayoutDirectionChanged:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    _containerSize = containerSize;
    _layoutDirection = layoutDirection;
    
    [self hideTailoringImageView];
    
    if (_gestureInteracting) {
        [self restoreGestureInteractionWithDuration:0];
    }
    
    [self updateLayoutWithContainerSize:containerSize];
    [self updateMainContentViewLayoutWithContainerSize:containerSize fillType:[self.cellData getFillTypeWithLayoutDirection:layoutDirection]];
}

- (void)ym_browserBodyIsInTheCenter:(BOOL)isIn {
    _bodyInCenter = isIn;
}

- (UIView *)ym_browserCurrentForegroundView {
    return self.mainImageView;
}

- (void)ym_browserSetGestureInteractionProfile:(YMIBGestureInteractionProfile *)giProfile {
    _giProfile = giProfile;
}

- (void)ym_browserStatusBarOrientationBefore:(UIInterfaceOrientation)orientation {
    _statusBarOrientationBefore = orientation;
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.cellData.zoomScale = scrollView.zoomScale;
    
    CGRect imageViewFrame = self.mainImageView.frame;
    CGFloat width = imageViewFrame.size.width,
    height = imageViewFrame.size.height,
    sHeight = scrollView.bounds.size.height,
    sWidth = scrollView.bounds.size.width;
    if (height > sHeight) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    }
    if (width > sWidth) {
        imageViewFrame.origin.x = 0;
    } else {
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    }
    self.mainImageView.frame = imageViewFrame;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cutImage];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    _zooming = YES;
    [self hideTailoringImageView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    _zooming = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _dragging = YES;
    [self hideTailoringImageView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _dragging = NO;
}


#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - gesture

- (void)addGesture {
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapSingle:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapDouble:)];
    tapDouble.numberOfTapsRequired = 2;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPan:)];
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    [tapSingle requireGestureRecognizerToFail:pan];
    [tapDouble requireGestureRecognizerToFail:pan];
    
    [self.mainContentView addGestureRecognizer:tapSingle];
    [self.mainContentView addGestureRecognizer:tapDouble];
    [self.mainContentView addGestureRecognizer:pan];
}

- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    if (_giProfile.isPreviewType) {
        self.ym_browserToolBarHiddenBlock(2);
        return;
    }
    [self browserDismiss];
}

- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap {
    [self hideTailoringImageView];
    
    UIScrollView *scrollView = self.mainContentView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (BOOL)currentIsLargeImageBrowsing {
    CGFloat sHeight = self.mainContentView.bounds.size.height,
    sWidth = self.mainContentView.bounds.size.width,
    sContentHeight = self.mainContentView.contentSize.height,
    sContentWidth = self.mainContentView.contentSize.width;
    return sContentHeight > sHeight || sContentWidth > sWidth;
}

- (void)respondsToPan:(UIPanGestureRecognizer *)pan {
    if ((CGRectIsEmpty(self.mainImageView.frame) || !self.mainImageView.image) || _giProfile.disable) return;
    
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        _gestureInteractionStartPoint = point;
        
    } else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateRecognized || pan.state == UIGestureRecognizerStateFailed) {
        
        // END
        if (_gestureInteracting) {
            CGPoint velocity = [pan velocityInView:self.mainContentView];
            
            BOOL velocityArrive = ABS(velocity.y) > _giProfile.dismissVelocityY;
            BOOL distanceArrive = ABS(point.y - _gestureInteractionStartPoint.y) > _containerSize.height * _giProfile.dismissScale;
            
            BOOL shouldDismiss = distanceArrive || velocityArrive;
            if (shouldDismiss) {
                [self browserDismiss];
            } else {
        
                [self restoreGestureInteractionWithDuration:_giProfile.restoreDuration];
            }
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [pan velocityInView:self.mainContentView];
        CGFloat triggerDistance = _giProfile.triggerDistance;
        
        BOOL startPointValid = !CGPointEqualToPoint(_gestureInteractionStartPoint, CGPointZero);
        BOOL distanceArrive = ABS(point.x - _gestureInteractionStartPoint.x) < triggerDistance && ABS(velocity.x) < 500;
        BOOL upArrive = point.y - _gestureInteractionStartPoint.y > triggerDistance && self.mainContentView.contentOffset.y <= 1;
        BOOL downArrive = point.y - _gestureInteractionStartPoint.y < -triggerDistance && self.mainContentView.contentOffset.y + self.mainContentView.bounds.size.height >= MAX(self.mainContentView.contentSize.height, self.mainContentView.bounds.size.height) - 1;
        
        BOOL shouldStart = startPointValid && !_gestureInteracting && (upArrive || downArrive) && distanceArrive && _bodyInCenter && !_zooming;
        // START
        if (shouldStart) {
            if ([UIApplication sharedApplication].statusBarOrientation != _statusBarOrientationBefore) {
                [self browserDismiss];
            } else {
                [self hideTailoringImageView];
                
                _gestureInteractionStartPoint = point;
                
                CGRect startFrame = self.mainContentView.frame;
                CGFloat anchorX = point.x / startFrame.size.width,
                anchorY = point.y / startFrame.size.height;
                self.mainContentView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
                self.mainContentView.userInteractionEnabled = NO;
                self.mainContentView.scrollEnabled = NO;
                
                self.ym_browserScrollEnabledBlock(NO);
                self.ym_browserToolBarHiddenBlock(1);
                
                _gestureInteracting = YES;
            }
        }
        
        // CHNAGE
        if (_gestureInteracting) {
            self.mainContentView.center = point;
            CGFloat scale = 1 - ABS(point.y - _gestureInteractionStartPoint.y) / (_containerSize.height * 1.2);
            if (scale > 1) scale = 1;
            if (scale < 0.35) scale = 0.35;
            self.mainContentView.transform = CGAffineTransformMakeScale(scale, scale);
            
            CGFloat alpha = 1 - ABS(point.y - _gestureInteractionStartPoint.y) / (_containerSize.height * 1.1);
            if (alpha > 1) alpha = 1;
            if (alpha < 0) alpha = 0;
            self.ym_browserChangeAlphaBlock(alpha, 0);
        }
    }
}

- (void)restoreGestureInteractionWithDuration:(NSTimeInterval)duration {
    self.ym_browserChangeAlphaBlock(1, duration);
    
    void (^animations)(void) = ^{
        self.mainContentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.mainContentView.center = CGPointMake(self->_containerSize.width / 2, self->_containerSize.height / 2);
        self.mainContentView.transform = CGAffineTransformIdentity;
    };
    void (^completion)(BOOL finished) = ^(BOOL finished){
        self.ym_browserScrollEnabledBlock(YES);
        self.ym_browserToolBarHiddenBlock(0);
        
        self.mainContentView.userInteractionEnabled = YES;
        self.mainContentView.scrollEnabled = YES;
        
        self->_gestureInteractionStartPoint = CGPointZero;
        self->_gestureInteracting = NO;
        
        [self cutImage];
    };
    if (duration <= 0) {
        animations();
        completion(NO);
    } else {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
}


#pragma mark - observe
- (void)addObserverForDataState {
    [self.cellData addObserver:self forKeyPath:@"dataState" options:NSKeyValueObservingOptionNew context:nil];
    [self.cellData loadData];
}

- (void)removeObserverForDataState {
    [self.cellData removeObserver:self forKeyPath:@"dataState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (!_outTransitioning && object == self.cellData && [keyPath isEqualToString:@"dataState"]) {
        [self cellDataStateChanged];
    }
}

#pragma mark - private
- (void)browserDismiss {
    _outTransitioning = YES;
    [self hideTailoringImageView];
    [self.contentView ym_hideProgressView];
    [self ym_hideProgressView];
    self.ym_browserDismissBlock();
    _gestureInteracting = NO;
}

- (void)cellDataStateChanged {
    YMImageBrowseCellData *data = self.cellData;
    YMImageBrowseCellDataState dataState = data.dataState;
    switch (dataState) {
        case YMImageBrowseCellDataStateInvalid: {
            if (self.cellData.extraData && [self.cellData.extraData isKindOfClass:[NSDictionary class]]) {
                //如果是群头像或者头像不执行操作
            } else {
                [self.contentView ym_showProgressViewWithText:@"图片无效" click:nil];
            }
        }
            break;
        case YMImageBrowseCellDataStateImageReady: {
            if (self.mainImageView.image != data.image) {
                self.mainImageView.image = data.image;
                [self updateMainContentViewLayoutWithContainerSize:_containerSize fillType:[data getFillTypeWithLayoutDirection:_layoutDirection]];
            }
        }
            break;
        case YMImageBrowseCellDataStateIsDecoding: {
            if (!self.mainImageView.image) {
                [self.contentView ym_showProgressViewLoading];
            }
        }
            break;
        case YMImageBrowseCellDataStateDecodeComplete: {
            [self.contentView ym_hideProgressView];
        }
            break;
        case YMImageBrowseCellDataStateCompressImageReady: {
            if (self.mainImageView.image != data.compressImage) {
                self.mainImageView.image = data.compressImage;
                [self updateMainContentViewLayoutWithContainerSize:_containerSize fillType:[data getFillTypeWithLayoutDirection:_layoutDirection]];
            }
        }
            break;
        case YMImageBrowseCellDataStateThumbImageReady: {
            // If the image has been display, discard the thumb image.
            if (!self.mainImageView.image) {
                self.mainImageView.image = data.thumbImage;
                [self updateMainContentViewLayoutWithContainerSize:_containerSize fillType:[data getFillTypeWithLayoutDirection:_layoutDirection]];
            }
        }
            break;
        case YMImageBrowseCellDataStateIsCompressingImage: {
            [self.contentView ym_showProgressViewLoading];
        }
            break;
        case YMImageBrowseCellDataStateCompressImageComplete: {
            [self.contentView ym_hideProgressView];
        }
            break;
        case YMImageBrowseCellDataStateIsLoadingPHAsset: {
            [self.contentView ym_showProgressViewLoading];
        }
            break;
        case YMImageBrowseCellDataStateLoadPHAssetSuccess: {
            [self.contentView ym_hideProgressView];
        }
            break;
        case YMImageBrowseCellDataStateLoadPHAssetFailed: {
            [self.contentView ym_showProgressViewWithText:@"图片无效" click:nil];
        }
            break;
        case YMImageBrowseCellDataStateIsDownloading: {
            [self.contentView ym_showProgressViewWithValue:data.downloadProgress];
        }
            break;
        case YMImageBrowseCellDataStateDownloadProcess: {
            [self.contentView ym_showProgressViewWithValue:data.downloadProgress];
        }
            break;
        case YMImageBrowseCellDataStateDownloadSuccess: {
            [self.contentView ym_hideProgressView];
        }
            break;
        case YMImageBrowseCellDataStateDownloadFailed: {
            [self.contentView ym_showProgressViewWithText:@"下载图片失败" click:nil];
        }
            break;
        default:
            break;
    }
}

- (void)updateLayoutWithContainerSize:(CGSize)containerSize {
    self.mainContentView.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
}

- (void)updateMainContentViewLayoutWithContainerSize:(CGSize)containerSize fillType:(YMImageBrowseFillType)fillType {
    CGSize imageSize;
    if (self.cellData.image) {
        imageSize = self.cellData.image.size;
    } else if (self.cellData.thumbImage) {
        imageSize = self.cellData.thumbImage.size;
    } else {
        return;
    }
    
    CGRect imageViewFrame = [self.cellData.class getImageViewFrameWithContainerSize:containerSize imageSize:imageSize fillType:fillType];
    
    self.mainContentView.zoomScale = 1;
    self.mainContentView.contentSize = [self.cellData.class getContentSizeWithContainerSize:containerSize imageViewFrame:imageViewFrame];
    self.mainContentView.minimumZoomScale = 1;
    self.mainContentView.maximumZoomScale = 1;
    if (self.cellData.image) {
        self.mainContentView.maximumZoomScale = self.cellData.maxZoomScale >= 1 ? self.cellData.maxZoomScale : [self.cellData.class getMaximumZoomScaleWithContainerSize:containerSize imageSize:imageSize fillType:fillType];
    }
    
    self.mainImageView.frame = imageViewFrame;
}

- (void)showTailoringImageView:(UIImage *)image {
    if (_gestureInteracting) return;
    if (!self.tailoringImageView.superview) {
        [self.contentView addSubview:self.tailoringImageView];
    }
    self.tailoringImageView.frame = CGRectMake(0, 0, _containerSize.width, _containerSize.height);
    self.tailoringImageView.hidden = NO;
    self.tailoringImageView.image = image;
}

- (void)hideTailoringImageView {
    // Don't use 'getter' method, because it's according to the need to load.
    if (_tailoringImageView) {
        self.tailoringImageView.hidden = YES;
    }
}

- (void)cutImage {
    if ([self.cellData needCompress] && !self.cellData.cutting && self.mainContentView.zoomScale > 1.15) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_cutImage) object:nil];
        [self performSelector:@selector(_cutImage) withObject:nil afterDelay:0.25];
    }
}

- (void)_cutImage {
    CGFloat scale = self.cellData.image.size.width / self.mainContentView.contentSize.width;
    CGFloat x = self.mainContentView.contentOffset.x * scale,
    y = self.mainContentView.contentOffset.y * scale,
    width = self.mainContentView.bounds.size.width * scale,
    height = self.mainContentView.bounds.size.height * scale;
    
    YMImageBrowseCellData *tmp = self.cellData;
    [self.cellData cuttingImageToRect:CGRectMake(x, y, width, height) complete:^(UIImage *image) {
        if (tmp == self.cellData && !self->_dragging) {
            [self showTailoringImageView:image];
        }
    }];
}

#pragma mark - getter

- (UIScrollView *)mainContentView {
    if (!_mainContentView) {
        _mainContentView = [UIScrollView new];
        _mainContentView.delegate = self;
        _mainContentView.showsHorizontalScrollIndicator = NO;
        _mainContentView.showsVerticalScrollIndicator = NO;
        _mainContentView.decelerationRate = UIScrollViewDecelerationRateFast;
        _mainContentView.maximumZoomScale = 1;
        _mainContentView.minimumZoomScale = 1;
        _mainContentView.alwaysBounceHorizontal = NO;
        _mainContentView.alwaysBounceVertical = NO;
        _mainContentView.layer.masksToBounds = NO;
        if (@available(iOS 11.0, *)) {
            _mainContentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mainContentView;
}

- (YYAnimatedImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [YYAnimatedImageView new];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.masksToBounds = YES;
    }
    return _mainImageView;
}

- (YMImageBrowserProgressView *)progressView {
    if (!_progressView) {
        _progressView = [YMImageBrowserProgressView new];
    }
    return _progressView;
}

- (UIImageView *)tailoringImageView {
    if (!_tailoringImageView) {
        _tailoringImageView = [UIImageView new];
        _tailoringImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _tailoringImageView;
}


@end
