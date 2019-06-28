//
//  FMDBManager+PreKeyStore.m
//  SecureTest
//
//  Created by mac on 2019/3/29.
//  Copyright © 2019 mac. All rights reserved.
//

#import "FMDBManager+PreKeyStore.h"

#define BATCH_SIZE 100

@implementation FMDBManager (PreKeyStore)

- (PreKeyRecord *)loadPreKey:(int)preKeyId {
    __block PreKeyRecord *prekey = nil;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM PreKeyRecord WHERE Id=?", @(preKeyId)];
        while (result.next) {
            int Id = [result intForColumn:@"Id"];
            ECKeyPair *keyPair = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"keyPair"]];
            prekey = [[PreKeyRecord alloc] initWithId:Id keyPair:keyPair];
        }
        [result close];
    }];
    return prekey;
}

- (void)storePreKey:(int)preKeyId preKeyRecord:(PreKeyRecord *)record {
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if (db.open) {
        BOOL success = [db executeUpdate:@"INSERT OR REPLACE INTO PreKeyRecord (Id, keyPair) VALUES (?, ?)", @(preKeyId), [NSKeyedArchiver archivedDataWithRootObject:record.keyPair]];
        if (!success) {
            NSLog(@"插入preKeyRecord失败：%d", preKeyId);
        }
        }
    }];
}

- (BOOL)containsPreKey:(int)preKeyId {
    __block BOOL ret;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM PreKeyRecord WHERE Id=?", @(preKeyId)];
        while (result.next) {
            ret = YES;
        }
        [result close];
    }];
    return ret;
}

- (void)removePreKey:(int)preKeyId{
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"DELETE FROM PreKeyRecord WHERE Id=?", @(preKeyId)];
        if (!success) {
            NSLog(@"删除PreKeyRecord失败, record.Id:%d", preKeyId);
        }
    }];    
}

- (NSArray<PreKeyRecord *> *)generatePreKeyRecordsWithCount:(NSInteger)count
{
    NSMutableArray *preKeyRecords = [NSMutableArray array];
    NSInteger c = count == 0 ? BATCH_SIZE : count;
    @synchronized(self)
    {
        int preKeyId = [self nextPreKeyId];
        
        NSLog(@"building %d new preKeys starting from preKeyId: %d", BATCH_SIZE, preKeyId);
        for (int i = 0; i < c; i++) {
            ECKeyPair *keyPair = [Curve25519 generateKeyPair];
            PreKeyRecord *record = [[PreKeyRecord alloc] initWithId:preKeyId keyPair:keyPair];
            
            [preKeyRecords addObject:record];
            //生成就存储
            [self storePreKey:record.Id preKeyRecord:record];
            preKeyId++;
        }
//        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
//        BOOL success = [self.db executeUpdate:@"UPDATE UserInfo nextPrekeyID=? WHERE ID=?", preKeyId, userID];
        [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL success = [db executeUpdate:@"UPDATE YMEncryptionUserModel SET nextPrekeyID=?", @(preKeyId)];
            if (!success) {
                NSLog(@"存储nextPreKeyId失败");
            }
        }];
    }
    return preKeyRecords;
}

- (int)nextPreKeyId {
    __block int ret = 1;
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM YMEncryptionUserModel"];
        int nextSignedPreKeyId = 1;
        while (result.next) {
            nextSignedPreKeyId = [result intForColumn:@"nextPrekeyId"];
            if (nextSignedPreKeyId > INT32_MAX-1)
                nextSignedPreKeyId = 1;
            ret = nextSignedPreKeyId;
        }
        [result close];
    }];
    return ret;
}

- (void)storePreKeyRecords:(NSArray<PreKeyRecord *> *)preKeyRecords
{
    for (PreKeyRecord *record in preKeyRecords) {
        [self storePreKey:record.Id preKeyRecord:record];
    }
}

@end
