//
//  DialogueContentToolView.h
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "ToolBarView.h"

@interface MessageRoomToolView : BaseView

@property (strong, nonatomic) ToolBarView *toolBar;

@property (copy, nonatomic) NSString *folderPath;
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) void (^changeHeightBlock) (CGFloat height);
@property (copy, nonatomic) void (^sendMessageBlock) (MessageModel *model);
@property (copy, nonatomic) void (^changeToolBarHeightBlock) (CGFloat height);

- (void)hidenSpaceView;

- (void)dissMissAllToolBoard;

@end
