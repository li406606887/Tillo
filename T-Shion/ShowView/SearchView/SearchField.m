//
//  SearchField.m
//  AilloTest
//
//  Created by together on 2019/3/28.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "SearchField.h"

@implementation SearchField
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor ALGrayBgColor];
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        self.font = [UIFont systemFontOfSize:15];
        self.placeholder = Localized(@"search_placeholder");
        self.returnKeyType = UIReturnKeySearch;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIImageView *searchIconView = [self getSearchIconView];
        searchIconView.center = leftView.center;
        [leftView addSubview:searchIconView];
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ALGrayBgColor];
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        self.font = [UIFont systemFontOfSize:15];
        self.returnKeyType = UIReturnKeySearch;
        self.placeholder = Localized(@"search_placeholder");
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIImageView *searchIconView = [self getSearchIconView];
        searchIconView.center = leftView.center;
        [leftView addSubview:searchIconView];
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
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
- (UIImageView *)getSearchIconView {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_search"]];
}
@end
