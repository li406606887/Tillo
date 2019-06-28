//
//  AudioModel.m
//  T-Shion
//
//  Created by together on 2018/5/7.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AudioModel.h"

@implementation AudioModel
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"fileHash":@"hash",@"ID":@"_id"};
}
@end
