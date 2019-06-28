//
//  MineHeadView.h
//  T-Shion
//
//  Created by together on 2018/6/15.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "MineViewModel.h"

@interface MineHeadView : BaseView
@property (strong, nonatomic) UIImageView *headBack;
@property (strong, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UILabel *nickName;
@property (strong, nonatomic) MineViewModel *viewModel;
@property (strong, nonatomic) UIImage *defaultImage;
@end
