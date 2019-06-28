//
//  NSObject+Common.m
//  AilloTest
//
//  Created by mac on 2019/6/4.
//  Copyright © 2019 With_Dream. All rights reserved.
//  避免一些闪退的异常处理

#import "NSObject+Common.h"

@implementation NSNumber (Common)

- (NSInteger)length {
    return [[self stringValue] length];
}

- (BOOL)isEqualToString:(NSString*)string {
    return [[self stringValue] isEqualToString:string];
}

@end

@implementation NSNull (Common)

- (BOOL)boolValue {
    return NO;
}

- (NSInteger)length {
    return 0;
}

- (BOOL)isEqualToString:(NSString*)string {
    return NO;
}

- (NSInteger)integerValue {
    return 0;
}

@end
