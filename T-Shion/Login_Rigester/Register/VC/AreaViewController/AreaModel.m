//
//  AreaModel.m
//  T-Shion
//
//  Created by together on 2018/4/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AreaModel.h"

@implementation AreaModel
- (void)setName:(NSString *)name {
    _name = name;
    _firstLetter = [NSString getStringFirstLetterWithString:name];
}
@end
