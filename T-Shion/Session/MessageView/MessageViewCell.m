//
//  MessageViewCell.m
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageViewCell.h"
#import "MessageBaseView.h"
#import "MessageFileView.h"
#import "MessageTextView.h"
#import "MessageAudioView.h"
#import "MessageImageView.h"
#import "MessageVideoView.h"
#import "MessageRTCView.h"
#import "MessageWithdrawView.h"
#import "MessageNotificationView.h"
#import "MessageLocaltionView.h"
#import "MessageModel.h"
#import "NewMsgPromptView.h"
#import "ContactsCardView.h"

@implementation MessageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier {
    self =  [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = CGRectZero;
        
        switch (type) {
            case MESSAGE_NotifyTime:
            case MESSAGE_System:{
                MessageNotificationView *notify = [[MessageNotificationView alloc] initWithFrame:frame];
                self.bubbleView = notify;
            }
                break;
                
            case MESSAGE_TEXT: {
                MessageTextView *textView = [[MessageTextView alloc] initWithFrame:frame];
                self.bubbleView = textView;
            }
                break;
                
            case MESSAGE_AUDIO: {
                MessageAudioView *audioView = [[MessageAudioView alloc] initWithFrame:frame];
                self.bubbleView = audioView;
            }
                break;
                
            case MESSAGE_IMAGE: {
                MessageImageView *imageView = [[MessageImageView alloc] initWithFrame:frame];
//                @weakify(self)
//                imageView.updateHeightBlock = ^{
//                    @strongify(self)
//                    
//                };
                self.bubbleView = imageView;
            }
                break;
                
            case MESSAGE_Video: {
                MessageVideoView *fileView = [[MessageVideoView alloc] initWithFrame:frame];
                self.bubbleView = fileView;
            }
                break;
                
            case MESSAGE_File: {
                MessageFileView *fileView = [[MessageFileView alloc] initWithFrame:frame];
                self.bubbleView = fileView;
            }
                break;
                
            case MESSAGE_RTC: {
                MessageRTCView *rtcView = [[MessageRTCView alloc] initWithFrame:frame];
                self.bubbleView = rtcView;
            }
                break;
                
            case MESSAGE_Location: {
                MessageLocaltionView *localtionView = [[MessageLocaltionView alloc] initWithFrame:frame];
                self.bubbleView = localtionView;
                
            }
                break;
                
            case MESSAGE_Withdraw: {
                MessageWithdrawView *withdrawView = [[MessageWithdrawView alloc] initWithFrame:frame];
                self.bubbleView = withdrawView;
            }
                break;
                
            case MESSAGE_New_Msg: {
                NewMsgPromptView *newMsg = [[NewMsgPromptView alloc] initWithFrame:frame];
                self.bubbleView = newMsg;
            }
                break;
                
            case MESSAGE_Contacts_Card: {
                ContactsCardView *contactsCard = [[ContactsCardView alloc] initWithFrame:frame];
                self.bubbleView = contactsCard;
            }
                break;
                
            default: {
                MessageTextView *textView = [[MessageTextView alloc] initWithFrame:frame];
                self.bubbleView = textView;
            }
                
                break;
                
        }
        
        [self.contentView addSubview:self.bubbleView];
    }
    return self;
}


- (void)dealloc {
    [self.message removeObserver:self forKeyPath:@"uploading"];
    [self.message removeObserver:self forKeyPath:@"senderInfo"];
}

- (void)setMessage:(MessageModel*)message {
    [self.message removeObserver:self forKeyPath:@"uploading"];
    [self.message removeObserver:self forKeyPath:@"senderInfo"];
    _message = message;
    [self.message addObserver:self forKeyPath:@"senderInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.message addObserver:self forKeyPath:@"uploading" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

@end
