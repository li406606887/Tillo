//
//  OhterInformationViewController.h
//  T-Shion
//
//  Created by together on 2018/4/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendsModel.h"

@interface OtherInformationViewController : BaseViewController
@property (copy, nonatomic) FriendsModel *model;
//add by chw 2019.04.16 for Encryption
@property (nonatomic, assign) BOOL isCrypt;
@end
