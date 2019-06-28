//
//  LookingForPwdViewController.h
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "LookingForViewModel.h"
#import "RegisterViewController.h"

@interface LookingForPwdViewController : BaseViewController

@property (strong, nonatomic) LookingForViewModel *viewModel;
@property (nonatomic, weak) id <RegisterViewControllerDelegate> delegate;

@end
