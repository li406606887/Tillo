//
//  YMIdentityManager.h
//  SecureTest
//
//  Created by mac on 2019/4/1.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBManager.h"
#import <Curve25519Kit/Curve25519.h>
#import "IdentityKeyStore.h"
#import "YMRecipientIdentity.h"

NS_ASSUME_NONNULL_BEGIN

// This notification will be fired whenever identities are created
// or their verification state changes.
extern NSString *const kNSNotificationName_IdentityStateDidChange;

// number of bytes in a signal identity key, excluding the key-type byte.
extern const NSUInteger kIdentityKeyLength;

#ifdef DEBUG
extern const NSUInteger kStoredIdentityKeyLength;
#endif

@interface YMIdentityManager : NSObject <IdentityKeyStore>

+ (instancetype)sharedManager;

- (ECKeyPair *)identityWithUserId:(nullable NSString*)userId;

- (nullable YMRecipientIdentity *)recipientIdentityForRecipientId:(NSString *)recipientId;

- (YMVerificationState)verificationStateForRecipientId:(NSString *)recipientId;

- (void)setVerificationState:(YMVerificationState)verificationState
                 identityKey:(NSData *)identityKey
                 recipientId:(NSString *)recipientId
       isUserInitiatedChange:(BOOL)isUserInitiatedChange;


//获取是否上传key成功了
- (BOOL)isUploadedPublicKey;
//设置上传key成功或失败
- (void)setUploadPublicKey:(BOOL)success;
@end

NS_ASSUME_NONNULL_END

