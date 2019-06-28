//
//  YMEncryptionUserModel.h
//  SecureTest
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Curve25519Kit/Curve25519.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMEncryptionUserModel : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, strong) ECKeyPair *identity;
@property (nonatomic, assign) int nextPrekeyId;
@property (nonatomic, assign) int currentSignedPrekeyId;
@property (nonatomic, assign) BOOL isSaveIdentity;

@end

NS_ASSUME_NONNULL_END
