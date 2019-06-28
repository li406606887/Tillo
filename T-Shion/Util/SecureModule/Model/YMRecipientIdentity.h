//
//  YMRecipientIdentity.h
//  SecureTest
//
//  Created by mac on 2019/4/1.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YMVerificationState) {
    YMVerificationStateDefault = 0,
    YMVerificationStateVerified,
    YMVerificationStateNoLongerVerified,
};

@interface YMRecipientIdentity : NSObject<NSCoding>

@property (nonatomic, readonly) NSString *recipientId;
@property (nonatomic, readonly) NSData *identityKey;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) BOOL isFirstKnownKey;


#pragma mark - Verification State

@property (atomic, readonly) YMVerificationState verificationState;

- (void)updateWithVerificationState:(YMVerificationState)verificationState;

#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)coder;

- (instancetype)initWithRecipientId:(NSString *)recipientId
                        identityKey:(NSData *)identityKey
                    isFirstKnownKey:(BOOL)isFirstKnownKey
                          createdAt:(NSDate *)createdAt
                  verificationState:(YMVerificationState)verificationState;

+ (nullable instancetype)fetchObjectWithUniqueID:(NSString *)uniqueID;

- (BOOL)store;

- (BOOL)update;

@end

NS_ASSUME_NONNULL_END
