//
//  QueryMessageTableViewCell.h
//  T-Shion
//
//  Created by together on 2019/3/21.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueryMessageTableViewCell : BaseTableViewCell
@property (assign, nonatomic) int type;    
@property (copy, nonatomic) MessageModel *message;

@end

NS_ASSUME_NONNULL_END
