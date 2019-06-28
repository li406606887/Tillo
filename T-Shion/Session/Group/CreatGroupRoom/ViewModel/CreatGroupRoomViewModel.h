//
//  CreatGroupRoomViewModel.h
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface CreatGroupRoomViewModel : BaseViewModel
@property (strong, nonatomic) RACCommand *creatGroupCommand;

@property (strong, nonatomic) RACSubject *creatSuccessSubject;

@property (copy, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableArray *indexArray;

@property (weak, nonatomic) NSMutableArray *memberArray;

@property (copy, nonatomic) NSString *groupID;

//是否创建加密群聊
@property (nonatomic, assign) BOOL isCrypt;
@end
