//
//  OutMessageCell.h
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OutMessageCell : MessageViewCell
@property (copy, nonatomic) void(^resendBlock) (MessageModel *model);
@end

NS_ASSUME_NONNULL_END
