//
//  MessageTextView.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"
#import "KILabel.h"
#import "YYTextView.h"

@interface MessageTextView : MessageBaseView
//@property(strong, nonatomic) KILabel *contentLabel;
@property(strong, nonatomic) YYTextView *contentView;

@property (copy, nonatomic) void (^clickTextViewBlock) (id param);
@end
