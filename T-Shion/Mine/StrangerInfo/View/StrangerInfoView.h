//
//  StrangerInfoView.h
//  T-Shion
//
//  Created by together on 2018/8/9.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "StrangerInfoViewModel.h"

@interface StrangerInfoView : BaseView
@property (strong, nonatomic) UILabel *name;

@property (strong, nonatomic) UIImageView *icon;

@property (strong, nonatomic) UIButton *addBtn;

@property (copy, nonatomic) MemberModel *model;

@property (strong, nonatomic) StrangerInfoViewModel *viewModel;

@end
