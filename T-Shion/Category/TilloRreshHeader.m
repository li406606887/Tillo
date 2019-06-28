//
//  TilloRreshHeader.m
//  T-Shion
//
//  Created by together on 2018/5/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TilloRreshHeader.h"

@implementation TilloRreshHeader

- (instancetype)init {
    if (self = [super init]) {
        self.stateLabel.hidden = YES;
        
        self.lastUpdatedTimeLabel.hidden = YES;
        
        self.arrowView.hidden = YES;
        
        self.height = 25;
    }
    return self;
}
@end
