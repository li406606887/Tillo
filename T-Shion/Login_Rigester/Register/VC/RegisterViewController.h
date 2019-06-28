//
//  RegisterViewController.h
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "RegisterViewModel.h"

@protocol RegisterViewControllerDelegate <NSObject>

@optional
- (void)didAutoLoginSuccess;

@end


@interface RegisterViewController : BaseViewController

@property (nonatomic, weak) id <RegisterViewControllerDelegate> delegate;
@property (strong, nonatomic) RegisterViewModel *viewModel;

@end
