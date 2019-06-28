//
//  ChooseAtManTableViewCell.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"

UIKIT_EXTERN NSString *const ChooseAtManTableViewCellReuseIdentifier;

@interface ChooseAtManTableViewCell : BaseTableViewCell

@property (strong, nonatomic) MemberModel *model;

@end

