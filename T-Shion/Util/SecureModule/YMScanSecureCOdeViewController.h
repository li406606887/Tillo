//
//  YMScanSecureCOdeViewController.h
//  AilloTest
//
//  Created by mac on 2019/4/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YMScanSecureCOdeViewController : BaseViewController

@property (nonatomic, copy) void(^scanComplete)(NSData *result);

@end

NS_ASSUME_NONNULL_END
