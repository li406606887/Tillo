//
//  LookForFileMainView.m
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForFileMainView.h"
#import "LookForFileSegmentView.h"
#import "LookForFileView.h"
#import "LookForAssetView.h"
#import "LookForFileViewModel.h"

@interface LookForFileMainView ()<UIScrollViewDelegate>
@property (weak, nonatomic) LookForFileViewModel *viewModel;
@property (strong, nonatomic) LookForFileSegmentView *segmentView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) LookForAssetView *assetView;
@property (strong, nonatomic) LookForFileView *fileView;
@end

@implementation LookForFileMainView
- (instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (LookForFileViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    [self addSubview:self.segmentView];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.assetView];
    [self.scrollView addSubview:self.fileView];
}

- (void)layoutSubviews {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentView.mas_bottom);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, self.height- 40));
    }];
    
    [self.assetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView);
        make.centerY.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
        make.width.offset(SCREEN_WIDTH);
    }];
    
    [self.fileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.assetView.mas_right);
        make.centerY.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
        make.width.offset(SCREEN_WIDTH);
    }];
    [super layoutSubviews];
}

- (void)bindViewModel {
    
}

#pragma mark scroll delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        long index = scrollView.contentOffset.x==SCREEN_WIDTH ? 1: 0;
        [self.segmentView setSegmentIndex:index];
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0.1f);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (LookForFileSegmentView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[LookForFileSegmentView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        @weakify(self)
        _segmentView.clickBlock = ^(long index) {
            @strongify(self)
            [self.scrollView setContentOffset:CGPointMake(index*SCREEN_WIDTH, 0) animated:YES];
        };
    }
    return _segmentView;
}

- (LookForAssetView *)assetView {
    if (!_assetView) {
        _assetView = [[LookForAssetView alloc] initWithViewModel:self.viewModel];
        _assetView.backgroundColor = [UIColor redColor];
    }
    return _assetView;
}

- (LookForFileView *)fileView {
    if (!_fileView) {
        _fileView = [[LookForFileView alloc] initWithViewModel:self.viewModel];
        _fileView.backgroundColor = [UIColor greenColor];
    }
    return _fileView;
}
@end
