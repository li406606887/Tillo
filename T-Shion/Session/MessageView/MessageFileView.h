//
//  MessageFileView.h
//  AilloTest
//
//  Created by together on 2019/2/18.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "MessageBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageFileView : MessageBaseView
@property (strong, nonatomic) UIView *touchView;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *fileName;
@property (strong, nonatomic) UILabel *fileSize;
@property (copy, nonatomic) void (^fileClickBlock) (id model);
@end

NS_ASSUME_NONNULL_END
