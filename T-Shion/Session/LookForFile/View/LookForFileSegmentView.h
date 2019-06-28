//
//  LookForFileSegmentView.h
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LookForFileSegmentView : BaseView
/**
 创建segmentView
 @param array 数组
 */
@property (copy, nonatomic) void (^clickBlock) (long index);

/**
 设置滑动位置
 @param index 位置
 */
- (void)setSegmentIndex:(long)index;
@end

NS_ASSUME_NONNULL_END
