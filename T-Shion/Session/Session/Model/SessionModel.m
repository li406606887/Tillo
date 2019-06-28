//
//  DialogueModel.m
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SessionModel.h"
#import "NSDate+AL.h"

@implementation SessionModel
- (void)setTimestamp:(NSString *)timestamp {
    NSTimeInterval interval    = [timestamp doubleValue] / 1000.0;
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    _timestamp = date.conversaionTimeInfo;
//    _timestamp = [NSDate timestampToStringWithTimestamp:timestamp Format:@"MM-dd hh:mm"];
}

- (NSString *)name {
    if (!_name) {
        if ([self.type isEqualToString:@"singleChat"]) {
            _name = self.model.showName;
        }else {
            _name = self.group.name;
        }
    }
    return _name;
}
@end
