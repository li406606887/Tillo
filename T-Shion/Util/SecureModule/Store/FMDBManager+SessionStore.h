//
//  FMDBManager+SessionStore.h
//  SecureTest
//
//  Created by mac on 2019/3/29.
//  Copyright © 2019 mac. All rights reserved.
//

#import "FMDBManager.h"
#import <AxolotlKit/SessionStore.h>
NS_ASSUME_NONNULL_BEGIN

@interface FMDBManager (SessionStore)<SessionStore>

- (void)archiveAllSessionsForContact:(NSString *)contactIdentifier;

#pragma mark - Debug

- (void)resetSessionStore;



@end

NS_ASSUME_NONNULL_END
