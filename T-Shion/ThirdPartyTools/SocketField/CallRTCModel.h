//
//  CallRTCModel.h
//  T-Shion
//
//  Created by together on 2018/12/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CallRTCModel : NSObject
@property (copy, nonatomic) NSString *chatType;
@property (copy, nonatomic) NSString *roomId;
@property (copy, nonatomic) NSString *sender;
@property (copy, nonatomic) NSString *cmd;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSArray *receivers;
@end


