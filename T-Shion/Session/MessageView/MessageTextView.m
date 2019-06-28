//
//  MessageTextView.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageTextView.h"
#import "KILabel.h"
#import "NSString+JSMessagesView.h"


@interface MessageTextView ()<YYTextViewDelegate>
//@property(nonatomic, copy) NSString *text;
@end

@implementation MessageTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:self.contentLabel];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)setMessage:(MessageModel *)message{
    UIColor *color = message.sendType == OtherSender ? [UIColor blackColor]: [UIColor whiteColor];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *atttibuted = [[NSAttributedString alloc] initWithString:message.content attributes:@{NSParagraphStyleAttributeName:style,NSFontAttributeName:[UIFont systemFontOfSize: 17],NSForegroundColorAttributeName:color}];
    self.contentView.attributedText = atttibuted;
    [super setMessage:message];
}

- (CGSize)bubbleSize {
    self.contentView.size = CGSizeMake(0, 0);
    CGSize size =  [self.contentView sizeThatFits:CGSizeMake(250, MAXFLOAT)];
    size.width += 4;
    size.height += 20;
    if (size.width<40) {
        size.width = 40;
    }
    if (size.height<40) {
        size.height = 40.0f;
    }
    return size;
}

- (void)textView:(YYTextView *)textView didTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect {
    NSLog(@"%ld%ld",characterRange.location,characterRange.length);
    highlight.tapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        NSURL *url = [NSURL URLWithString:text.string];
        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", text]];
            if (![[UIApplication sharedApplication] canOpenURL:url]) {
                NSLog(@"can't open url:%@", text);
                return;
            }
        }
        [[UIApplication sharedApplication] openURL:url];
    };
}

-(void)layoutSubviews {
    CGRect bubbleFrame = self.bounds;
    self.contentView.frame = CGRectMake(2, 10, bubbleFrame.size.width-4, bubbleFrame.size.height-20);
    [super layoutSubviews];
}

//- (KILabel *)contentLabel {
//    if (!_contentLabel) {
//        _contentLabel = [[KILabel alloc] init];
//        _contentLabel.font = [UIFont systemFontOfSize:17.0f];
//        _contentLabel.numberOfLines = 0;
//        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        _contentLabel.preferredMaxLayoutWidth = widthMax;
//        _contentLabel.linkDetectionTypes = KILinkTypeOptionURL;
//    }
//    return _contentLabel;
//}

- (YYTextView *)contentView {
    if (!_contentView) {
        _contentView = [[YYTextView alloc] init];
        _contentView.font = [UIFont systemFontOfSize:17];
        _contentView.editable = NO;
        _contentView.scrollEnabled = NO;
        _contentView.dataDetectorTypes = UIDataDetectorTypeLink;
        _contentView.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 8);
        _contentView.delegate = self;
    }
    return _contentView;
}
@end
