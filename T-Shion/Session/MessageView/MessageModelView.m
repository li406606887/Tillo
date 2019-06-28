//
//  MessageModelView.m
//  T-Shion
//
//  Created by together on 2018/12/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageModelView.h"

@implementation MessageModelView
- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [self.message removeObserver:self forKeyPath:@"flags"];
}

- (CGSize)messageSize {
    return CGSizeZero;
}

- (void)setMessage:(MessageModel *)message {
    _message = message;
    
    [self.message addObserver:self forKeyPath:@"sendStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"sendStatus"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([self.message.sendStatus intValue] == 1) {
//                [self.acview stopAnimating];
//                [self.resendButton setHidden:YES];
//            }else if([self.model.sendStatus intValue] == 2){
//                [self.acview stopAnimating];
//                [self.resendButton setHidden:NO];
//            }else if([self.model.sendStatus intValue] == 3){
//                [self.acview startAnimating];
//                [self.resendButton setHidden:YES];
//            }
        });
    }
}

@end
