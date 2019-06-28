//
//  AddFriendSearchView.m
//  T-Shion
//
//  Created by together on 2018/12/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddFriendSearchView.h"

@interface AddFriendSearchView ()<UITextFieldDelegate>

@end

@implementation AddFriendSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"%@",@(frame));
        [self addSubview:self.searchField];
//        @weakify(self)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            @strongify(self)
//            [self.searchField becomeFirstResponder];
//        });
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:textField.text forKey:@"mobile"];
    if (self.searchUserBlock) {
        self.searchUserBlock(param);
    }
    return YES;
}

- (UITextField *)searchField {
    if (!_searchField) {
        _searchField = [[UITextField alloc] initWithFrame:self.bounds];
        [_searchField setBackgroundColor:[UIColor whiteColor]];
        _searchField.placeholder = Localized(@"Phone_Number");
        _searchField.delegate = self;
        _searchField.font = [UIFont systemFontOfSize:15];
        _searchField.backgroundColor = RGB(238, 238, 238);
        _searchField.layer.masksToBounds = YES;
        _searchField.layer.cornerRadius = 18;
        _searchField.clearButtonMode = UITextFieldViewModeAlways;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 34)];
        UIImageView *search = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8.5, 18, 18)];
        [search setImage:[UIImage imageNamed:@"Dialogue_Search"]];
        [leftView addSubview:search];
        _searchField.leftView = leftView;
        _searchField.leftViewMode = UITextFieldViewModeAlways;
        _searchField.returnKeyType = UIReturnKeySearch;
        
    }
    return _searchField;
}

@end
