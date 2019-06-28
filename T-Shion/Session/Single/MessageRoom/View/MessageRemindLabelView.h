//
//  MessageRemindLabelView.h
//  T-Shion
//
//  Created by together on 2019/5/16.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageRemindLabelView : UIView
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *content;
@property (copy, nonatomic) void (^readFirstMsgBlock) (void);
@property (assign, nonatomic) int unreadCount;    
@end

NS_ASSUME_NONNULL_END
