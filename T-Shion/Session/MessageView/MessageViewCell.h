//
//  MessageViewCell.h
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageModel;
@class MessageBaseView;

#define TRIANGLE_WIDTH 4
#define TRIANGLE_HEIGHT 8

@interface MessageViewCell : UITableViewCell
@property(nonatomic) MessageModel *message;
@property(nonatomic) UIView *containerView;
@property(nonatomic) MessageBaseView *bubbleView;
@property(nonatomic, assign) BOOL selectedToShowCopyMenu;

- (id)initWithType:(int)type reuseIdentifier:(NSString *)reuseIdentifier;
@end
