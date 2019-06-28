//
//  RequestModel.h
//  T-Shion
//
//  Created by together on 2018/4/16.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestModel : NSObject
@property (copy  , nonatomic) NSString *status;
@property (copy  , nonatomic) NSString *message;
@property (strong, nonatomic) id  data;
@end

@interface RequestTableModel : NSObject
@property (assign , nonatomic) int pages;
@property (strong , nonatomic) NSArray *rows;
@property (assign, nonatomic) int total;
@property (assign, nonatomic) int pageNo;

@end
