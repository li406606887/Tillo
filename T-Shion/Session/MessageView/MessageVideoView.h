//
//  MessageVideoView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/22.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

@interface MessageVideoView : MessageBaseView

@property (nonatomic, strong) UIImageView *previewView;

@property (copy, nonatomic) void (^lookVideoDetailBlock) (MessageModel *model, UIImageView *coverView);

@end

