//
//  SendCardViewController.h
//  AilloTest
//
//  Created by together on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SendCardViewController : BaseViewController
@property (copy, nonatomic) void (^clickCardBlock) (NSString *param);
- (instancetype)initWithUid:(NSString *)uid;
@end

NS_ASSUME_NONNULL_END
