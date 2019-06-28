//
//  InviteFriendModel.h
//  T-Shion
//
//  Created by together on 2018/12/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InviteFriendModel : NSObject
@property (copy, nonatomic) NSString *familyName;
@property (copy, nonatomic) NSString *givenName;
@property (copy, nonatomic) NSString *phoneNo;
@property (copy, nonatomic) NSString *letter;//首字母
@end

NS_ASSUME_NONNULL_END
