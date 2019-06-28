//
//  MyFriendViewController.h
//  T-Shion
//
//  Created by together on 2018/6/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendsViewModel.h"

@interface MyFriendViewController : BaseViewController<UISearchBarDelegate>
@property (strong, nonatomic) FriendsViewModel *viewModel;
@end
