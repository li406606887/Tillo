//
//  LookImageDetailsView.m
//  T-Shion
//
//  Created by together on 2018/12/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LookImageDetailsView.h"
#import "PhotoBrowseCell.h"
#import "PhotoBrowseModel.h"

static NSString *ID = @"PhotoBrowseCell";

@interface LookImageDetailsView() <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
/** 模型数组 */
@property(nonatomic, strong) NSMutableArray *photoBrowseModelArr;
/** 当前显示的Index */
@property(nonatomic, assign) NSInteger currentIndex;
/** 当前的image */
@property(nonatomic, strong) UIImage *currentImage;
/** 当前indexPath */
@property(nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation LookImageDetailsView

- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)photosArr currentIndex:(NSInteger)currentIndex {
    if (self = [super initWithFrame:frame]) {
        for (MessageModel *message in photosArr) {
            PhotoBrowseModel *model = [PhotoBrowseModel photoBrowseModelWith:message];
            [self.photoBrowseModelArr addObject:model];
        }
        [self addChildView];
        self.currentIndex = currentIndex;
    }
    return self;
}

- (void)addChildView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - shareView event
- (void)tapSaveLocalLabel {
    if (self.currentImage) {
        UIImageWriteToSavedPhotosAlbum(self.currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        ShowWinMessage(@"保存失败")
    } else {
        ShowWinMessage(@"已保存到相册");
    }
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoBrowseModelArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.model = self.photoBrowseModelArr[indexPath.row];
//    __weak typeof(self) weakSelf = self;
    cell.singleTapGestureBlock = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MBProgressHUD getCurrentUIVC] dismissViewControllerAnimated:YES completion:nil];
        });
    };
    self.currentImage = cell.browseView.imageView.image;
    self.currentIndexPath = indexPath;
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[PhotoBrowseCell class]]) {
        [(PhotoBrowseCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[PhotoBrowseCell class]]) {
        [(PhotoBrowseCell *)cell recoverSubviews];
    }
}
#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //设置页码Label
//    NSInteger page = scrollView.contentOffset.x / (self.pf_width + 20);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.width + 20, self.height);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.width + 20, self.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(0, 0);
        _collectionView.contentSize = CGSizeMake(self.photoBrowseModelArr.count * (self.width + 20), 0);
        [_collectionView registerClass:[PhotoBrowseCell class] forCellWithReuseIdentifier:ID];
    }
    return _collectionView;
}

- (NSMutableArray *)photoBrowseModelArr {
    if (!_photoBrowseModelArr) {
        _photoBrowseModelArr = [NSMutableArray array];
    }
    return _photoBrowseModelArr;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
