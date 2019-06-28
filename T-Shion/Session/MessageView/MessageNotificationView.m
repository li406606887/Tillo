//
//  MessageNotificationView.m
//  T-Shion
//
//  Created by together on 2018/12/13.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageNotificationView.h"

#define  widthMax  SCREEN_WIDTH * 0.65f



@implementation MessageNotificationView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.label = [[UILabel alloc] init];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        [self.label setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
    if (message.msgType == MESSAGE_NotifyTime) {
        self.label.text = message.times;
    }else {
        self.label.text = message.content;
    }
    
}

- (CGSize)bubbleSize {
    if (self.message.msgType == MESSAGE_NotifyTime) {
        CGRect bounds = CGRectMake(0, 0, widthMax, 44);
        CGRect r = [self.label textRectForBounds:bounds limitedToNumberOfLines:0];
        return r.size;
    } else {
        CGSize textSize = [MessageNotificationView textSizeForText:self.label.text withFont:[UIFont systemFontOfSize:14]];
        return textSize;
    }
}

+ (CGSize)textSizeForText:(NSString *)txt withFont:(UIFont*)font {
    CGRect rect = [txt boundingRectWithSize:CGSizeMake(widthMax, MAXFLOAT)
                   
                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                   
                                 attributes:@{NSFontAttributeName:font}
                   
                                    context:nil];
    double height = ceil(rect.size.height);
    double width = ceil(rect.size.width);//14内容距外边距 +15内容距内边距
    return  CGSizeMake(width,height);
}

- (void)layoutSubviews {
    CGRect bubbleFrame = self.bounds;
    self.label.frame = bubbleFrame;
    [self.label sizeToFit];
    [super layoutSubviews];
}
@end

