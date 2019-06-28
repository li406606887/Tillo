//
//  MessageLocaltionView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/3/4.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

@interface MessageLocaltionView : MessageBaseView

@property (copy, nonatomic) void (^lookLocationDetailBlock) (MessageModel *model);

@end

