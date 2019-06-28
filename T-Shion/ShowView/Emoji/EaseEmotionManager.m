//
//  EaseEmotionManager.m
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "EaseEmotionManager.h"

@implementation EaseEmotionManager

- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions
{
    self = [super init];
    if (self) {
        _emotionType = Type;
        _emotionRow = emotionRow;
        _emotionCol = emotionCol;
        _emotions = emotions;
    }
    return self;
}
@end
