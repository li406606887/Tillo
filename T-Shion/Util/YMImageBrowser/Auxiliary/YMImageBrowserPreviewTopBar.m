//
//  YMImageBrowserPreviewTopBar.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/23.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowserPreviewTopBar.h"
#import "YMIBUtilities.h"
#import "YMImageBrowserToolBarProtocol.h"

static CGFloat kTopBarDefaultsHeight = 60.0;

@interface YMImageBrowserPreviewTopBar ()

@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation YMImageBrowserPreviewTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backButton];
        [self addSubview:self.indexLabel];
        self.backgroundColor = [UIColor colorWithRed:0  green:0  blue:0 alpha:0.8];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat hExtra = 0;
    if (YMIB_IS_IPHONEX && [UIScreen mainScreen].bounds.size.height < [UIScreen mainScreen].bounds.size.width) hExtra += YMIB_HEIGHT_EXTRABOTTOM;
    
    self.backButton.frame = CGRectMake(10 + hExtra, self.bounds.size.height - kTopBarDefaultsHeight, kTopBarDefaultsHeight, kTopBarDefaultsHeight);
    
    self.indexLabel.frame = CGRectMake(self.bounds.size.width - 45, (self.bounds.size.height - 30)/2, 30, 30);
    [super layoutSubviews];
}

#pragma mark - public

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize {
    CGFloat height = kTopBarDefaultsHeight;
    if (containerSize.height > containerSize.width && YMIB_IS_IPHONEX) height += YMIB_HEIGHT_STATUSBAR;
    return CGRectMake(0, 0, containerSize.width, height);
}


#pragma mark - event
- (void)backBtnClick:(UIButton *)btn {
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ym_imageBrowserPreviewTopBar:clickBackButton:)]) {
        [self.delegate ym_imageBrowserPreviewTopBar:self clickBackButton:btn];
    }
}

#pragma mark - YMImageBrowserToolBarProtocol
- (void)ym_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YMImageBrowserCellDataProtocol>)data {
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)(pageIndex + 1)];
//    if (totalPage <= 1) {
//        self.indexLabel.hidden = YES;
//    } else {
//        self.indexLabel.hidden  = NO;
////        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)(pageIndex + 1), (unsigned long)totalPage];
//        
//        self.indexLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)(pageIndex + 1)];
//    }
}

- (void)ym_browserUpdateLayoutWithDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    self.frame = [self getFrameWithContainerSize:containerSize];
}

#pragma mark - getter
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"ymib_cancel"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.backgroundColor = [UIColor colorWithRed:95/255.0 green:206/255.0 blue:173/255.0 alpha:1];
    
        _indexLabel.layer.masksToBounds = YES;
        _indexLabel.layer.cornerRadius = 15;
        _indexLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _indexLabel;
}

@end
