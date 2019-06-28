//
//  LookAvatarViewController.m
//  AilloTest
//
//  Created by together on 2019/2/25.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookAvatarViewController.h"

@interface LookAvatarViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIImage *avatarImage;
@property (copy, nonatomic) NSString *avatarUrl;
@end

@implementation LookAvatarViewController
- (instancetype)initWithImage:(UIImage *)image url:(NSString *)url {
    self = [super init];
    if (self) {
        self.avatarImage = image;
        self.avatarUrl = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageContainerView];
    [self.imageContainerView addSubview:self.avatarView];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self.view addGestureRecognizer:tap2];
    
    [self recoverSubviews];
}

- (void)recoverSubviews {
    [self.scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    self.imageContainerView.origin = CGPointZero;
    self.imageContainerView.width = self.scrollView.width;
    
    UIImage *image = self.avatarView.image;
    if (image.size.height / image.size.width > SCREEN_HEIGHT / self.scrollView.width) {
        self.imageContainerView.height = floor(image.size.height / (image.size.width / self.scrollView.width));
    } else{
        CGFloat height = image.size.height / image.size.width * self.scrollView.width;
        if (height < 1 || isnan(height)) height = SCREEN_HEIGHT;
        height = floor(height);
        self.imageContainerView.height = height;
        self.imageContainerView.centerY = SCREEN_HEIGHT / 2;
    }
    if (self.imageContainerView.height > SCREEN_HEIGHT && self.imageContainerView.height - SCREEN_HEIGHT <= 1) {
        self.imageContainerView.height = SCREEN_HEIGHT;
    }
    CGFloat contentSizeH = MAX(self.imageContainerView.height, SCREEN_HEIGHT);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, contentSizeH);
    [self.scrollView scrollRectToVisible:self.view.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.imageContainerView.height <= SCREEN_HEIGHT ? NO : YES;
    self.avatarView.frame = _imageContainerView.bounds;
    
    [self refreshScrollViewContentSize];
}

#pragma mark - UITapGestureRecognizer Event
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > 1.0) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else{
        CGPoint touchPoint = [tap locationInView:self.avatarView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = SCREEN_WIDTH / newZoomScale;
        CGFloat ysize = SCREEN_HEIGHT / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollViewContentSize];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (self.scrollView.width > self.scrollView.contentSize.width) ? ((self.scrollView.width - self.scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (self.scrollView.height > self.scrollView.contentSize.height) ? ((self.scrollView.height - self.scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)refreshScrollViewContentSize {
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIView *)imageContainerView {
    if (!_imageContainerView) {
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageContainerView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
    }
    return _scrollView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = [UIColor blackColor];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        _avatarView.image = self.avatarImage;
    }
    return _avatarView;
}

@end
