//
//  MessageModelView.h
//  T-Shion
//
//  Created by together on 2018/12/10.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageModel;

@interface MessageModelView : UIView
@property (nonatomic, strong) MessageModel *message;
- (CGSize)messageSize;
@end
