//
//  LoginModel.h
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginModel : NSObject
@property (copy, nonatomic) NSString *token;

@property (copy, nonatomic) NSString *refreshToken;


//- (void)outLoginCleanInfomation;

@end
