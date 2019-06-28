//
//  LookForFileTableViewCell.h
//  T-Shion
//
//  Created by together on 2019/4/15.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LookForFileTableViewCell : BaseTableViewCell
@property (strong, nonatomic) UIImageView *head;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *fileName;
@property (strong, nonatomic) UILabel *fileSize;
@property (weak, nonatomic) MessageModel *message;
@end

NS_ASSUME_NONNULL_END
