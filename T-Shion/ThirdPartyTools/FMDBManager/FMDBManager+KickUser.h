//
//  FMDBManager+KickUser.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/25.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"


@interface FMDBManager (KickUser)

+ (BOOL)updateKickLog:(NSDictionary *)logDict;

+ (BOOL)updateMpushConnectLog:(NSDictionary *)logDict;

@end

