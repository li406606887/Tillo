//
//  FriendsViewModel.h
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface FriendsViewModel : BaseViewModel

@property (strong, nonatomic) RACSubject *setingClickSubject;

@property (strong, nonatomic) RACSubject *sendMessageClickSubject;

@property (strong, nonatomic) RACSubject *iconClickSubject;

@property (strong, nonatomic) RACSubject *validationClickSubject;

@property (strong, nonatomic) RACSubject *scrollSubject;

@property (copy, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableArray *indexArray;

@property (copy, nonatomic) NSString *groupID;
@end
