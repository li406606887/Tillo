//
//  FriendsValidationModel.h
//  T-Shion
//
//  Created by together on 2018/3/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsValidationModel : NSObject
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *mobile;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *remark;
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *requestId;//请求ID
@property (assign, nonatomic) int status;//0 待添加好友  1 已通过申请
@property (strong, nonatomic) FriendsModel *user;
@end
