//
//  MessageBaseView.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"

@class MessageModel;

@interface MessageBaseView : BaseView
@property (nonatomic, strong) MessageModel *message;
-(CGSize)bubbleSize;
@end
