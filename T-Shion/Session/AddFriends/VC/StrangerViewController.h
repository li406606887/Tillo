//
//  StrangerViewController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "AddFriendsModel.h"
#import "FriendsValidationViewModel.h"


@interface StrangerViewController : BaseViewController

@property (nonatomic, strong) AddFriendsModel *model;
@property (nonatomic, assign) BOOL isFromValidation;
@property (strong, nonatomic) FriendsValidationViewModel *viewModel;

@property (nonatomic, assign) BOOL isNavPop;

@end

