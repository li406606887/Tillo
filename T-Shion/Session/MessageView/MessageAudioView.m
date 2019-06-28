//
//  MessageAudioView.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageAudioView.h"

@interface MessageAudioView ()
@property (strong, nonatomic) UIImageView *sendAudioAnimationImageView;
@property (strong, nonatomic) UIImageView *receiveAudioAnimationImageView;
@property (weak, nonatomic) UIImageView *audioAnimationImageView;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIView *colorView;
@end

@implementation MessageAudioView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupViews];
        @weakify(self)
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            @strongify(self)
            if (self.playBlock) {
                self.playBlock(self.message);
            }
            self.colorView.alpha = 1;
            [self hiddenView];
        }];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.sendAudioAnimationImageView];
    [self addSubview:self.receiveAudioAnimationImageView];
    [self addSubview:self.durationLabel];
    [self addSubview:self.redView];
    [self addSubview:self.colorView];
}

- (void)layoutSubviews {
    [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(12);
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(7, 7));
    }];
    
    [self.audioAnimationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(13, 16));
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_offset(CGSizeMake(40, 20));
    }];
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super layoutSubviews];
}

- (void)setMessage:(MessageModel *)message {
    [self.message removeObserver:self forKeyPath:@"audioPlaying"];
    [super setMessage:message];
    if (message.audioPlaying) {
        [self.audioAnimationImageView startAnimating];
    }else {
        [self.audioAnimationImageView stopAnimating];
    }
    
    [self updateAudioViewLayoutWithWay:message.sendType];

    if (!message.downloading) {
        if ([message.readStatus intValue]!=1) {
            BOOL state = [FMDBManager seletedFileIsSaveWithPath:message];
            if (!state) {
                message.downloading = YES;
                [TSRequest downLoadAudioWithTitle:message];
            }
        }
    }
    
    if (message.sendType == SelfSender) {
        self.redView.hidden = YES;
    }else {
        self.redView.hidden = [message.readStatus intValue] != 1 ? NO: YES;
    }

    if (self.durationLabel.hidden==NO) {
        self.durationLabel.text = [NSString stringWithFormat:@"%@”",message.duration];
    }

    self.durationLabel.textColor = message.sendType == OtherSender ? [UIColor blackColor]: [UIColor whiteColor];
    
    [self.message addObserver:self forKeyPath:@"audioPlaying" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    @weakify(self)
    if([keyPath isEqualToString:@"audioPlaying"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            if (self.message.audioPlaying) {
                self.redView.hidden = YES;
                [self.audioAnimationImageView startAnimating];
            }else {
                [self.audioAnimationImageView stopAnimating];
            }
        });
    }
}

- (CGSize)bubbleSize {
    CGSize bubbleSize = CGSizeMake(kAudioWidth, kAudioHeight);
    return bubbleSize;
}

- (void)updateAudioViewLayoutWithWay:(MsgSendType)type {
    self.audioAnimationImageView.hidden = YES;
    if (type == OtherSender) {
        self.audioAnimationImageView = self.receiveAudioAnimationImageView;
        [self.audioAnimationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(12);
        }];
        
        [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.audioAnimationImageView.mas_right).with.offset(18);
        }];
    }else {
        self.audioAnimationImageView = self.sendAudioAnimationImageView;
        [self.audioAnimationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).with.offset(-12);
        }];
        
        [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.audioAnimationImageView.mas_left).with.offset(-18);
        }];
    }
    self.audioAnimationImageView.hidden = NO;

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.colorView.alpha = 1;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenView];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenView];
    [super touchesEnded:touches withEvent:event];
}

- (void)hiddenView {
    @weakify(self)
    [UIView animateWithDuration:0.15 animations:^{// 要执行动画的代码
        @strongify(self)
        self.colorView.alpha = 0;
    } completion:nil];
}
#pragma mark 懒加载
- (UIView *)redView {
    if (!_redView) {
        _redView = [[UIView alloc] init];
        _redView.layer.cornerRadius = 3.5f;
        _redView.backgroundColor = RGB(255, 99, 121);
        _redView.hidden = YES;
    }
    return _redView;
}

- (UIImageView *)receiveAudioAnimationImageView {
    if (!_receiveAudioAnimationImageView) {
        _receiveAudioAnimationImageView = [[UIImageView alloc] init];
        _receiveAudioAnimationImageView.animationRepeatCount = 0;
        _receiveAudioAnimationImageView.animationDuration = 1;
        _receiveAudioAnimationImageView.image=[UIImage imageNamed:@"Audio_playing_other_three"];
        _receiveAudioAnimationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"Audio_playing_other_three"],[UIImage imageNamed:@"Audio_playing_other_two"],[UIImage imageNamed:@"Audio_playing_other_one"],[UIImage imageNamed:@"Audio_playing_other_two"],[UIImage imageNamed:@"Audio_playing_other_three"],nil];
    }
    return _receiveAudioAnimationImageView;
}

- (UIImageView *)sendAudioAnimationImageView {
    if (!_sendAudioAnimationImageView) {
        _sendAudioAnimationImageView = [[UIImageView alloc] init];
        _sendAudioAnimationImageView.animationRepeatCount = 0;
        _sendAudioAnimationImageView.animationDuration = 1;
        _sendAudioAnimationImageView.image = [UIImage imageNamed:@"Audio_playing_self_three"];
        _sendAudioAnimationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"Audio_playing_self_three"],[UIImage imageNamed:@"Audio_playing_self_two"],[UIImage imageNamed:@"Audio_playing_self_one"],[UIImage imageNamed:@"Audio_playing_self_two"],[UIImage imageNamed:@"Audio_playing_self_three"],nil];
    }
    return _sendAudioAnimationImageView;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor lightGrayColor];
        _durationLabel.font = [UIFont systemFontOfSize:11];
        _durationLabel.textAlignment = NSTextAlignmentRight;
    }
    return _durationLabel;
}

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] init];
        _colorView.backgroundColor = RGBACOLOR(150, 150, 150, 0.5);
        _colorView.layer.cornerRadius = 20;
        _colorView.layer.masksToBounds = YES;
        _colorView.alpha = 0;
    }
    return _colorView;
}
@end
