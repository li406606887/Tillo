//
//  BlackUserViewModel.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/7.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface BlackUserViewModel : BaseViewModel

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSIndexPath *editIndexPath;

@property (nonatomic, strong) RACCommand *loadDataCommand;
@property (nonatomic, strong) RACCommand *removeCommand;

@property (nonatomic, strong) RACSubject *refreshEndSubject;
@property (nonatomic, strong) RACSubject *removeEndSubject;

@property (nonatomic, strong) RACSubject *cellClickSubject;

@end

