//
//  MineView.h
//  T-Shion
//
//  Created by together on 2018/6/15.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "MineHeadView.h"
#import "MineViewModel.h"

@interface MineView : BaseView<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) BaseTableView *table;
@property (strong, nonatomic) MineHeadView *headView;
@property (strong, nonatomic) MineViewModel *viewModel;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *iconArray;
@end
