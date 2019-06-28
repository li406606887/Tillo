//
//  EaseEmoji.m
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//


#import "EaseEmoji.h"
#import "EaseEmojiEmoticons.h"

@implementation EaseEmoji

+ (NSString *)emojiWithCode:(int)code
{
    int sym = EMOJI_CODE_TO_SYMBOL(code);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}

+ (NSArray *)allEmoji
{
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:[EaseEmojiEmoticons allEmoticons]];
    return array;
}

@end
