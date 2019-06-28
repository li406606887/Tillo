//
//  PhotoBrowseCell.m
//  BGH-family
//
//  Created by Sunny on 17/2/24.
//  Copyright © 2017年 Zontonec. All rights reserved.
//

#import "PhotoBrowseCell.h"
#import "PhotoBrowseModel.h"
#import "UIImageView+WebCache.h"
#import "TSImageHandler.h"
#import "UIImageView+YMAnimatedImageView.h"

@implementation PhotoBrowseCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.browseView = [[PhotoBrowseView alloc] initWithFrame:self.bounds];
        __weak typeof(self) weakSelf = self;
        self.browseView.singleTapGestureBlock = ^(){
            if (weakSelf.singleTapGestureBlock) {
                weakSelf.singleTapGestureBlock();
            }
        };
        [self addSubview:self.browseView];
    }
    return self;
}

- (void)setModel:(PhotoBrowseModel *)model {
    self.browseView.model = model;
}

- (void)recoverSubviews {
    [self.browseView recoverSubviews];
}


@end


@interface PhotoBrowseView() <UIScrollViewDelegate>

@end

@implementation PhotoBrowseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.frame = CGRectMake(10, 0, self.width - 20, self.height);
        self.scrollView.bouncesZoom = YES;
        self.scrollView.maximumZoomScale = 2.5;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.multipleTouchEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.delaysContentTouches = NO;
        self.scrollView.canCancelContentTouches = YES;
        self.scrollView.alwaysBounceVertical = NO;
        [self addSubview:self.scrollView];
        
        self.imageContainerView = [[UIView alloc] init];
        self.imageContainerView.clipsToBounds = YES;
        self.imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.imageContainerView];
        
        self.imageView = [[SDAnimatedImageView alloc] init];
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.imageContainerView addSubview:self.imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
        UILongPressGestureRecognizer *longPG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [self addGestureRecognizer:longPG];
    }
    return self;
}

- (void)setModel:(PhotoBrowseModel *)model {
    _model = model;
    if (model.isGIF) {
        [self loadGifImageWith:model];
        return;
    }
    
    if (model.type == NoImageType) {
        [self loadingBigImageWithUrl:model.URL placeholder:nil];
    } else if (model.type == SmallImageType) {
        [self loadingBigImageWithUrl:model.URL placeholder:model.small];
    } else if (model.type == BigImageType) {
        [self.imageView setImage:model.big];
        if (model.message.sendType == OtherSender) {
            [self saveImageToAillo:model.big withBigImage:model.message.fileName withAssetPath:model.message.bigImage];
        }
//        if ([model.big isKindOfClass:[FLAnimatedImage class]]) {
//            self.imageView.animatedImage = (FLAnimatedImage*)model.big;
//
//            NSString *folder = [FMDBManager getMessagePathWithMessage:self.model.message];
//            NSString *path = [folder stringByAppendingPathComponent:model.message.fileName];
//            if (model.message.sendType == OtherSender) {
//                [self saveImageToAillo:path withBigImage:model.message.fileName withAssetPath:model.message.bigImage];
//            }
//        } else {
//            [self.imageView setImage:model.big];
//            if (model.message.sendType == OtherSender) {
//                [self saveImageToAillo:model.big withBigImage:model.message.fileName withAssetPath:model.message.bigImage];
//            }
//        }
    }
}

- (void)loadGifImageWith:(PhotoBrowseModel *)model {
    NSString *path = [[FMDBManager getMessagePathWithMessage:model.message] stringByAppendingPathComponent:model.message.fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
//    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
//    self.imageView.animatedImage = image;
    self.imageView.image = [SDAnimatedImage sd_imageWithGIFData:data];
    
    NSString *bigImageName;
    if (model.message.bigImage.length > 0) {
        bigImageName = model.message.bigImage;
    } else {
        bigImageName = [NSString stringWithFormat:@"image_big_%@.gif",[NSUUID UUID].UUIDString];
    }
    
    if (model.message.sendType == OtherSender) {
        [self saveImageToAillo:path withBigImage:bigImageName withAssetPath:model.message.bigImage];
    }
}

- (void)loadingBigImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholder {
    
    @weakify(self)
    
    [self.imageView ym_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"%ld----%ld",(long)receivedSize,(long)expectedSize);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        @strongify(self)
        if (error==nil) {
            
            NSString *folder = [FMDBManager getMessagePathWithMessage:self.model.message];
            NSString *bigImage = nil;
//            NSData *data = nil;
            BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:data];
            
            if (isGif) {
                bigImage = [NSString stringWithFormat:@"image_big_%@.gif",[NSUUID UUID].UUIDString];
//                data = self.imageView.animatedImage.data;
            }
            else {
                bigImage = [NSString stringWithFormat:@"image_big_%@.jpg",[NSUUID UUID].UUIDString];
//                data = UIImageJPEGRepresentation(image, 1);
            }
            if (data.length < 1)
                return;
            NSString *path = [folder stringByAppendingPathComponent:bigImage];
            
            BOOL result = [data writeToFile:path atomically:YES];
            NSString *assetName = [self saveImageToAillo:path withBigImage:bigImage withAssetPath:nil];
            
            if (result) {
                self.model.message.bigImage = assetName; //保存到相册后存相册地址
                self.model.type = BigImageType;
                self.model.big = image;
                [self recoverSubviews];
            }
        }
    }];
}

- (NSString*)saveImageToAillo:(id)image withBigImage:(NSString*)bigImageName withAssetPath:(NSString*)assetPath
{
    if (assetPath && assetPath.length > 0)  //图片已经保存过了的处理
    {
        if ([TSImageHandler phAssetsIsExist:assetPath])//图片还在相册，不重复保存
            return assetPath;
    }
    NSString *assetName = [TSImageHandler saveImageToAlbum:image];
    [FMDBManager updateMessagBigImagePathWithRoomId:self.model.message.roomId messageId:self.model.message.messageId assetName:assetName fileName:bigImageName];
    return assetName;
}

- (void)recoverSubviews {
    [self.scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    self.imageContainerView.origin = CGPointZero;
    self.imageContainerView.width = self.scrollView.width;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.height / self.scrollView.width) {
        self.imageContainerView.height = floor(image.size.height / (image.size.width / self.scrollView.width));
    } else{
        CGFloat height = image.size.height / image.size.width * self.scrollView.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        self.imageContainerView.height = height;
        self.imageContainerView.centerY = self.height / 2;
    }
    
    if (self.imageContainerView.height > self.height && self.imageContainerView.height - self.height <= 1) {
        self.imageContainerView.height = self.height;
    }
    CGFloat contentSizeH = MAX(self.imageContainerView.height, self.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, contentSizeH);
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.imageContainerView.height <= self.height ? NO : YES;
    self.imageView.frame = _imageContainerView.bounds;
    
    [self refreshScrollViewContentSize];
}

#pragma mark - UITapGestureRecognizer Event
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > 1.0) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else{
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)longPg {
    if (longPg.state == UIGestureRecognizerStateBegan) {
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        NSData *imageData =UIImagePNGRepresentation(self.imageView.image);
        CIImage *ciImage = [CIImage imageWithData:imageData];
        NSArray *features = [detector featuresInImage:ciImage];
        if (features.count<1) {
            return;
        }
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"Identify_The_Qrcode") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addAction:[UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
        }]];
        
        [alertC addAction:[UIAlertAction actionWithTitle:Localized(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ShowViewMessage(scannedResult);
        }]];
        
        [[SocketViewModel getTopViewController] presentViewController:alertC animated:YES completion:nil];
    }
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

@end
