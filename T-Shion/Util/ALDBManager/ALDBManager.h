//
//  ALDBManager.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface ALDBManager : NSObject

/**
 *  DB队列（除IM相关）
 */
@property (nonatomic, strong) FMDatabaseQueue *commonQueue;

/**
 *  与IM相关的DB队列
 */
@property (nonatomic, strong) FMDatabaseQueue *messageQueue;


+ (ALDBManager *)sharedInstance;


@end


