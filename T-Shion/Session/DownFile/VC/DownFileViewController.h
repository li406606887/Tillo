//
//  DownFileViewController.h
//  T-Shion
//
//  Created by together on 2019/2/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@class MessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface DownFileViewController : BaseViewController
- (instancetype)initWithMessage:(MessageModel*)message;
@end

NS_ASSUME_NONNULL_END
