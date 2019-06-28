//
//  MessageWithdrawView.h
//  T-Shion
//
//  Created by together on 2019/3/5.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageWithdrawView : MessageBaseView
@property (strong, nonatomic) UILabel *contentLabel;
@property (assign, nonatomic) int type;//1 单聊  2.群聊
@end

NS_ASSUME_NONNULL_END
