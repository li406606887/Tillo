//
//  FMDBManager+SignedPreKeyStore.h
//  SecureTest
//
//  Created by mac on 2019/3/29.
//  Copyright © 2019 mac. All rights reserved.
//

#import "FMDBManager.h"
#import <AxolotlKit/SignedPreKeyStore.h>


@interface FMDBManager (SignedPreKeyStore) <SignedPreKeyStore>

- (SignedPreKeyRecord *)generateRandomSignedRecord;

- (nullable SignedPreKeyRecord *)loadSignedPrekeyOrNil:(int)signedPreKeyId;

@end

