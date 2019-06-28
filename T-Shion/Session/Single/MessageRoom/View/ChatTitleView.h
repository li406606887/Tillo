//
//  SingleChatNavigationView.h
//  T-Shion
//
//  Created by together on 2019/1/17.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatTitleView : UIView
@property (strong, nonatomic) FriendsModel *model;
@property (strong, nonatomic) GroupModel *group;
- (instancetype)initWithFrame:(CGRect)frame headIcon:(BOOL)isShow;
@property (copy, nonatomic) void (^backClick) (void);
@property (copy, nonatomic) void (^infoClick) (void);

- (void)refreshDisturbState;

//add by chw 2019.04.18 for Encryption
@property (nonatomic, assign) BOOL showLock;

@end

NS_ASSUME_NONNULL_END
