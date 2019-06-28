//
//  GroupSessionModel.m
//  T-Shion
//
//  Created by together on 2018/7/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupSessionModel.h"
#import "NSDate+AL.h"

@implementation GroupSessionModel
+(NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"count":@"_offline_count",@"roomId":@"roomid",@"ID":@"_id"};
}

- (void)setTimestamp:(NSString *)timestamp {
    NSTimeInterval interval    = [timestamp doubleValue] / 1000.0;
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    _timestamp = date.conversaionTimeInfo;
//    _timestamp = [NSDate timestampToStringWithTimestamp:timestamp Format:@"MM-dd hh:mm"];
}

@end
