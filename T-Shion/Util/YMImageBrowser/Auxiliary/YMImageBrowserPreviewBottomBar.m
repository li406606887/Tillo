//
//  YMImageBrowserPreviewBottomBar.m
//  YMImageBrowserDemo
//
//  Created by 与梦信息的Mac on 2019/5/23.
//  Copyright © 2019年 与梦信息技术有限公司. All rights reserved.
//

#import "YMImageBrowserPreviewBottomBar.h"
#import "YMIBUtilities.h"

static CGFloat kBottomBarDefaultsHeight = 60.0;

@interface YMImageBrowserPreviewBottomBar ()
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation YMImageBrowserPreviewBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.sendButton];

        self.backgroundColor = [UIColor colorWithRed:0  green:0  blue:0 alpha:0.8];
    }
    return self;
}

- (void)layoutSubviews {
    self.sendButton.frame = CGRectMake(self.bounds.size.width - 100, (self.bounds.size.height - 30)/2, 80, 30);
    
    [super layoutSubviews];
}

#pragma mark - event
- (void)sendBtnClick:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ym_imageBrowserPreviewBottomBar:clickSendButton:)]) {
        [self.delegate ym_imageBrowserPreviewBottomBar:self clickSendButton:btn];
    }
}

#pragma mark - public

- (CGRect)getFrameWithContainerSize:(CGSize)containerSize {
    CGFloat height = kBottomBarDefaultsHeight + YMIB_HEIGHT_EXTRABOTTOM;
    return CGRectMake(0, containerSize.height - height, containerSize.width, height);
}

#pragma mark - YMImageBrowserToolBarProtocol
- (void)ym_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YMImageBrowserCellDataProtocol>)data {
    [_sendButton setTitle:[NSString stringWithFormat:@"发送(%ld)", (unsigned long)(totalPage)] forState:UIControlStateNormal];
}

- (void)ym_browserUpdateLayoutWithDirection:(YMImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    self.frame = [self getFrameWithContainerSize:containerSize];
}


#pragma mark - getter
- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = [UIColor colorWithRed:95/255.0 green:206/255.0 blue:173/255.0 alpha:1];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 5;
    }
    return _sendButton;
}


@end
