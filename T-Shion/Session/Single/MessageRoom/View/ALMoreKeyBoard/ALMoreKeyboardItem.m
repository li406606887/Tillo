//
//  ALMoreKeyboardItem.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALMoreKeyboardItem.h"

@implementation ALMoreKeyboardItem

+ (ALMoreKeyboardItem *)createByType:(ALMoreKeyboardItemType)type
                               title:(NSString *)title
                           imagePath:(NSString *)imagePath {
    ALMoreKeyboardItem *item = [[ALMoreKeyboardItem alloc] init];
    item.type = type;
    item.title = title;
    item.imagePath = imagePath;
    return item;
}

@end
