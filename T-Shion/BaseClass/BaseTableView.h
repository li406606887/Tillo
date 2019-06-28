//
//  BaseTableView.h
//  T-Shion
//
//  Created by together on 2018/6/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableView : UITableView
@property (copy, nonatomic) void (^touchBeginBlock) (void);
@end
