//
//  FriendsValidationViewModel.h
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"
#import "FriendsValidationModel.h"

@interface FriendsValidationViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *getValidationFriendCommand;

@property (strong, nonatomic) RACSubject *getValidationFriendSubject;

@property (strong, nonatomic) RACCommand *agreeCommand;

@property (strong, nonatomic) RACCommand *deleteRequestCommand;

@property (strong, nonatomic) RACSubject *agreeSubject;

@property (strong, nonatomic) FriendsModel *agreeModel;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableArray *sourceDataArray;

@property (strong, nonatomic) RequestTableModel *tableModel;

@property (strong, nonatomic) RACSubject *gotoSearchFriendSubject;

@property (strong, nonatomic) RACSubject *cellClickSubject;

@property (strong, nonatomic) RACSubject *deleteRequestSubject;


//@property (weak, nonatomic) FriendsValidationModel *friendValidationModel;
@end
