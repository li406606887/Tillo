//
//  EaseEmotionManager.h
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EMEmotionType) {
    EMEmotionDefault = 0,
    EMEmotionPng,
    EMEmotionGif
};

@interface EaseEmotionManager : NSObject

@property (nonatomic, copy) NSString *emotionName;
/**
 *  某一类表情的数据源
 */
@property (nonatomic, strong) NSArray *emotions;

@property (nonatomic, assign) NSInteger emotionRow;

@property (nonatomic, assign) NSInteger emotionCol;

@property (nonatomic, assign) EMEmotionType emotionType;

- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions;

@end
