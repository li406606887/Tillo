//
//  ALDBBaseStore.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALDBManager.h"

#define     ALTimeStamp(date)   ([NSString stringWithFormat:@"%lf", [date timeIntervalSince1970]])

@interface ALDBBaseStore : NSObject

/// 数据库操作队列(从ALDBManager中获取，默认使用commonQueue)
@property (nonatomic, weak) FMDatabaseQueue *dbQueue;

/**
 *  表创建
 */
- (BOOL)createTable:(NSString *)tableName withSQL:(NSString *)sqlString;

/*
 *  执行带数组参数的sql语句 (增，删，改)
 */
- (BOOL)excuteSQL:(NSString *)sqlString withArrParameter:(NSArray *)arrParameter;

/*
 *  执行带字典参数的sql语句 (增，删，改)
 */
- (BOOL)excuteSQL:(NSString *)sqlString withDicParameter:(NSDictionary *)dicParameter;

/*
 *  执行格式化的sql语句 (增，删，改)
 */
- (BOOL)excuteSQL:(NSString *)sqlString,...;

/**
 *  执行查询指令
 */
- (void)excuteQuerySQL:(NSString *)sqlStr resultBlock:(void(^)(FMResultSet *rsSet))resultBlock;

@end

