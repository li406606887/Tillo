//
//  BaseTableView.m
//  T-Shion
//
//  Created by together on 2018/6/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        if (@available(iOS 11.0, *)) {
            self.estimatedRowHeight = 0.f;
            self.estimatedSectionFooterHeight = 0.f;
            self.estimatedSectionHeaderHeight = 0.f;
            self.sectionIndexColor = [UIColor ALKeyColor];
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchBackgroud)];
            tapGestureRecognizer.cancelsTouchesInView = NO;
            [self addGestureRecognizer:tapGestureRecognizer];
        }
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchBackgroud {
    if (self.touchBeginBlock) {
        self.touchBeginBlock();
    }
}

@end
