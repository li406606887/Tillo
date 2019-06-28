//
//  YMIdentityManager.m
//  SecureTest
//
//  Created by mac on 2019/4/1.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YMIdentityManager.h"
#import "YMRecipientIdentity.h"
#import "YMEncryptionUserModel.h"
#import "FMDBManager+SessionStore.h"

// Don't trust an identity for sending to unless they've been around for at least this long
const NSTimeInterval kIdentityKeyStoreNonBlockingSecondsThreshold = 5.0;

// The canonical key includes 32 bytes of identity material plus one byte specifying the key type
const NSUInteger kIdentityKeyLength = 33;

// Cryptographic operations do not use the "type" byte of the identity key, so, for legacy reasons we store just
// the identity material.
// TODO: migrate to storing the full 33 byte representation.
const NSUInteger kStoredIdentityKeyLength = 32;

NSString *const kNSNotificationName_IdentityStateDidChange = @"kNSNotificationName_IdentityStateDidChange";

@interface YMIdentityManager ()
@property (nonatomic, strong) ECKeyPair *identity;
@property (nonatomic, strong) YMEncryptionUserModel *myModel;
@end

@implementation YMIdentityManager

+ (instancetype)sharedManager
{
    static YMIdentityManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YMIdentityManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}

- (ECKeyPair *)identityWithUserId:(nullable NSString*)userId {
    __block YMEncryptionUserModel *userModel = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMEncryptionUserModel"];
        while (result.next) {
            userModel = [[YMEncryptionUserModel alloc] init];
            userModel.userID = userId;
            userModel.identity = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"identity"]];
            self.identity = userModel.identity;
            userModel.currentSignedPrekeyId = [result intForColumn:@"currentSignedPrekeyId"];
            userModel.nextPrekeyId = [result intForColumn:@"nextPrekeyId"];
            userModel.isSaveIdentity = [result boolForColumn:@"isSaveIdentity"];
            self.myModel = userModel;
        }
        [result close];
    }];
    if (!userModel) {
        userModel = [[YMEncryptionUserModel alloc] init];
        userModel.userID = userId;
        userModel.identity = [Curve25519 generateKeyPair];
        self.identity = userModel.identity;
        userModel.currentSignedPrekeyId = 1;
        userModel.nextPrekeyId = 1;
        userModel.isSaveIdentity = NO;
        self.myModel = userModel;
        [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"INSERT OR REPLACE INTO YMEncryptionUserModel (userID, identity, currentSignedPrekeyId, nextPrekeyId) VALUES (?, ?, ?, ?)", userId, [NSKeyedArchiver archivedDataWithRootObject:userModel.identity], @(userModel.currentSignedPrekeyId), @(userModel.nextPrekeyId)];
            if (!success) {
                NSLog(@"插入YMEncryptionUserModel失败");
            }
        }];
    }
    return userModel.identity;
}

- (nullable ECKeyPair *)identityKeyPair:(nullable id)protocolContext{
    return self.identity;
}

- (int)localRegistrationId:(nullable id)protocolContext {
    return 1;
}

- (nullable YMRecipientIdentity *)recipientIdentityForRecipientId:(NSString *)recipientId{
    __block YMRecipientIdentity *recipientIdentity = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMRecipientIdentity WHERE recipientId=?", recipientId, nil];
        while (result.next) {
            recipientIdentity = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"recipientIdentity"]];
        }
        [result close];
    }];
    return recipientIdentity;
}

- (nullable NSData *)identityKeyForRecipientId:(NSString *)recipientId {
    __block NSData *identity = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMRecipientIdentity WHERE recipientId=?", recipientId, nil];
        while (result.next) {
            YMRecipientIdentity *recipientIdentity = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"recipientIdentity"]];
            identity = recipientIdentity.identityKey;
        }
        [result close];
    }];
    return identity;
}

- (YMVerificationState)verificationStateForRecipientId:(NSString *)recipientId {
    __block YMRecipientIdentity *recipientIdentity = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMRecipientIdentity WHERE recipientId=?", recipientId, nil];
        while (result.next) {
            recipientIdentity = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"recipientIdentity"]];
        }
        [result close];
    }];
    return recipientIdentity.verificationState==YMVerificationStateVerified;
}

