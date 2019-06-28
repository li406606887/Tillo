//
//  SendCardViewModel.h
//  AilloTest
//
//  Created by together on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SendCardViewModel : BaseViewModel
@property (strong, nonatomic) RACSubject *clickSubject;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *indexArray;
@property (strong, nonatomic) NSArray *array;
@property (copy, nonatomic) NSString *uid;    
@end

NS_ASSUME_NONNULL_END
