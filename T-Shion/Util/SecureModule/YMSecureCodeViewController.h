//
//  YMSecureCodeViewController.h
//  T-Shion
//
//  Created by mac on 2019/4/12.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMSecureCodeViewController : BaseViewController

- (instancetype)initWithMyID:(NSString*)myUserID myIdentity:(NSData*)myIdentity theirUserID:(NSString*)theirUserID theirIdentity:(NSData*)theirIdentityKey theirNickName:(NSString*)theirNickName;

@end

NS_ASSUME_NONNULL_END
