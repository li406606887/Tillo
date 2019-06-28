//
//  AddFriendsModel.h
//  T-Shion
//
//  Created by together on 2018/4/13.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddFriendsModel : NSObject
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *roomId;
@property (nonatomic,copy) NSString *sex;// 0 是男 1是女
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *region;
@property (nonatomic,copy) NSString *city;
@property (nonatomic,copy) NSString *district;
@property (copy, nonatomic) NSString *introduce;

@property (copy, nonatomic) NSString *requestId;//请求ID




@end