- (BOOL)saveRemoteIdentity:(NSData *)identityKey recipientId:(NSString *)recipientId protocolContext:(nullable id)protocolContext {
    __block YMRecipientIdentity *existingIdentity = nil;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMRecipientIdentity WHERE recipientId=?", recipientId, nil];
        while (result.next) {
            existingIdentity = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"recipientIdentity"]];
        }
        [result close];
    }];
    if (existingIdentity) {
        if (![existingIdentity.identityKey isEqualToData:identityKey]) {
            YMVerificationState verificationState;
            switch (existingIdentity.verificationState) {
                case YMVerificationStateDefault:
                    verificationState = YMVerificationStateDefault;
                    break;
                case YMVerificationStateVerified:
                case YMVerificationStateNoLongerVerified:
                    verificationState = YMVerificationStateNoLongerVerified;
                    break;
            }
            YMRecipientIdentity *recipientIdentity = [[YMRecipientIdentity alloc] initWithRecipientId:recipientId identityKey:identityKey isFirstKnownKey:YES createdAt:[NSDate date] verificationState:verificationState];
            [recipientIdentity update];
            [[FMDBManager shared] archiveAllSessionsForContact:recipientId];
        }
        return YES;
    }
    else {
        YMRecipientIdentity *recipientIdentity = [[YMRecipientIdentity alloc] initWithRecipientId:recipientId identityKey:identityKey isFirstKnownKey:YES createdAt:[NSDate date] verificationState:YMVerificationStateDefault];
        [recipientIdentity store];
        return NO;
    }
}

- (BOOL)isTrustedIdentityKey:(NSData *)identityKey
                 recipientId:(NSString *)recipientId
                   direction:(TSMessageDirection)direction
             protocolContext:(id)protocolContext {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if ([userID isEqualToString:recipientId]) {
        ECKeyPair *localIdentityKey = [self identityWithUserId:recipientId];
        if ([localIdentityKey.publicKey isEqualToData:identityKey]) {
            return YES;
        }
        return NO;
    }
    switch (direction) {
        case TSMessageDirectionIncoming: {
            return YES;
        }
        case TSMessageDirectionOutgoing: {
            YMRecipientIdentity *existingIdentity = [YMRecipientIdentity fetchObjectWithUniqueID:recipientId];
            return [self isTrustedKey:identityKey forSendingToIdentity:existingIdentity];
        }
        default: {
            NSLog(@"unexpected message direction: %ld", (long)direction);
            return NO;
        }
    }
    return NO;
}

- (BOOL)isTrustedKey:(NSData *)identityKey forSendingToIdentity:(nullable YMRecipientIdentity *)recipientIdentity
{
    if (recipientIdentity == nil) {
        return YES;
    }
    
    if (![recipientIdentity.identityKey isEqualToData:identityKey]) {
        NSLog(@"key mismatch for recipient: %@", recipientIdentity.recipientId);
        return YES;
    }
    
    if ([recipientIdentity isFirstKnownKey]) {
        return YES;
    }
    
    switch (recipientIdentity.verificationState) {
        case YMVerificationStateDefault: {
            BOOL isNew = (fabs([recipientIdentity.createdAt timeIntervalSinceNow])
                          < kIdentityKeyStoreNonBlockingSecondsThreshold);
            if (isNew) {
                NSLog(@"not trusting new identity for recipient: %@", recipientIdentity.recipientId);
                return YES;
            } else {
                return YES;
            }
        }
        case YMVerificationStateVerified:
            return YES;
        case YMVerificationStateNoLongerVerified:
            NSLog(@"not trusting no longer verified identity for recipient: %@", recipientIdentity.recipientId);
            return NO;
    }
}

- (void)setVerificationState:(YMVerificationState)verificationState
                 identityKey:(NSData *)identityKey
                 recipientId:(NSString *)recipientId
       isUserInitiatedChange:(BOOL)isUserInitiatedChange {
    [self saveRemoteIdentity:identityKey recipientId:recipientId protocolContext:nil];
    
    YMRecipientIdentity *recipientIdentity = [YMRecipientIdentity fetchObjectWithUniqueID:recipientId];
    if (recipientIdentity == nil) {
        NSLog(@"Missing expected identity: %@", recipientId);
        return;
    }
    
    if (recipientIdentity.verificationState == verificationState) {
        return;
    }
    
    [recipientIdentity updateWithVerificationState:verificationState];
}


- (void)setUploadPublicKey:(BOOL)success {
    self.myModel.isSaveIdentity = success;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL stored = [db executeUpdate:@"UPDATE YMEncryptionUserModel SET isSaveIdentity = ?", @(success)];
        if (!stored) {
            NSLog(@"更新YMEncryptionUserModel->isSaveIdentity失败");
        }
    }];
}

- (BOOL)isUploadedPublicKey {
    return self.myModel.isSaveIdentity;
}

@end
