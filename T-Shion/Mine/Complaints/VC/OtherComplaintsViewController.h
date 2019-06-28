//
//  OtherComplaintsViewController.h
//  T-Shion
//
//  Created by together on 2019/4/26.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OtherComplaintsViewController : BaseViewController
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *targerId;
@property (assign, nonatomic) int type;
@end

NS_ASSUME_NONNULL_END
