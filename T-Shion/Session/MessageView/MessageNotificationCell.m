//
//  MessageNotificationCell.m
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageNotificationCell.h"
#import "MessageModel.h"
#import "MessageBaseView.h"

@implementation MessageNotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:type reuseIdentifier:reuseIdentifier];
    if (self) {
        self.containerView = [[UIView alloc] init];
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.containerView.backgroundColor = RGB(207, 207, 207);
        CALayer *imageLayer = [self.containerView layer];
        [imageLayer setMasksToBounds:YES];
        [imageLayer setCornerRadius:4];
        [self.contentView addSubview:self.containerView];
        
        [self.contentView bringSubviewToFront:self.bubbleView];
    }
    return self;
}


- (void)setMessage:(MessageModel*)message {
    [super setMessage:message];
    self.bubbleView.message = message;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGSize size = [self.bubbleView bubbleSize];
    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.size.mas_offset(size);
    }];
    
    size.width += 16;
    size.height += 8;
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_offset(size);
    }];
    [super layoutSubviews];
}
@end
