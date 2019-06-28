//
//  ALSearchView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALSearchView;

@protocol ALSearchVeiwDelegate <NSObject>

@optional
- (void)al_didCancelButtonClick;
- (void)al_didSearchButtonClick:(NSString *)searchText;

- (void)searchview:(ALSearchView *)searchView didSearchTextChange:(NSString *)searchText;

@end

@interface ALSearchView : UIView

@property (nonatomic, strong) UITextField *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, assign) CGFloat placeholderFont;

@property (nonatomic, assign) BOOL cancelBtnAlways;

@property (nonatomic, weak) id <ALSearchVeiwDelegate>delegate;

@end

