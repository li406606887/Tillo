//
//  SelectFriendViewModel.h
//  T-Shion
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectFriendViewModel : BaseViewModel

//好友数组
@property (nonatomic, strong) NSArray *friendsArray;

//排序分组后的好友数组
@property (nonatomic, strong) NSMutableArray *dataArray;

//索引数组
@property (nonatomic, strong) NSMutableArray *indexArray;

@property (nonatomic, strong) RACSubject *sendMessageClickSubject;

@end

NS_ASSUME_NONNULL_END
