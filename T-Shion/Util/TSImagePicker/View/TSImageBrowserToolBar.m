//
//  TSImageBrowserToolBar.m
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSImageBrowserToolBar.h"

@interface TSImageBrowserToolBar ()

@property (nonatomic, strong) UIButton *finishedButton;
@property (nonatomic, strong) UIButton *previewButton;

@property (nonatomic, copy) dispatch_block_t previewBlock;
@property (nonatomic, copy) dispatch_block_t finishedBlock;

@end

@implementation TSImageBrowserToolBar

- (instancetype)initWithFrame:(CGRect)frame barStyle:(UIBarStyle)barStyle {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.barStyle = barStyle;
        self.previewButton.hidden = self.barStyle == UIBarStyleBlack;
        [self addSubview:self.finishedButton];
        [self addSubview:self.previewButton];
    }
    return self;
}


- (void)layoutSubviews {
    NSArray *subViewArray = [self subviews];
    for (id view in subViewArray) {
        if ([view isKindOfClass:(NSClassFromString(@"_UIToolbarContentView"))]) {
            UIView *testView = view;
            testView.userInteractionEnabled = NO;
            [testView bringSubviewToFront:self.finishedButton];
        }
    }
    
    [self.finishedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self);
        make.size.mas_offset(CGSizeMake(80, 50));
    }];
    
    [self.previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.size.mas_offset(CGSizeMake(80, 50));
    }];
    
    [super layoutSubviews];
}

- (void)handleFinishedButtonWithBlock:(dispatch_block_t)block {
    if (block) {
        self.finishedBlock = block;
    }
}

- (void)handlePreviewButtonWithBlock:(dispatch_block_t)block {
    if (block) {
        self.previewBlock = block;
    }
}

- (void)resetSelectPhotosNumber:(NSInteger)number {
    if (number == 0) {
        _finishedButton.enabled = NO;
         _previewButton.enabled = NO;
        [_finishedButton setTitle:Localized(@"Send") forState:UIControlStateNormal];
    } else {
        _finishedButton.enabled= YES;
        _previewButton.enabled = YES;
        [_finishedButton setTitle:[NSString stringWithFormat:@"%@( %ld )",Localized(@"Send"),number] forState:UIControlStateNormal];
    }
}



#pragma mark - getter and setter
- (UIButton *)finishedButton {
    if (!_finishedButton) {
        _finishedButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [_finishedButton setTitle:Localized(@"Send") forState:UIControlStateNormal];
        [_finishedButton setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
        [_finishedButton setTitleColor:[UIColor ALTextGrayColor] forState:UIControlStateDisabled];
        _finishedButton.titleLabel.font = [UIFont systemFontOfSize:15];
        @weakify(self)
        [[_finishedButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            self.finishedButton.enabled = NO;
            if (self.finishedBlock) {
                self.finishedBlock();
            }
        }];
        
    }
    return _finishedButton;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previewButton setTitle:Localized(@"View") forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor ALTextGrayColor] forState:UIControlStateDisabled];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:15];        
        @weakify(self)
        [[_previewButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.previewBlock) {
                self.previewBlock();
                self.finishedButton.enabled = YES;
            }
        }];
        
    }
    return _previewButton;
}

@end
