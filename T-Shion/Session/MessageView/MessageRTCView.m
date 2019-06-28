//
//  MessageRTCView.m
//  T-Shion
//
//  Created by together on 2019/1/7.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageRTCView.h"
#import "YMRTCDataItem.h"

@interface MessageRTCView ()
@property (nonatomic, strong) UIImageView *flagView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation MessageRTCView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.flagView];
    [self addSubview:self.contentLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    @weakify(self)
    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self)
        if (self.rtcCallBlock) {
            self.rtcCallBlock(self.message);
        }
    }];
    [self addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [self.flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_offset(CGSizeMake(20, 10));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_offset(30);
    }];
    
    [super layoutSubviews];
}

- (void)setMessage:(MessageModel *)message {
    [super setMessage:message];
    [self updateAudioViewLayoutWithWay:message.sendType];
    
    if (message.sendType == OtherSender) {

        if ([message.type isEqualToString:@"rtc_audio"]) {
            _flagView.image = [UIImage imageNamed:@"rtc_message_audio_receive"];
        } else {
            _flagView.image = [UIImage imageNamed:@"rtc_message_video_receive"];
        }
        
    } else {
        if ([message.type isEqualToString:@"rtc_audio"]) {
            _flagView.image = [UIImage imageNamed:@"rtc_message_audio_sender"];
        } else {
            _flagView.image = [UIImage imageNamed:@"rtc_message_video_sender"];
        }
    }
    
    NSString *contentStr = @"";
    
    if (message.rtcStatus < 10) {
        //如果是旧版的消息
        switch (message.rtcStatus) {
            case RTCMessageStatus_Default: {
                NSDate *date1970 = [NSDate dateWithTimeIntervalSince1970:0];
                NSDate *timeToShow = [date1970 dateByAddingTimeInterval:[message.duration integerValue]];
                if ([message.duration integerValue] >= 3600) {
                    self.dateFormatter.dateFormat = @"HH:mm:ss";
                } else {
                    self.dateFormatter.dateFormat = @"mm:ss";
                }
                
                contentStr = [NSString stringWithFormat:@"%@ %@",Localized(@"RTC_Msg_Durtion"),[self.dateFormatter stringFromDate:timeToShow]];
            }
                break;
                
                
            case RTCMessageStatus_YourCancel:
                contentStr = Localized(@"RTC_Msg_YourCancel");
                break;
                
            case RTCMessageStatus_OthersRefuse:
                contentStr = Localized(@"RTC_Msg_OthersRefuse");
                break;
                
                
            case RTCMessageStatus_BusyReceiver:
                contentStr = Localized(@"RTC_Msg_BusyReceiver");
                break;
                
            case RTCMessageStatus_OthersCancel:
                contentStr = Localized(@"RTC_Msg_OthersCancel");
                break;
                
            case RTCMessageStatus_YourRefuse:
                contentStr = Localized(@"RTC_Msg_YourRefuse");
                break;
                
            default:
                break;
        }
    } else {
        //如果是新版的消息
        switch (message.rtcStatus) {
                
            case YMRTCRecordType_Cancel:
                if (message.sendType == OtherSender) {
                    contentStr = Localized(@"RTC_Msg_OthersCancel");
                } else {
                    contentStr = Localized(@"RTC_Msg_YourCancel");
                }
                
                break;
                
            case YMRTCRecordType_Timeout:
                contentStr = Localized(@"RTC_Msg_NoAnswer");
                break;
                
            case YMRTCRecordType_Refuse:
                if (message.sendType == OtherSender) {
                    contentStr = Localized(@"RTC_Msg_YourRefuse");
                } else {
                    contentStr = Localized(@"RTC_Msg_OthersRefuse");
                }

                break;
                
            case YMRTCRecordType_BusyReceiver:
                contentStr = Localized(@"RTC_Msg_BusyReceiver");
                break;
               
            case YMRTCRecordType_DialingError:
                if (message.sendType == OtherSender) {
                    contentStr = Localized(@"RTC_Msg_OthersCancel");//连接失败
                } else {
                    contentStr = Localized(@"RTC_Msg_DialingError");//拨号失败
                }
   
                break;
                
            case YMRTCRecordType_ConnectingError:
//                contentStr = @"连接失败";
                if (message.sendType == OtherSender) {
                    contentStr = Localized(@"RTC_Msg_OthersCancel");//连接失败
                } else {
                    contentStr = Localized(@"RTC_Msg_DialingError");//拨号失败
                }

                break;
                
            case YMRTCRecordType_DisConnect:
//                contentStr = @"通话异常断开";
//                break;
    
                
            case YMRTCRecordType_Close: {
                NSDate *date1970 = [NSDate dateWithTimeIntervalSince1970:0];
                NSDate *timeToShow = [date1970 dateByAddingTimeInterval:[message.duration integerValue]];
                if ([message.duration integerValue] >= 3600) {
                    self.dateFormatter.dateFormat = @"HH:mm:ss";
                } else {
                    self.dateFormatter.dateFormat = @"mm:ss";
                }
                
                contentStr = [NSString stringWithFormat:@"%@ %@",Localized(@"RTC_Msg_Durtion"),[self.dateFormatter stringFromDate:timeToShow]];
            }
                break;
                
            default:
                break;
        }
    }
    
    self.contentLabel.text = contentStr;
    self.contentLabel.textColor = message.sendType == OtherSender ? [UIColor blackColor]: [UIColor whiteColor];

}

- (void)updateAudioViewLayoutWithWay:(MsgSendType)type {
    if (type == OtherSender) {
        [self.flagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(10);
        }];
        
        [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.flagView.mas_right).with.offset(5);
            make.right.equalTo(self.mas_right).with.offset(-10);
        }];
    }else {
        [self.flagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).with.offset(-10);
        }];
        
        [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.flagView.mas_left).with.offset(-5);
            make.left.equalTo(self.mas_left).with.offset(10);
        }];
    }
}

- (CGSize)bubbleSize {
    UIFont *font = [[self class] font];
    CGSize textSize = [MessageRTCView textSizeForText:self.contentLabel.text withFont:font];
    textSize.width += 50;
    textSize.height = 40;
    return textSize;
}

+ (UIFont *)font {
    return [UIFont systemFontOfSize:17.0f];
}

+ (CGSize)textSizeForText:(NSString *)txt withFont:(UIFont*)font{
    CGFloat width = SCREEN_WIDTH * 0.65f;
    CGFloat height = 40;
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = font;
    gettingSizeLabel.text = txt;
    gettingSizeLabel.numberOfLines = 1;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(width, height);
    return  [gettingSizeLabel sizeThatFits:maximumLabelSize];
}

#pragma mark lazy load
- (UIImageView *)flagView {
    if (!_flagView) {
        _flagView = [[UIImageView alloc] init];
        _flagView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _flagView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [MessageRTCView font];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _contentLabel;
}

- (NSDateFormatter*)dateFormatter{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    return _dateFormatter;
}

@end
