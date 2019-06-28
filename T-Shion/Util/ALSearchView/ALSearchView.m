//
//  ALSearchView.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALSearchView.h"

@interface ALSearchView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *searchIconView;

@end


@implementation ALSearchView

- (instancetype)init {
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    [self addSubview:self.searchBar];
    [self addSubview:self.cancelButton];
}

//适配ios 11
- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREEN_WIDTH - 30, 30);
}

- (void)updateConstraints {
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(self.mas_centerY);
        if (self.cancelButton.hidden) {
            make.width.mas_equalTo(0);
        } else {
            make.width.mas_equalTo(50);
        }
        make.height.mas_equalTo(30);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self.cancelButton.mas_left).with.offset(-10);
    }];
    
    [super updateConstraints];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.cancelBtnAlways) {
        return YES;
    }
    
    self.cancelButton.hidden = NO;
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(al_didSearchButtonClick:)]) {
        [_delegate al_didSearchButtonClick:textField.text];
    }
//    [textField resignFirstResponder];
    return YES;
}


#pragma mark - getter and setter
- (UITextField *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UITextField alloc] init];
        _searchBar.backgroundColor = [UIColor ALGrayBgColor];
        _searchBar.delegate = self;
        _searchBar.layer.cornerRadius = 15;
//        _searchBar.layer.borderWidth = 1;
//        _searchBar.layer.borderColor = [UIColor ALLineColor].CGColor;
        _searchBar.layer.masksToBounds = YES;
        _searchBar.font = [UIFont systemFontOfSize:15];
        _searchBar.returnKeyType = UIReturnKeySearch;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.searchIconView.center = leftView.center;
        [leftView addSubview:self.searchIconView];
        _searchBar.leftView = leftView;
        _searchBar.leftViewMode = UITextFieldViewModeAlways;
        
        @weakify(self);
        [_searchBar.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(searchview:didSearchTextChange:)]) {
                [self.delegate searchview:self didSearchTextChange:x];
            }
        }];
    }
    return _searchBar;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:Localized(@"Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor ALKeyColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont ALFontSize15];
        _cancelButton.hidden = YES;
        @weakify(self);
        [[_cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(al_didCancelButtonClick)]) {
                [self.delegate al_didCancelButtonClick];
            }
            
            if (self.cancelBtnAlways) {
                [self.searchBar resignFirstResponder];
                return;
            }
            
            self.cancelButton.hidden = YES;
            [self.cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(0);
            }];
        }];
    }
    return _cancelButton;
}

- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_search"]];
    }
    return _searchIconView;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _searchBar.placeholder = placeholder;
}

- (void)setPlaceholderFont:(CGFloat)placeholderFont {
    _placeholderFont = placeholderFont;
    [_searchBar setValue:[UIFont systemFontOfSize:placeholderFont] forKeyPath:@"_placeholderLabel.font"];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [_searchBar setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)setCancelBtnAlways:(BOOL)cancelBtnAlways {
    _cancelButton.hidden = !cancelBtnAlways;
}


@end

