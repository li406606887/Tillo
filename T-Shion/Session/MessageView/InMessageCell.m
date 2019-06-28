//
//  InMessageCell.m
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "InMessageCell.h"
#import "TriangleView.h"
#import "MessageBaseView.h"

@interface InMessageCell()
@property (strong, nonatomic) UIActivityIndicatorView *acview;
@end

@implementation InMessageCell

-(id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:type reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.headView];
        
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *imageLayer = [self.containerView layer];
        [imageLayer setMasksToBounds:YES];
        [imageLayer setCornerRadius:20];
        
        [self.contentView addSubview:self.containerView];
        [self.contentView addSubview:self.acview];
        [self.contentView bringSubviewToFront:self.bubbleView];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize size = [self bubbleSize];
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.showName) {
            make.left.equalTo(self.headView.mas_right).with.offset(5);
            make.top.equalTo(self.contentView.mas_top).with.offset(NAME_LABEL_HEIGHT);
        } else {
            make.top.equalTo(self.contentView.mas_top).with.offset(10);
            make.left.equalTo(self).with.offset(15);
        }
        make.size.mas_offset(size);
    }];

    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.size.mas_offset(size);
    }];
    
    [self.acview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.mas_right).with.offset(10);
        make.centerY.equalTo(self.containerView);
        make.size.mas_offset(CGSizeMake(30, 30));
    }];
    [super layoutSubviews];
}

- (void)setSelectedToShowCopyMenu:(BOOL)isSelected{
    [super setSelectedToShowCopyMenu:isSelected];
    if (self.selectedToShowCopyMenu) {
        self.containerView.backgroundColor = RGB(229, 229, 229);
    }else {
        self.containerView.backgroundColor = [UIColor whiteColor];
    }
}


- (void)setMessage:(MessageModel *)message {
    [self.message removeObserver:self forKeyPath:@"downloading"];
    [super setMessage:message];
    [self.message addObserver:self forKeyPath:@"downloading" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    self.containerView.hidden = message.msgType == MESSAGE_IMAGE || message.msgType == MESSAGE_Location? YES: NO;
    self.headView.image = nil;
    
    if (message.downloading) {
        [self.acview startAnimating];
    } else {
        [self.acview stopAnimating];
    }
    
    if (message.msgType == MESSAGE_Withdraw && self.showName == YES) {
        self.headView.hidden = self.nameLabel.hidden = YES;
    } else {
        self.headView.hidden = self.nameLabel.hidden = !self.showName;
    }
    
    if (self.showName) {
        if (!message.member) {
            message.member = [FMDBManager selectedMemberWithRoomId:message.roomId memberID:message.sender];
        }
        if (message.member.headIcon) {
            self.headView.image = message.member.headIcon;
        }
        @weakify(self)
        [[RACObserve(message.member, showName) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            self.nameLabel.text = [MemberModel getShowNameWithMember:self.message.member];
        }];
    }
    
    self.bubbleView.message = message;
    if (message.msgType == MESSAGE_Withdraw || message.msgType == MESSAGE_New_Msg) {
        self.containerView.backgroundColor = [UIColor clearColor];
    }else {
        self.containerView.backgroundColor = [UIColor whiteColor];
    }
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    @weakify(self)
    if([keyPath isEqualToString:@"downloading"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (self.message.downloading) {
                [self.acview startAnimating];
            } else {
                [self.acview stopAnimating];
            }
        });
        
    }
    
}

- (CGSize)bubbleSize {
    return [self.bubbleView bubbleSize];
}

- (UIImageView *)headView {
    if (!_headView) {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 40, 40)];
        _headView.layer.cornerRadius = 20;
        _headView.layer.masksToBounds = YES;
        _headView.userInteractionEnabled = YES;
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.headClickBlock) {
                self.headClickBlock(self.message.member.userId);
            }
        }];
        [_headView addGestureRecognizer:tap];
    }
    return _headView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        CGRect frame = CGRectMake(56, 0, self.contentView.frame.size.width - 24, NAME_LABEL_HEIGHT);
        _nameLabel = [[UILabel alloc] initWithFrame:frame];
        _nameLabel.font =  [UIFont systemFontOfSize:14.0f];
        _nameLabel.textColor = [UIColor grayColor];
    }
    return _nameLabel;
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

@end
