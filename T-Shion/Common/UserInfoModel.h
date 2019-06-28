//
//  UserInfoModel.h
//  T-Shion
//
//  Created by 王四的mac air on 2018/3/23.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddressModel;

@interface UserInfoModel : NSObject

@property (copy, nonatomic) NSString *avatar;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *mobile;

@property (nonatomic, copy) NSString *dialCode;

@property (assign, nonatomic) int sex;//0 man 1 woman

@property (copy, nonatomic) NSString *ID;

@property (copy, nonatomic) NSString *introduce;

@property (copy, nonatomic) NSString *address;

@property (nonatomic, copy) NSString *region;

@property (copy, nonatomic) NSString *refreshToken;

@property (copy, nonatomic) NSString *token;

- (void)outLoginCleanInfomation;
@end


