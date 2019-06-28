//
//  YMRecipientIdentity.m
//  SecureTest
//
//  Created by mac on 2019/4/1.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YMRecipientIdentity.h"
#import "YMIdentityManager.h"
#import "FMDBManager+SessionStore.h"
#import "FMDBManager.h"

NSString *YMVerificationStateToString(YMVerificationState verificationState)
{
    switch (verificationState) {
        case YMVerificationStateDefault:
            return @"YMVerificationStateDefault";
        case YMVerificationStateVerified:
            return @"YMVerificationStateVerified";
        case YMVerificationStateNoLongerVerified:
            return @"YMVerificationStateNoLongerVerified";
    }
}

static NSString* const kCoderIdKey          = @"kCoderIdKey";
static NSString* const kCoderIdentityKey    = @"kCoderIdentityKey";
static NSString* const kCoderCreatedAtKey   = @"kCoderCreatedAtKey";
static NSString* const kCoderFirstKnowedKey = @"kCoderFirstKnowedKey";
static NSString* const kCoderVerifyStateKey = @"kCoderVerifyStateKey";

@interface YMRecipientIdentity ()

@property (atomic, assign) YMVerificationState verificationState;

@end

@implementation YMRecipientIdentity

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_recipientId forKey:kCoderIdKey];
    [aCoder encodeObject:_identityKey forKey:kCoderIdentityKey];
    [aCoder encodeObject:_createdAt forKey:kCoderCreatedAtKey];
    [aCoder encodeBool:_isFirstKnownKey forKey:kCoderFirstKnowedKey];
    [aCoder encodeInteger:_verificationState forKey:kCoderVerifyStateKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    if (self) {
        _recipientId = [aDecoder decodeObjectOfClass:[NSString class] forKey:kCoderIdKey];
        _identityKey = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderIdentityKey];
        _createdAt = [aDecoder decodeObjectOfClass:[NSDate class] forKey:kCoderCreatedAtKey];
        _isFirstKnownKey = [aDecoder decodeBoolForKey:kCoderFirstKnowedKey];
        _verificationState = [aDecoder decodeIntegerForKey:kCoderVerifyStateKey];
    }
    
    return self;
}

- (instancetype)initWithRecipientId:(NSString *)recipientId
                        identityKey:(NSData *)identityKey
                    isFirstKnownKey:(BOOL)isFirstKnownKey
                          createdAt:(NSDate *)createdAt
                  verificationState:(YMVerificationState)verificationState
{
    if (self = [super init]) {
        _recipientId = recipientId;
        _identityKey = identityKey;
        _isFirstKnownKey = isFirstKnownKey;
        _createdAt = createdAt;
        _verificationState = verificationState;
    }
    return self;
}

- (void)updateWithVerificationState:(YMVerificationState)verificationState {
    _verificationState = verificationState;
    [self store];
}

- (BOOL)store {
    __block BOOL ret = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        ret = [db executeUpdate:@"INSERT OR REPLACE INTO YMRecipientIdentity (recipientId, recipientIdentity) VALUES (?, ?)", self.recipientId, [NSKeyedArchiver archivedDataWithRootObject:self]];
    }];
    return ret;
}

- (BOOL)update {
    __block BOOL ret = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        ret = [db executeUpdate:@"UPDATE YMRecipientIdentity SET recipientIdentity = ? WHERE recipientId = ?", [NSKeyedArchiver archivedDataWithRootObject:self], self.recipientId];
    }];
    return ret;
}

+ (nullable instancetype)fetchObjectWithUniqueID:(NSString *)uniqueID {
    __block YMRecipientIdentity *recipientIdentity = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMRecipientIdentity WHERE recipientId=?", uniqueID, nil];
        while (result.next) {
            recipientIdentity = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"recipientIdentity"]];
        }
        [result close];
    }];
    return recipientIdentity;
}

@end
