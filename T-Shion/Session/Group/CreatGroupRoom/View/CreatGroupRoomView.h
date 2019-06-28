//
//  CreatGroupRoomView.h
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"

@class CreatGroupRoomViewModel;

@interface CreatGroupRoomView : BaseView<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) CreatGroupRoomViewModel *viewModel;
@property (strong, nonatomic) BaseTableView *table;
@property (strong, nonatomic) UIView *headView;
@end
