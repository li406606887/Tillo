//
//  DialogueTableViewCell.h
//  T-Shion
//
//  Created by together on 2018/3/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseTableViewCell.h"
//#import "GroupSessionModel.h"

@interface SessionTableViewCell : BaseTableViewCell
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *detailsMessage;
@property (strong, nonatomic) UILabel *receivingTime;
@property (strong, nonatomic) UILabel *messageNumber;
@property (nonatomic, strong) UIImageView *disturbView;
@property (copy  , nonatomic) SessionModel *model;
@end
