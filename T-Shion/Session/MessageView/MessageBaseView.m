//
//  MessageBaseView.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

@implementation MessageBaseView

- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(CGSize)bubbleSize {
    return CGSizeZero;
}

- (void)setMessage:(MessageModel *)message {
    _message = message;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}
@end
