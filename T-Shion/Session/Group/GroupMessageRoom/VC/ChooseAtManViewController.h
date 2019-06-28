//
//  ChooseAtManViewController.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/2/13.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewController.h"

@protocol ChooseAtManViewControllerDelegate <NSObject>

@optional
- (void)didChooseAtUserWithData:(MemberModel *)userData;

@end


@interface ChooseAtManViewController : BaseViewController

- (instancetype)initWithRoomID:(NSString *)roomID;
@property (nonatomic, weak) id <ChooseAtManViewControllerDelegate> delegate;

@end

