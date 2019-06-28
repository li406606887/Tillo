//
//  InMessageCell.h
//  T-Shion
//
//  Created by together on 2018/12/12.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageViewCell.h"


#define NAME_LABEL_HEIGHT 25

NS_ASSUME_NONNULL_BEGIN

@interface InMessageCell : MessageViewCell
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *headView;
@property (assign, nonatomic) BOOL showName;
@property (copy, nonatomic) void (^headClickBlock) (NSString *userId);
@end

NS_ASSUME_NONNULL_END
