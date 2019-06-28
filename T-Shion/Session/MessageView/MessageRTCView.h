//
//  MessageRTCView.h
//  T-Shion
//
//  Created by together on 2019/1/7.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageRTCView : MessageBaseView
@property (copy, nonatomic) void (^rtcCallBlock)(MessageModel *model);
@end

NS_ASSUME_NONNULL_END
