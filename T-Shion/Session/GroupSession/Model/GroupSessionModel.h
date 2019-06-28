//
//  GroupSessionModel.h
//  T-Shion
//
//  Created by together on 2018/7/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"

@interface GroupSessionModel : BaseViewModel
@property (copy, nonatomic) NSString *text;
@property (assign, nonatomic) int unReadCount;
@property (copy, nonatomic) NSString *timestamp;
@property (copy, nonatomic) NSString *roomId;
@property (copy, nonatomic) NSString *ID;
@property (strong, nonatomic) GroupModel *model;
@end
