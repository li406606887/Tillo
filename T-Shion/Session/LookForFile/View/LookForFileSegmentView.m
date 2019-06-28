//
//  LookForFileSegmentView.m
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForFileSegmentView.h"

@interface LookForFileSegmentView ()

/**
 图片和视频按钮
 */
@property (strong, nonatomic) UIButton *assetButton;
/**
 文件按钮
 */
@property (strong, nonatomic) UIButton *fileButton;
/**
 滑动块
 */
@property (strong, nonatomic) UIView *lineBlock;
@end

@implementation LookForFileSegmentView
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addChildView];
    }
    return self;
}

- (void)addChildView {
    [self addSubview:self.lineBlock];
    [self addSubview:self.assetButton];
    [self addSubview:self.fileButton];
}

- (void)layoutSubviews {
    [self.assetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH*0.5, self.height));
    }];
    
    [self.fileButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH*0.5, self.height));
    }];
    
    [self.lineBlock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.assetButton);
        make.bottom.equalTo(self.mas_bottom);
        make.size.mas_offset(CGSizeMake(20, 3));
    }];
    [super layoutSubviews];
}
#pragma mark thod
/**
 设置滑动位置
 @param index 位置
 */
- (void)setSegmentIndex:(long)index {
    [self setDisplayUIIndex:index];
}
#pragma mark lazy loading
- (UIView *)lineBlock {
    if (!_lineBlock) {
        _lineBlock = [[UIView alloc] init];
        _lineBlock.backgroundColor = RGB(80, 209, 172);
    }
    return _lineBlock;
}

- (UIButton *)assetButton {
    if (!_assetButton) {
        _assetButton = [self creatButtonWithTitle:Localized(@"lookFor_msg_asset") tag:0];
        _assetButton.selected = YES;
    }
    return _assetButton;
}

- (UIButton *)fileButton {
    if (!_fileButton) {
        _fileButton = [self creatButtonWithTitle:Localized(@"lookFor_msg_file") tag:1];
    }
    return _fileButton;
}

- (UIButton *)creatButtonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTag:tag];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:15];
    [btn setTitleColor:RGB(102, 102, 102) forState:UIControlStateNormal];
    [btn setTitleColor:RGB(80, 209, 172) forState:UIControlStateSelected];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self clickButtonWithTag:x.tag];
    }];
    return btn;
}

- (void)clickButtonWithTag:(long )tag {
    [self setDisplayUIIndex:tag];
    if (self.clickBlock) {
        self.clickBlock(tag);
    }
}

- (void)setDisplayUIIndex:(long)index {
    switch (index) {
        case 0: {
            [UIView animateWithDuration:0.25 animations:^{
                self.lineBlock.centerX = self.assetButton.centerX;
            }];
            self.assetButton.selected = YES;
            self.fileButton.selected = NO;
        }
            break;
            
        case 1: {
            [UIView animateWithDuration:0.25 animations:^{
                self.lineBlock.centerX = self.fileButton.centerX;
            }];
            self.fileButton.selected = YES;
            self.assetButton.selected = NO;
        }
            break;
            
        default:
            break;
    }
}
@end
