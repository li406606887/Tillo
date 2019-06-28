//
//  ALDBManager.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALDBManager.h"
#import "NSFileManager+AL.h"

static ALDBManager *manager;

@implementation ALDBManager

+ (ALDBManager *)sharedInstance {
    static dispatch_once_t once;
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    dispatch_once(&once, ^{
        manager = [[ALDBManager alloc] initWithUserID:userID];
    });
    return manager;
}

- (instancetype)initWithUserID:(NSString *)userID {
    if (self = [super init]) {
        NSString *commonQueuePath = [NSFileManager pathDBCommon];
        self.commonQueue = [FMDatabaseQueue databaseQueueWithPath:commonQueuePath];
        NSString *messageQueuePath = [NSFileManager pathDBMessage];
        self.messageQueue = [FMDatabaseQueue databaseQueueWithPath:messageQueuePath];
    }
    return self;
}


@end
