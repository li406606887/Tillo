//
//  MyInfoView.h
//  T-Shion
//
//  Created by together on 2018/6/25.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "MyInfoViewModel.h"

@interface MyInfoView : BaseView<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *placeholderArray;
@property (weak, nonatomic) UIImageView *headIcon;
@property (strong, nonatomic) UIImage *uploadImage;
@property (weak, nonatomic) UILabel *sex;
@property (strong, nonatomic) MyInfoViewModel *viewModel;
@end
//birthdate    body    Date
//description    body    String
//name    body    String
//sex    body    Enum[String], 'M', 'F'
