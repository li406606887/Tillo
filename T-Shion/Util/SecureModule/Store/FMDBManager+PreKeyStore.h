//
//  FMDBManager+PreKeyStore.h
//  SecureTest
//
//  Created by mac on 2019/3/29.
//  Copyright © 2019 mac. All rights reserved.
//

#import "FMDBManager.h"
#import <AxolotlKit/PreKeyStore.h>


@interface FMDBManager (PreKeyStore)<PreKeyStore>

- (NSArray<PreKeyRecord *> *)generatePreKeyRecordsWithCount:(NSInteger)count;

@end


