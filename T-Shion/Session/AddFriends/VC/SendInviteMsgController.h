//
//  SendInviteMsgController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"
#import "SendInviteViewModel.h"

@interface SendInviteMsgController : BaseViewController

@property (nonatomic, strong) SendInviteViewModel *viewModel;
@property (nonatomic, assign) BOOL isNavPop;

@end

