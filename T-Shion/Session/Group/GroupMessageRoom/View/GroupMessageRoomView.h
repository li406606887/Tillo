//
//  GroupMessageRoomView.h
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "BaseView.h"
#import "BaseTableView.h"

@interface GroupMessageRoomView : BaseView

@property (strong, nonatomic) BaseTableView *table;

- (void)stopAudioPlay;
- (void)loadDraftData;
@end
