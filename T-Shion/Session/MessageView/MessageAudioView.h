//
//  MessageAudioView.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

#define kAudioHeight 40
#define kAudioWidth 116

@interface MessageAudioView : MessageBaseView

@property (strong, nonatomic) UIView *redView;

@property (copy, nonatomic) void (^playBlock)(MessageModel *model);
@end
