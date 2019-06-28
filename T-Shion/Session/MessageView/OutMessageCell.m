//
//  OutMessageCell.m
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "OutMessageCell.h"
#import "TriangleView.h"
#import "MessageModel.h"
#import "MessageBaseView.h"

@interface OutMessageCell()
@property (strong, nonatomic) UIActivityIndicatorView *sendingIndicatorView;
//@property (strong, nonatomic) TriangleView *triangleView;

@property (strong, nonatomic) UIActivityIndicatorView *acview;
@property (strong, nonatomic) UIImageView *resendButton;
@end

@implementation OutMessageCell
- (id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:type reuseIdentifier:reuseIdentifier];
    if (self) {
        self.containerView = [[UIView alloc] init];
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.containerView.backgroundColor = RGB(84, 208, 172);
        CALayer *imageLayer = [self.containerView layer];
        [imageLayer setMasksToBounds:YES];
        [imageLayer setCornerRadius:20];
        [self.contentView addSubview:self.containerView];
        if (self.bubbleView) {
            [self.contentView bringSubviewToFront:self.bubbleView];
        }
        [self.contentView addSubview:self.resendButton];
        [self.contentView addSubview:self.acview];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize size = [self bubbleSize];
    
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.top.equalTo(self.contentView).with.offset(10);
        make.size.mas_equalTo(size);
    }];
    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.size.mas_offset(size);
    }];
    
    [self.resendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.equalTo(self.containerView);
        make.right.equalTo(self.containerView.mas_left).with.offset(-8);
    }];
    
    [self.acview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(self.containerView);
        make.right.equalTo(self.containerView.mas_left);
    }];
    
    [super layoutSubviews];
}

- (void)setSelectedToShowCopyMenu:(BOOL)isSelected{
    [super setSelectedToShowCopyMenu:isSelected];
    if (self.selectedToShowCopyMenu) {
        self.containerView.backgroundColor = RGB(148, 204, 94);
    } else {
        self.containerView.backgroundColor = RGB(197, 216, 255);
    }
}

- (void)setMessage:(MessageModel *)message {
    [self.message removeObserver:self forKeyPath:@"sendStatus"];
    [super setMessage:message];
    self.bubbleView.message = message;
    self.containerView.hidden = message.msgType == MESSAGE_IMAGE || message.msgType == MESSAGE_Location? YES: NO;
    
    switch ([message.sendStatus intValue]) {
        case 1:
            self.resendButton.hidden = YES;
            [self.acview stopAnimating];
            break;
        case 2:
            self.resendButton.hidden = NO;
            [self.acview stopAnimating];
            break;
        case 3:
            self.resendButton.hidden = YES;
            [self.acview startAnimating];
            break;
        default:
            break;
    }
    if (message.msgType == MESSAGE_Withdraw || message.msgType == MESSAGE_New_Msg) {
        self.containerView.backgroundColor = [UIColor clearColor];
    }else {
        self.containerView.backgroundColor = RGB(84, 208, 172);
    }
    [self.message addObserver:self forKeyPath:@"sendStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   if([keyPath isEqualToString:@"sendStatus"]) {
           dispatch_async(dispatch_get_main_queue(), ^{
               if ([self.message.sendStatus intValue] == 1) {
                   [self.acview stopAnimating];
                   [self.resendButton setHidden:YES];
               }else if([self.message.sendStatus intValue] == 2){
                   [self.acview stopAnimating];
                   [self.resendButton setHidden:NO];
               }else if([self.message.sendStatus intValue] == 3){
                   NSLog(@"消息ID%@,回执ID%@", self.message.messageId, self.message.backId);
                   [self.acview startAnimating];
                   [self.resendButton setHidden:YES];
               }
           });
    }
}

- (CGSize)bubbleSize {
    return [self.bubbleView bubbleSize];
}

- (UIActivityIndicatorView *)acview {
    if (!_acview) {
        _acview = [[UIActivityIndicatorView alloc] init];
        _acview.translatesAutoresizingMaskIntoConstraints = NO;
        [_acview setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_acview startAnimating];
    }
    return _acview;
}

- (UIImageView *)resendButton {
    if (!_resendButton) {
        _resendButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Dialogue_resend"]];
        _resendButton.translatesAutoresizingMaskIntoConstraints = NO;
        _resendButton.contentMode = UIViewContentModeCenter;
        _resendButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        @weakify(self)
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.resendBlock) {
                self.resendBlock(self.message);
            }
        }];
        [_resendButton addGestureRecognizer:tap];
    }
    return _resendButton;
}
@end
