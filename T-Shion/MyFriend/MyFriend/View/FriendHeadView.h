//
//  FriendHeadView.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/11.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendHeadViewDelegate <NSObject>

@optional

/**
 点击联系人页面操作按钮回调

 @param index 0.添加联系人 1.群聊 2.邀请好友
 */
- (void)didClickOperateButtonWithIndex:(NSInteger)index;

@end


@interface FriendHeadView : UIView

@property (nonatomic, weak) id <FriendHeadViewDelegate> delegate;
@property (nonatomic, assign) CGFloat scrollOffset;

@end

