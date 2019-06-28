//
//  TransmitRecentlyViewController.h
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//  转发-最近联系人

#import "BaseViewController.h"
#import "TransmitViewModel.h"

@interface TransmitViewController : BaseViewController

@property (nonatomic, copy) void (^completeBlock)(NSArray* selectArray);

@property (nonatomic, strong) MessageModel *transmitMessage;

@property (nonatomic, copy) NSArray *selectedArray; //最近会话中已选中的联系人，用于朋友和群聊中去除已选中
- (instancetype)initWithType:(TransmitViewType)type;

@end

