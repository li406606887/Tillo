//
//  RequestModel.m
//  T-Shion
//
//  Created by together on 2018/4/16.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "RequestModel.h"

@implementation RequestModel
- (void)setStatus:(NSString *)status {
    _status = status;
    if ([_status isEqualToString:@"-10000"]) {
        [SocketViewModel kickUserRequest:NO];
    }
}
@end

@implementation RequestTableModel

@end
