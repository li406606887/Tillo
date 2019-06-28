//
//  FMDBManager+SignedPreKeyStore.m
//  SecureTest
//
//  Created by mac on 2019/3/29.
//  Copyright © 2019 mac. All rights reserved.
//

#import "FMDBManager+SignedPreKeyStore.h"
#import "YMIdentityManager.h"
#import <Curve25519Kit/Ed25519.h>
#import <Curve25519Kit/Curve25519.h>
#import "NSData+keyVersionByte.h"

@implementation FMDBManager (SignedPreKeyStore)

- (SignedPreKeyRecord *)generateRandomSignedRecord {
    ECKeyPair *keyPair = [Curve25519 generateKeyPair];

    // Signed prekey ids must be > 0.
    int preKeyId = [self nextSignedPreKeyId];
    ECKeyPair *identityKeyPair = [[YMIdentityManager sharedManager] identityWithUserId:nil];

    @try {
        NSData *signature = [Ed25519 throws_sign:keyPair.publicKey.prependKeyType withKeyPair:identityKeyPair];
        return [[SignedPreKeyRecord alloc] initWithId:preKeyId
                                              keyPair:keyPair
                                            signature:signature
                                          generatedAt:[NSDate date]];
    } @catch (NSException *exception) {
        // throws_sign only throws when the data to sign is empty or `keyPair` is nil.
        // Neither of which should happen.
        NSLog(@"签名出错：%@", exception);
        return nil;
    }
    return nil;
}

- (nullable SignedPreKeyRecord *)loadSignedPreKey:(int)signedPreKeyId {
    __block SignedPreKeyRecord *record = nil;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SignedPreKeyRecord WHERE Id=?", @(signedPreKeyId)];
        while (result.next) {
            int Id = [result intForColumn:@"Id"];
            ECKeyPair *keyPair = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"keyPair"]];
            NSData *signature = [result dataForColumn:@"signature"];
            NSDate *generatedAt = [result dateForColumn:@"generatedAt"];
            BOOL wasAcceptedByService = [result boolForColumn:@"wasAcceptedByService"];
            record = [[SignedPreKeyRecord alloc] initWithId:Id keyPair:keyPair signature:signature generatedAt:generatedAt];
            if (wasAcceptedByService)
                [record markAsAcceptedByService];
        }
        [result close];
    }];
    return record;
}

- (int)nextSignedPreKeyId {
    __block int ret = 1;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMEncryptionUserModel"];
        int nextSignedPreKeyId = 1;
        while (result.next) {
            nextSignedPreKeyId = [result intForColumn:@"currentSignedPrekeyId"]+1;
            if (nextSignedPreKeyId > INT32_MAX-2)
                nextSignedPreKeyId = 1;
            ret = nextSignedPreKeyId;
        }
        [result close];
        [db executeUpdate:@"UPDATE YMEncryptionUserModel SET currentSignedPrekeyId=?", @(ret)];
    }];
    return ret;
}

- (NSArray *)loadSignedPreKeys
{
    __block NSMutableArray *signedPreKeyRecords = [NSMutableArray array];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SignedPreKeyRecord"];
        while (result.next) {
            int Id = [result intForColumn:@"Id"];
            ECKeyPair *keyPair = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"keyPair"]];
            NSData *signature = [result dataForColumn:@"signature"];
            NSDate *generatedAt = [result dateForColumn:@"generatedAt"];
            BOOL wasAcceptedByService = [result boolForColumn:@"wasAcceptedByService"];
            SignedPreKeyRecord *record = [[SignedPreKeyRecord alloc] initWithId:Id keyPair:keyPair signature:signature generatedAt:generatedAt];
            if (wasAcceptedByService)
                [record markAsAcceptedByService];
            [signedPreKeyRecords addObject:record];
        }
        [result close];
    }];
    return signedPreKeyRecords;
}

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord *)signedPreKeyRecord {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"INSERT OR REPLACE INTO SignedPreKeyRecord (Id, keyPair, signature, generatedAt, wasAcceptedByService) VALUES (?, ?, ?, ?, ?)", @(signedPreKeyId), [NSKeyedArchiver archivedDataWithRootObject:signedPreKeyRecord.keyPair], signedPreKeyRecord.signature, signedPreKeyRecord.generatedAt, @(signedPreKeyRecord.wasAcceptedByService)];
        if (!success) {
            NSLog(@"储存SignedPreKeyRecord失败:%d", signedPreKeyId);
        }
    }];
}

- (BOOL)containsSignedPreKey:(int)signedPreKeyId {
    __block BOOL ret = NO;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM SignedPreKeyRecord WHERE Id=?", @(signedPreKeyId)];
        while (result.next) {
            ret = YES;
        }
        [result close];
    }];
    return ret;
}

- (void)removeSignedPreKey:(int)signedPrekeyId
{
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"DELETE FROM SignedPreKeyRecord WHERE Id=?", @(signedPrekeyId)];
        if (!success) {
            NSLog(@"删除SignedPreKeyRecord失败：%d", signedPrekeyId);
        }
    }];
}

- (nullable NSNumber *)currentSignedPrekeyId
{
    __block NSNumber *ret = [NSNumber numberWithInt:1];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMEncryptionUserModel"];
        int nextSignedPreKeyId = 1;
        while (result.next) {
            nextSignedPreKeyId = [result intForColumn:@"currentSignedPrekeyId"];
            ret = [NSNumber numberWithInt:nextSignedPreKeyId];
        }
        [result close];
    }];
    return ret;
}

- (void)setCurrentSignedPrekeyId:(int)value
{
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"UPDATE YMEncryptionUserModel SET currentSignedPrekeyId=?", @(value)];
        if (!success) {
            NSLog(@"设置CurrentSignedPrekeyId失败：%d", value);
        }
    }];
}

- (nullable SignedPreKeyRecord *)currentSignedPreKey
{
    NSNumber *currentPrekeyId = [self currentSignedPrekeyId];
    return [self loadSignedPrekeyOrNil:[currentPrekeyId intValue]];
}

@end
